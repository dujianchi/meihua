import 'dart:async';
import 'dart:convert';

import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/entity/database/db_history_sync.dart';
import 'package:meihua/util/config_helper.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

/// webdav同步助手
class SyncHelper {
  static webdav.Client? _client;

  static Future<webdav.Client?> _getSyncClient() async {
    if (_client == null) {
      final (serverUrl, account, password) = await getWebDavConf();
      _client = webdav.newClient(
        serverUrl!,
        user: account!,
        password: password!,
        debug: false,
      )
        ..setHeaders({
          'accept-charset': 'utf-8',
          "content-type": "text/plain",
        })
        ..setConnectTimeout(8000)
        ..setSendTimeout(8000)
        ..setReceiveTimeout(8000);
      try {
        await _client!.ping();
      } catch (e) {
        e.log('webdav exception: ');
        _client = null;
      } finally {}
    }
    return _client;
  }

  static Future<(String?, String?, String?)> getWebDavConf() async {
    final serverUrl = await ConfigHelper.getConfig('webdav_server');
    final account = await ConfigHelper.getConfig('webdav_account');
    final password = await ConfigHelper.getConfig('webdav_password');
    return (serverUrl, account, password);
  }

  static Future<void> saveWebDavConf(
      String? url, String? account, String? password) async {
    await ConfigHelper.saveConfig('webdav_server', url);
    await ConfigHelper.saveConfig('webdav_account', account);
    await ConfigHelper.saveConfig('webdav_password', password);
  }

  static Future<bool> isConfigured() async {
    final (url, account, password) = await getWebDavConf();
    return url.isNotBlank && account.isNotBlank && password.isNotBlank;
  }

  static Future<String> _getContent(String path) async {
    try {
      final client = await _getSyncClient();
      final bytes = await client?.read(path);
      return bytes == null ? '' : utf8.decode(bytes);
    } catch (ex) {
      ex.log('get content error');
      return '';
    }
  }

  // static Future<List<String>> _getFileList(String path) async {
  //   final client = await _getSyncClient();
  //   final list = await client?.readDir(path);
  //   return list?.map((f) => f.path ?? '').where((t) => t.isNotBlank).toList() ??
  //       <String>[];
  // }

  static _write(String path, String? content) async {
    final client = await _getSyncClient();
    await client?.write(path, utf8.encode(content ?? ''));
  }

  // static Future<bool> _isExists(String path) async {
  //   final client = await _getSyncClient();
  //   final response = await client?.c.wdOptions(client, path);
  //   return response?.statusCode == 200;
  // }

  static _createDir(String path) async {
    final client = await _getSyncClient();
    await client?.mkdirAll(path);
  }

  static Future<void> sync([bool toast = true]) async {
    const dir = '/meihua',
        lock = '$dir/lock',
        json = '$dir/sync.json',
        days = 24 * 60 * 60 * 1000;
    var acquired = false;
    try {
      // 先确认 WebDAV 可达,否则下面的读返回空、写是空操作,却会误报"同步完成"
      if (await _getSyncClient() == null) {
        if (toast) '同步失败：无法连接 WebDAV'.toast();
        return;
      }
      await _createDir(dir);
      final lockStr = await _getContent(lock);
      // 判断锁是否有效，默认锁24小时
      if (lockStr.isBlank ||
          DateTime.now().millisecondsSinceEpoch - lockStr.toInt() >= days) {
        //将当前时间戳写入 lock 文件
        await _write(lock, '${DateTime.now().millisecondsSinceEpoch}');
        acquired = true;
        // 读远端快照(自动兼容旧操作日志格式,见 _readRemoteSnapshot)
        final remoteList = await _readRemoteSnapshot(json);
        // 本地全量快照:立即克隆,避免持有 Hive frame 缓存的对象引用
        // (Hive CE 的 frame 缓存与 box.values 返回同一批对象,就地修改
        //  可能因 frame 内部反序列化/缓存淘汰导致字段被清空)
        final rawList =
            (await DbHelper.query<DbHistory>(DbHistory.nameDb))?.toList() ?? [];
        final localList =
            rawList.map((h) => DbHistory()..fromMap(h.toMap())).toList();
        // 修复历史遗留:syncHash 为空的旧记录补算并刷新,否则快照合并会漏掉它们
        await _normalizeLocal(localList);
        // 按 syncHash 合并,update_time 新者胜(last-write-wins),平局墓碑胜
        final merged = _mergeSnapshots(remoteList, localList);
        // 落地本地(只更新比本地新的条目,新增远端独有的)
        await _applyToLocal(merged, localList);
        // 整份快照写回远端(跳过关键字段为空的损坏记录)
        final clean = merged
            .map((h) => h.toMap())
            .where((m) => m['sync_hash'] != null && m['save_date'] != null)
            .toList();
        await _write(json, clean.toJson());
        if (toast) '同步完成'.toast();
      } else {
        // 锁仍有效:别的设备(或上次崩溃的同步)持有,本次跳过,不能报"完成"
        '同步跳过：另一设备正在同步,请稍后再试'.toast(5);
      }
    } catch (ex) {
      ex.log('sync error: $ex');
      if (toast) '同步失败：$ex'.toast();
    } finally {
      // 只清自己抢到的锁,别把别的设备持有的锁误清掉
      if (acquired) {
        await _write(lock, '');
      }
    }
  }

  static forceSync() async {
    // 本地整份快照直接覆盖远端(状态快照模型下不再需要"全删"指令)
    const dir = '/meihua',
        lock = '$dir/lock',
        json = '$dir/sync.json',
        days = 24 * 60 * 60 * 1000;
    var acquired = false;
    try {
      if (await _getSyncClient() == null) {
        '同步失败：无法连接 WebDAV'.toast();
        return;
      }
      await _createDir(dir);
      final lockStr = await _getContent(lock);
      if (lockStr.isBlank ||
          DateTime.now().millisecondsSinceEpoch - lockStr.toInt() >= days) {
        await _write(lock, '${DateTime.now().millisecondsSinceEpoch}');
        acquired = true;
        final rawList =
            (await DbHelper.query<DbHistory>(DbHistory.nameDb))?.toList() ?? [];
        // 克隆后操作,避免 Hive frame 缓存引用问题
        final localList =
            rawList.map((h) => DbHistory()..fromMap(h.toMap())).toList();
        await _normalizeLocal(localList);
        final clean = localList
            .map((h) => h.toMap())
            .where((m) => m['sync_hash'] != null && m['save_date'] != null)
            .toList();
        await _write(json, clean.toJson());
        '同步完成'.toast();
      } else {
        '同步跳过：另一设备正在同步,请稍后再试'.toast(5);
      }
    } catch (ex) {
      ex.log('sync error: $ex');
      '同步失败：$ex'.toast();
    } finally {
      if (acquired) {
        await _write(lock, '');
      }
    }
  }

  // ---- 状态快照合并工具 ----

  static Timer? _autoSyncTimer;

  /// 安排一次延迟自动同步(默认 2 秒后)。连续调用会重置计时,把快速连续的
  /// 增删改合并成一次同步。仅在已配置 WebDAV 时实际执行;同步在后台进行,
  /// 不阻塞 UI。本地数据已即时落盘,同步只负责推到远端,所以 UI 始终是新的。
  static Future<void> scheduleAutoSync(
      [Duration delay = const Duration(seconds: 2)]) async {
    if (!await isConfigured()) return;
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer(delay, () async {
      _autoSyncTimer = null;
      try {
        await sync(false);
      } catch (ex) {
        ex.log('auto sync error: ');
      }
    });
  }

  /// 修复历史遗留:旧版本落盘时 syncHash 可能为 null,补算并刷新 updateTime,
  /// 使其能正常参与快照合并(否则会被 _mergeSnapshots 跳过,导致漏推/重复)。
  static Future<void> _normalizeLocal(List<DbHistory> localList) async {
    for (final h in localList) {
      if (h.syncHash == null || h.syncHash!.isEmpty) {
        h.ensureSyncHash();
        h.touch();
        await DbHelper.save(h);
      }
    }
  }

  /// 记录的版本时间戳:优先 update_time,回退 save_date,再回退 0
  static int _ts(DbHistory h) => h.updateTime ?? h.saveDate ?? 0;

  /// candidate 是否应替换 prev:时间戳不同则新者胜;相同(同毫秒)时
  /// 已删除(deleted=1)的版本胜出——删除是终止操作,应优先传播,
  /// 否则一条刚删除的墓碑可能被同毫秒的旧版本压住、推不到远端。
  static bool _shouldReplace(DbHistory candidate, DbHistory prev) {
    final tc = _ts(candidate), tp = _ts(prev);
    if (tc != tp) return tc > tp;
    return candidate.deleted == 1 && prev.deleted != 1;
  }

  /// 按 syncHash 合并两端快照,相同 key 取 update_time 新者,平局墓碑胜
  /// 返回克隆后的新对象,与入参列表完全独立,避免 Hive frame 缓存引用问题
  static List<DbHistory> _mergeSnapshots(
      List<DbHistory> remote, List<DbHistory> local) {
    final byHash = <String, DbHistory>{};
    for (final h in [...remote, ...local]) {
      final key = h.syncHash;
      if (key == null || key.isEmpty) continue;
      final prev = byHash[key];
      if (prev == null || _shouldReplace(h, prev)) {
        // 克隆后放入合并结果,断绝与 Hive frame / 远程临时对象的引用关系
        byHash[key] = DbHistory()..fromMap(h.toMap());
      }
    }
    return byHash.values.toList();
  }

  /// 把合并结果落地到本地:新增远端独有的、用较新版本覆盖本地旧版本
  static Future<void> _applyToLocal(
      List<DbHistory> merged, List<DbHistory> local) async {
    final localByHash = {for (var h in local) h.syncHash: h};
    for (final m in merged) {
      final key = m.syncHash;
      if (key == null || key.isEmpty) continue;
      final existing = localByHash[key];
      if (existing == null) {
        // 本地没有,新增(用本地新 id,丢弃远端 id)
        final dh = DbHistory()..fromMap(m.toMap());
        dh.id = null;
        await DbHelper.save(dh);
      } else if (_shouldReplace(m, existing)) {
        // 合并版本比本地新(或同毫秒但为墓碑),覆盖本地(保留本地 id)
        final dh = DbHistory()..fromMap(m.toMap());
        dh.id = existing.id;
        await DbHelper.save(dh);
      }
    }
  }

  /// 读远端 sync.json 并还原成 DbHistory 列表。
  /// 兼容两种格式:
  ///  - 新格式:List<DbHistory 快照 map>
  ///  - 旧格式:List<DbHistorySync 操作日志>(含 'operate' 字段),回放一次转成快照
  static Future<List<DbHistory>> _readRemoteSnapshot(String json) async {
    final jsonStr = await _getContent(json);
    if (jsonStr.isBlank) return [];
    final arr = jsonDecode(jsonStr) as List<dynamic>;
    if (arr.isEmpty) return [];
    final first = arr.first;
    if (first is Map && first.containsKey('operate')) {
      return _replayOldLog(arr.cast<Map<String, dynamic>>());
    }
    return arr
        .map((e) => DbHistory()..fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// 回放旧操作日志(1=增 2=删 3=改)得到最终态快照,用于一次性迁移
  static List<DbHistory> _replayOldLog(List<Map<String, dynamic>> arr) {
    final logs = arr.map((m) => DbHistorySync()..fromMap(m)).toList()
      ..sort((a, b) => (a.createTime ?? 0).compareTo(b.createTime ?? 0));
    final byHash = <String, DbHistory>{};
    for (final hs in logs) {
      if (hs.operate == 1 || hs.operate == 3) {
        final dh = DbHistory()..fromMap(hs.data?.jsonToMap() ?? const {});
        if (dh.syncHash != null && dh.syncHash!.isNotEmpty) {
          byHash[dh.syncHash!] = dh;
        }
      } else if (hs.operate == 2) {
        if (hs.whereArgs.isNotBlank && hs.whereParam.isNotBlank) {
          byHash.remove(hs.whereParam);
        } else {
          byHash.clear();
        }
      }
    }
    return byHash.values.toList();
  }
}
