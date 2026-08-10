import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:meihua/entity/database/base.dart';
import 'package:meihua/entity/database/db_64gua.dart';
import 'package:meihua/entity/database/db_8gua.dart';
import 'package:meihua/entity/database/db_ai_chat.dart';
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
    Hive.box<DbAiChat>(DbAiChat.nameDb),
  );

  // ignore: non_constant_identifier_names
  final Box<Db8gua> _8guaBox;
  // ignore: non_constant_identifier_names
  final Box<Db64gua> _64guaBox;
  final Box<DbConfig> _configBox;
  final Box<DbHistory> _historyBox;
  final Box<DbHistorySync> _historySyncBox;
  final Box<DbAiChat> _aiChatBox;

  DbHelper._internal(this._8guaBox, this._64guaBox, this._configBox,
      this._historyBox, this._historySyncBox, this._aiChatBox);

  factory DbHelper() {
    return _instance;
  }

  static void initDataIfNeed() async {
    if (_instance._8guaBox.isEmpty) {
      // 读取 assets/_8gua_.json
      final json = await rootBundle.loadString('assets/_8gua_.json');
      final list = jsonDecode(json) as List<dynamic>;
      final data = list.map((e) => Db8gua()..fromMap(e)).toList();
      final putData = <dynamic, Db8gua>{};
      for (var d in data) {
        putData[d.id] = d;
      }
      await _instance._8guaBox.putAll(putData);
    }
    if (_instance._64guaBox.isEmpty) {
      // 读取 assets/_64gua_.json
      final json = await rootBundle.loadString('assets/_64gua_.json');
      final list = jsonDecode(json) as List<dynamic>;
      final data = list.map((e) => Db64gua()..fromMap(e)).toList();
      final putData = <dynamic, Db64gua>{};
      for (var d in data) {
        putData[d.id] = d;
      }
      await _instance._64guaBox.putAll(putData);
    }
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
    } else if (tableName == DbAiChat.nameDb) {
      return _instance._aiChatBox;
    }
    return null;
  }

  static Future<int?> save<T extends Base>(T data) async {
    final box = _database(data);
    if (data.id == null) {
      data.id = await box?.add(data);
      await box?.put(data.id, data);
    } else {
      await box?.put(data.id, data);
    }
    return data.id;
  }

  static Future<bool> exists(
      String tableName, String columnName, dynamic value) async {
    final box = _databaseByName(tableName);
    final exists =
        box?.values.firstWhereOrNull((e) => e.toMap()[columnName] == value);
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
      [String idName = 'id', dynamic idArg]) async {
    assert(idName.isNotBlank);
    final box = _database(data);
    final first = box?.values
        .firstWhereOrNull((d) => d.toMap()[idName] == (idArg ?? data.id));
    if (first != null) {
      // 按 idName/idArg 命中的可能是从快照重建的对象(id 为 null),
      // 写回前要保留原记录的 id,否则落盘后 id 丢失、后续按 id 查不到。
      data.id = first.id;
      await box?.put(first.id, data);
    }
  }

  static Future<Iterable<T>?> query<T extends Base>(String table,
      [Iterable<T>? Function(Iterable<T>? list)? filter]) async {
    final box = _databaseByName(table);
    if (filter != null) {
      if (box?.isNotEmpty != true) return filter([]);
      return filter(box!.values.toList() as List<T>);
    } else {
      if (box?.isNotEmpty != true) return [];
      return box!.values.toList() as List<T>;
    }
  }
}
