import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:meihua/entity/database/base.dart';
import 'package:meihua/entity/database/db_64gua.dart';
import 'package:meihua/entity/database/db_8gua.dart';
import 'package:meihua/entity/database/db_config.dart';
import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/entity/database/db_history_sync.dart';
import 'package:meihua/util/exts.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal(
    Hive.box<Db8gua>(Db8gua.nameDb),
    Hive.box<Db64gua>(Db64gua.nameDb),
    Hive.box<DbConfig>(DbConfig.nameDb),
    Hive.box<DbHistory>(DbHistory.nameDb),
    Hive.box<DbHistorySync>(DbHistorySync.nameDb),
  );

  final Box<Db8gua> _8guaBox;
  final Box<Db64gua> _64guaBox;
  final Box<DbConfig> _configBox;
  final Box<DbHistory> _historyBox;
  final Box<DbHistorySync> _historySyncBox;

  DbHelper._internal(this._8guaBox, this._64guaBox, this._configBox,
      this._historyBox, this._historySyncBox);

  factory DbHelper() {
    return _instance;
  }

  static Box<Base>? _database(Base data) {
    final tableName = data.dbName;
    return _databaseByName(tableName);
  }

  static Box<Base>? _databaseByName(String tableName) {
    if (tableName == Db8gua.nameDb) {
      return _instance._8guaBox;
    } else if (tableName == Db64gua.nameDb) {
      return _instance._64guaBox;
    } else if (tableName == DbConfig.nameDb) {
      return _instance._configBox;
    } else if (tableName == DbHistory.nameDb) {
      return _instance._historyBox;
    } else if (tableName == DbHistorySync.nameDb) {
      return _instance._historySyncBox;
    }
    return null;
  }

  static Future<void> save<T extends Base>(T data) async {
    final box = _database(data);
    if (data.id == null) {
      data.id = await box?.add(data);
      await box?.put(data.id, data);
    } else {
      await box?.put(data.id, data);
    }
  }

  static Future<bool> exists(
      String tableName, String columnName, dynamic value) async {
    final box = _databaseByName(tableName);
    final exists =
        box?.values.firstWhere((e) => e.toMap()[columnName] == value);
    return exists != null;
  }

  static Future<void> delete(
      String table, bool Function(Base data) test) async {
    final box = _databaseByName(table);
    final waitDeletes = box?.values.where(test);
    if (waitDeletes.isNoneEmpty) {
      box?.deleteAll(waitDeletes!.map((d) => d.id).toList());
    }
  }

  static Future<void> update<T extends Base>(T data,
      [String idName = 'id']) async {
    assert(idName.isNotBlank);
    final box = _database(data);
    final first = box?.values.firstWhere((d) => d.toMap()[idName] == data.id);
    if (first != null) {
      box?.put(first.id, data);
    }
  }

  static Future<Iterable<Base>?> query(String table,
      Iterable<Base>? Function(Iterable<Base>? list) filter) async {
    final box = _databaseByName(table);
    return filter(box?.values.toList());
  }
}
