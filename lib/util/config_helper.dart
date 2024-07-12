import 'package:meihua/entity/database/db_config.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';

/// 配置工具类
class ConfigHelper {
  static Future<DbConfig?> _getConfig(String key) async {
    if (key.isBlank) return null;
    final configs = await DbHelper.query(DbConfig.nameDb,
        where: 'key = ?', whereArgs: [key], limit: 1);
    final conf = configs.firstOrNull;
    return conf == null ? null : (DbConfig()..fromMap(conf));
  }

  static Future<String?> getConfig(String key) async {
    final conf = await _getConfig(key);
    return conf?.val;
  }

  static Future<void> saveConfig(String key, String? val) async {
    var conf = await _getConfig(key);
    if (conf == null) {
      conf = DbConfig()
        ..key = key
        ..val = val;
      await DbHelper.save(conf);
    } else {
      conf.val = val;
      await DbHelper.update(conf);
    }
  }
}
