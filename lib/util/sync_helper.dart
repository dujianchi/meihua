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

  static sync() async {
    const dir = '/meihua',
        lock = '$dir/lock',
        json = '$dir/sync.json',
        days = 24 * 60 * 60 * 1000;
    try {
      final lastUpdate = (await ConfigHelper.getConfig('last_update')).toInt();
      await _createDir(dir);
      final lockStr = await _getContent(lock);
      // 判断锁是否有效，默认锁24小时
      if (lockStr.isBlank ||
          DateTime.now().millisecondsSinceEpoch - lockStr.toInt() >= days) {
        //将当前时间戳写入 lock 文件
        await _write(lock, '${DateTime.now().millisecondsSinceEpoch}');
        // 读取 sync.json
        final jsonStr = await _getContent(json);
        final jsonArr =
            jsonStr.isNotBlank ? jsonDecode(jsonStr) as List<dynamic> : [];
        final dbHistorySyncOnline =
            jsonArr.map((m) => DbHistorySync()..fromMap(m)).toList();
        final dbHistorySyncLocalList = await DbHistorySync.query();
        // 线上数据过滤掉本地的
        final onlineToLocal = dbHistorySyncOnline.where((hs) {
          if ((hs.createTime ?? -1) < lastUpdate) return false;
          if (hs.operate == 2) return true;
          final hsm = DbHistory()..fromMap(hs.data.jsonToMap());
          final localMatched = dbHistorySyncLocalList.where(
            (hsl) {
              final hslm = DbHistory()..fromMap(hsl.data.jsonToMap());
              return hsm.syncHash == hslm.syncHash;
            },
          );
          return localMatched.isEmpty;
        }).toList();
        // 数据按时间排序
        onlineToLocal
            .sort((a, b) => a.createTime?.compareTo(b.createTime ?? 0) ?? 0);
        // 按照 1=增 2=删 3=改 的逻辑处理数据
        for (var hs in onlineToLocal) {
          if (hs.operate == 1 || hs.operate == 3) {
            final dh = DbHistory()..fromMap(hs.data.jsonToMap());
            dh.id == null;
            if (hs.operate == 1) {
              await DbHelper.save(dh);
            } else {
              await DbHelper.update(dh, 'sync_hash');
            }
          } else if (hs.operate == 2) {
            if (hs.whereArgs.isNotBlank && hs.whereParam.isNotBlank) {
              await DbHelper.delete(DbHistory.nameDb,
                  where: hs.whereArgs, whereArgs: [hs.whereParam]);
            }
          }
        }
        // 本地所有未上传的
        final localToOnline =
            dbHistorySyncLocalList.where((hs) => hs.uploaded == 0).toList();
        for (var hs in localToOnline) {
          hs.uploaded = 1;
          await DbHelper.update(hs);
        }
        localToOnline.addAll(onlineToLocal);
        if (localToOnline.isNotEmpty) {
          localToOnline
              .sort((a, b) => a.createTime?.compareTo(b.createTime ?? 0) ?? 0);
          await _write(
              json, localToOnline.map((hs) => hs.toMap()).toList().toJson());
        }
      }
      '同步完成'.toast();
    } catch (ex) {
      ex.log('sync error: $ex');
      '同步失败：$ex'.toast();
    } finally {
      await ConfigHelper.saveConfig(
          'last_update', '${DateTime.now().millisecondsSinceEpoch}');
      await _write(lock, '');
    }
  }

  static forceSync() async {
    // 本地覆盖同步，即代表本地历史所有数据要被删除，然后服务器上的数据也应该被清除
    const dir = '/meihua',
        lock = '$dir/lock',
        json = '$dir/sync.json',
        days = 24 * 60 * 60 * 1000;
    try {
      await _createDir(dir);
      final lockStr = await _getContent(lock);
      // 判断锁是否有效，默认锁24小时
      if (lockStr.isBlank ||
          DateTime.now().millisecondsSinceEpoch - lockStr.toInt() >= days) {
        //将当前时间戳写入 lock 文件
        await _write(lock, '${DateTime.now().millisecondsSinceEpoch}');
        // 删除本地历史记录
        await DbHelper.delete(DbHistorySync.nameDb,
            where: 'id > ?', whereArgs: [0]);
        // 构造一个删除记录
        final dbHistorySyncDelAll = DbHistorySync()
          ..createTime = DateTime.now().millisecondsSinceEpoch
          ..operate = 2
          ..uploaded = 0
          ..whereArgs = 'id > ?'
          ..whereParam = '0';
        await DbHelper.save(dbHistorySyncDelAll);
        // 查询本地所有记录，构造新增记录
        final localList = await DbHelper.query(DbHistory.nameDb);
        for (var dh in localList) {
          final dbHistorySync = DbHistorySync()
            ..createTime = DateTime.now().millisecondsSinceEpoch
            ..operate = 1
            ..uploaded = 0
            ..data = dh.toJson();
          await DbHelper.save(dbHistorySync);
        }
        // 上传所有新构造的新增记录
        final syncList = await DbHelper.query(DbHistorySync.nameDb);
        await _write(json, syncList.toJson());
      }
      '同步完成'.toast();
    } catch (ex) {
      ex.log('sync error: $ex');
      '同步失败：$ex'.toast();
    } finally {
      await ConfigHelper.saveConfig(
          'last_update', '${DateTime.now().millisecondsSinceEpoch}');
      await _write(lock, '');
    }
  }
}
