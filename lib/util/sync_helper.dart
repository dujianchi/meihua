import 'dart:async';
import 'dart:convert';

import 'package:meihua/entity/database/db_ai_chat.dart';
import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/entity/database/db_history_sync.dart';
import 'package:meihua/util/ai_helper.dart';
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
        await syncAiChat(false);
        await syncAiConfig(false);
      } catch (ex) {
        ex.log('auto sync error: ');
      }
    });
  }

  /// 修复历史遗留:
  /// 1. 旧版本落盘时 syncHash 可能为 null,补算并刷新 updateTime,
  ///    使其能正常参与快照合并(否则会被 _mergeSnapshots 跳过,导致漏推/重复)。
  /// 2. 存量已删除记录(旧版本删除未瘦身)执行一次性瘦身迁移:
  ///    保留墓碑字段、清空其余,不刷新 updateTime,不破坏 LWW。
  static Future<void> _normalizeLocal(List<DbHistory> localList) async {
    for (final h in localList) {
      if (h.syncHash == null || h.syncHash!.isEmpty) {
        h.ensureSyncHash();
        h.touch();
        await DbHelper.save(h);
      }
      if (h.deleted == 1 && !h.isStrippedTombstone) {
        h.tombstone(touch: false);
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

  /// 按 syncHash 合并两端快照,相同 key 取 update_time 新者,平局墓碑胜。
  /// 迭代顺序 本地在前:平局(同时间戳)时保留本地版本——
  /// 本地已做墓碑瘦身迁移,可把精简版写回远端,逐步压缩远端同步文件
  static List<DbHistory> _mergeSnapshots(
      List<DbHistory> remote, List<DbHistory> local) {
    final byHash = <String, DbHistory>{};
    for (final h in [...local, ...remote]) {
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

  // ==================== AI对话同步(独立文件,不掺和排盘历史) ====================

  static const _aiDir = '/meihua',
      _aiLock = '$_aiDir/ai_chat.lock',
      _aiJson = '$_aiDir/ai_chat.json',
      _lockDays = 24 * 60 * 60 * 1000;

  /// AI对话同步:与排盘历史同模型(快照+LWW+墓碑),但使用独立的同步文件与锁
  static Future<void> syncAiChat([bool toast = true]) async {
    var acquired = false;
    try {
      if (await _getSyncClient() == null) {
        if (toast) '对话同步失败：无法连接 WebDAV'.toast();
        return;
      }
      await _createDir(_aiDir);
      final lockStr = await _getContent(_aiLock);
      if (lockStr.isBlank ||
          DateTime.now().millisecondsSinceEpoch - lockStr.toInt() >= _lockDays) {
        await _write(_aiLock, '${DateTime.now().millisecondsSinceEpoch}');
        acquired = true;
        final remoteList = await _readAiChatSnapshot(_aiJson);
        final rawList =
            (await DbHelper.query<DbAiChat>(DbAiChat.nameDb))?.toList() ?? [];
        final localList =
            rawList.map((h) => DbAiChat()..fromMap(h.toMap())).toList();
        await _normalizeAiChatLocal(localList);
        final merged = _mergeAiChatSnapshots(remoteList, localList);
        await _applyAiChatToLocal(merged, localList);
        final clean = merged
            .map((h) => h.toMap())
            .where((m) => m['sync_hash'] != null)
            .toList();
        await _write(_aiJson, clean.toJson());
        if (toast) '对话同步完成'.toast();
      } else {
        '对话同步跳过：另一设备正在同步,请稍后再试'.toast(5);
      }
    } catch (ex) {
      ex.log('ai chat sync error: $ex');
      if (toast) '对话同步失败：$ex'.toast();
    } finally {
      if (acquired) {
        await _write(_aiLock, '');
      }
    }
  }

  /// AI对话强制同步:本地整份快照直接覆盖远端
  static Future<void> forceSyncAiChat() async {
    var acquired = false;
    try {
      if (await _getSyncClient() == null) {
        '对话同步失败：无法连接 WebDAV'.toast();
        return;
      }
      await _createDir(_aiDir);
      final lockStr = await _getContent(_aiLock);
      if (lockStr.isBlank ||
          DateTime.now().millisecondsSinceEpoch - lockStr.toInt() >= _lockDays) {
        await _write(_aiLock, '${DateTime.now().millisecondsSinceEpoch}');
        acquired = true;
        final rawList =
            (await DbHelper.query<DbAiChat>(DbAiChat.nameDb))?.toList() ?? [];
        final localList =
            rawList.map((h) => DbAiChat()..fromMap(h.toMap())).toList();
        await _normalizeAiChatLocal(localList);
        final clean = localList
            .map((h) => h.toMap())
            .where((m) => m['sync_hash'] != null)
            .toList();
        await _write(_aiJson, clean.toJson());
        '对话同步完成'.toast();
      } else {
        '对话同步跳过：另一设备正在同步,请稍后再试'.toast(5);
      }
    } catch (ex) {
      ex.log('ai chat sync error: $ex');
      '对话同步失败：$ex'.toast();
    } finally {
      if (acquired) {
        await _write(_aiLock, '');
      }
    }
  }

  /// 修复历史遗留:syncHash 为空补算;存量已删除记录做一次性瘦身迁移
  static Future<void> _normalizeAiChatLocal(List<DbAiChat> localList) async {
    for (final h in localList) {
      if (h.syncHash == null || h.syncHash!.isEmpty) {
        h.ensureSyncHash();
        h.touch();
        await DbHelper.save(h);
      }
      if (h.deleted == 1 && !h.isStrippedTombstone) {
        h.tombstone(touch: false);
        await DbHelper.save(h);
      }
    }
  }

  static int _tsChat(DbAiChat h) => h.updateTime ?? 0;

  static bool _shouldReplaceChat(DbAiChat candidate, DbAiChat prev) {
    final tc = _tsChat(candidate), tp = _tsChat(prev);
    if (tc != tp) return tc > tp;
    return candidate.deleted == 1 && prev.deleted != 1;
  }

  static List<DbAiChat> _mergeAiChatSnapshots(
      List<DbAiChat> remote, List<DbAiChat> local) {
    final byHash = <String, DbAiChat>{};
    for (final h in [...local, ...remote]) {
      final key = h.syncHash;
      if (key == null || key.isEmpty) continue;
      final prev = byHash[key];
      if (prev == null || _shouldReplaceChat(h, prev)) {
        byHash[key] = DbAiChat()..fromMap(h.toMap());
      }
    }
    return byHash.values.toList();
  }

  static Future<void> _applyAiChatToLocal(
      List<DbAiChat> merged, List<DbAiChat> local) async {
    final localByHash = {for (var h in local) h.syncHash: h};
    for (final m in merged) {
      final key = m.syncHash;
      if (key == null || key.isEmpty) continue;
      final existing = localByHash[key];
      if (existing == null) {
        final dh = DbAiChat()..fromMap(m.toMap());
        dh.id = null;
        await DbHelper.save(dh);
      } else if (_shouldReplaceChat(m, existing)) {
        final dh = DbAiChat()..fromMap(m.toMap());
        dh.id = existing.id;
        await DbHelper.save(dh);
      }
    }
  }

  static Future<List<DbAiChat>> _readAiChatSnapshot(String json) async {
    final jsonStr = await _getContent(json);
    if (jsonStr.isBlank) return [];
    final arr = jsonDecode(jsonStr) as List<dynamic>;
    return arr
        .map((e) => DbAiChat()..fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ==================== AI设置同步(单份最新配置,新覆盖旧,无历史) ====================

  static const _aiConfJson = '$_aiDir/ai_config.json';
  static const _aiConfLock = '$_aiDir/ai_config.lock';

  /// 读取本地AI配置(只收集已配置的项)
  static Future<Map<String, dynamic>> _localAiConfigMap() async {
    final map = <String, dynamic>{};
    for (final key in AiHelper.configKeys) {
      final val = await ConfigHelper.getConfig(key);
      if (val?.isNotEmpty == true) {
        map[key] = val;
      }
    }
    return map;
  }

  static Future<Map<String, dynamic>?> _readAiConfigRemote() async {
    final jsonStr = await _getContent(_aiConfJson);
    if (jsonStr.isBlank) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (ex) {
      ex.log('ai config 解析失败: ');
      return null;
    }
  }

  /// AI设置同步:只保留一份最新配置,update_time 新者胜,永远以新的覆盖旧的
  static Future<void> syncAiConfig([bool toast = true]) async {
    var acquired = false;
    try {
      if (await _getSyncClient() == null) {
        if (toast) 'AI设置同步失败：无法连接 WebDAV'.toast();
        return;
      }
      await _createDir(_aiDir);
      final lockStr = await _getContent(_aiConfLock);
      if (lockStr.isBlank ||
          DateTime.now().millisecondsSinceEpoch - lockStr.toInt() >=
              _lockDays) {
        await _write(_aiConfLock, '${DateTime.now().millisecondsSinceEpoch}');
        acquired = true;
        final remote = await _readAiConfigRemote();
        final localMap = await _localAiConfigMap();
        final localTime =
            (await ConfigHelper.getConfig(AiHelper.keyUpdateTime)).toInt();
        final remoteTime = (remote?['update_time'] as num?)?.toInt() ?? 0;
        // 远端存在且(本地无配置 或 远端更新) → 远端胜;否则本地胜。
        // 注意:本地无配置时必须远端胜,否则空配置会覆盖远端并把 update_time
        // 打成 0,导致后续所有设备 0>=0 永远本地胜、互相覆盖不了
        final remoteWins =
            remote != null && (localMap.isEmpty || localTime < remoteTime);
        if (remoteWins) {
          // 远端为准:覆盖本地配置,并同步时间戳
          for (final key in AiHelper.configKeys) {
            final val = remote[key];
            if (val is String && val.isNotEmpty) {
              await ConfigHelper.saveConfig(key, val);
            }
          }
          await ConfigHelper.saveConfig(AiHelper.keyUpdateTime, '$remoteTime');
        } else {
          // 本地为准:整份覆盖远端。本地无配置(远端也空)时写空壳;
          // 本地有配置但缺时间戳(被 0 污染的旧文件)时补记当前时间,顺带修复
          final ts = localMap.isEmpty
              ? 0
              : (localTime > 0
                  ? localTime
                  : DateTime.now().millisecondsSinceEpoch);
          final payload = <String, dynamic>{...localMap, 'update_time': ts};
          await _write(_aiConfJson, payload.toJson());
        }
        if (toast) 'AI设置同步完成'.toast();
      } else {
        'AI设置同步跳过：另一设备正在同步,请稍后再试'.toast(5);
      }
    } catch (ex) {
      ex.log('ai config sync error: $ex');
      if (toast) 'AI设置同步失败：$ex'.toast();
    } finally {
      if (acquired) {
        await _write(_aiConfLock, '');
      }
    }
  }

  /// AI设置强制同步:本地配置整份覆盖远端(本地无配置时不覆盖,避免误清云端)
  static Future<void> forceSyncAiConfig() async {
    var acquired = false;
    try {
      if (await _getSyncClient() == null) {
        'AI设置同步失败：无法连接 WebDAV'.toast();
        return;
      }
      await _createDir(_aiDir);
      final lockStr = await _getContent(_aiConfLock);
      if (lockStr.isBlank ||
          DateTime.now().millisecondsSinceEpoch - lockStr.toInt() >=
              _lockDays) {
        await _write(_aiConfLock, '${DateTime.now().millisecondsSinceEpoch}');
        acquired = true;
        final localMap = await _localAiConfigMap();
        if (localMap.isNotEmpty) {
          final nowMs = DateTime.now().millisecondsSinceEpoch;
          await ConfigHelper.saveConfig(AiHelper.keyUpdateTime, '$nowMs');
          final payload = <String, dynamic>{...localMap, 'update_time': nowMs};
          await _write(_aiConfJson, payload.toJson());
        }
        'AI设置同步完成'.toast();
      } else {
        'AI设置同步跳过：另一设备正在同步,请稍后再试'.toast(5);
      }
    } catch (ex) {
      ex.log('ai config sync error: $ex');
      'AI设置同步失败：$ex'.toast();
    } finally {
      if (acquired) {
        await _write(_aiConfLock, '');
      }
    }
  }
}
