import 'dart:async';

import 'package:meihua/util/config_helper.dart';
import 'package:meihua/util/exts.dart';
import 'package:webdav_client/webdav_client.dart';

/// webdav同步助手
class SyncHelper {
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

  static String _getContent(String path) {
    return '';
  }

  static List<String> _getFileList(String path) {
    return [];
  }

  static bool _isExists(String path) {
    return false;
  }

  static _createDir(String path) async {
    final (serverUrl, account, password) = await getWebDavConf();
    final client = newClient(
      serverUrl!,
      user: account!,
      password: password!,
      debug: false,
    );
    client.setHeaders({'accept-charset': 'utf-8'});
    client.setConnectTimeout(8000);
    client.setSendTimeout(8000);
    client.setReceiveTimeout(8000);
    try {
      await client.ping();
      await client.mkdir('/meihua');
      var list = await client.readDir('/meihua');
      if (list.isEmpty) {
      } else {}
    } catch (e) {
      e.log('webdav exception: ');
    } finally {}
  }

  static sync() {}
  static forceSync() {}
}
