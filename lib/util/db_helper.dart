import 'dart:io';

import 'package:flutter/services.dart';
import 'package:meihua/entity/database/base.dart';
import 'package:meihua/util/exts.dart';
import 'package:sqflite/sqflite.dart' as mobile;
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as desktop;

typedef DatabaseExec = Future<dynamic> Function(Database db);
typedef StatementExec = Future<dynamic> Function(Transaction txn);

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static bool get isUseMobile =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  DbHelper._internal() {
    if (!isUseMobile) {
      desktop.sqfliteFfiInit();
    }
  }
  factory DbHelper() {
    return _instance;
  }

  static Future<dynamic> database(DatabaseExec exec) async {
    if (!isUseMobile) {
      databaseFactory = desktop.databaseFactoryFfi;
    } else {
      databaseFactory = mobile.databaseFactory;
    }
    final databasesPath = isUseMobile
        ? await mobile.getDatabasesPath()
        : await desktop.getDatabasesPath();
    final path = '$databasesPath${Platform.pathSeparator}meihua.db';
    final dbFile = File(path);
    if (!dbFile.existsSync()) {
      final dbDir = Directory(databasesPath);
      if (!dbDir.existsSync()) {
        dbDir.createSync(recursive: true);
      }
      final databaseBytes = await rootBundle.load('assets/meihua.db');
      await dbFile.writeAsBytes(databaseBytes.buffer.asInt8List());
    }
    path.log('database path = ');
    Database database = isUseMobile
        ? await mobile.openDatabase(
            path,
            version: 1,
            onCreate: (Database db, int version) async {},
            onUpgrade: (db, oldVersion, newVersion) async {},
          )
        : await desktop.openDatabase(
            path,
            version: 1,
            onCreate: (Database db, int version) async {},
            onUpgrade: (db, oldVersion, newVersion) async {},
          );
    final execResult = await exec(database);
    await database.close();
    return execResult;
  }

  static Future<dynamic> transaction(StatementExec exec) async {
    return await database((db) async {
      return await db.transaction(
        (txn) async {
          return await exec(txn);
        },
      );
    });
  }

  static Future<void> save<T extends Base>(T data) async {
    await transaction((db) async {
      await db.insert(data.dbName, data.toMap());
    });
  }

  static Future<void> delete(String table,
      {String? where, List<Object?>? whereArgs}) async {
    await transaction((db) async {
      await db.delete(table, where: where, whereArgs: whereArgs);
    });
  }

  static Future<void> update<T extends Base>(T data,
      [String idName = 'id']) async {
    assert(idName.isNotBlank);
    await transaction((db) async {
      final map = data.toMap();
      final id = map.remove(idName);
      await db.update(data.dbName, map, where: "$idName = ?", whereArgs: [id]);
    });
  }

  static Future<List<Map<String, Object?>>> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    return await transaction((db) async {
      final list = await db.query(table,
          distinct: distinct,
          columns: columns,
          where: where,
          whereArgs: whereArgs,
          groupBy: groupBy,
          having: having,
          orderBy: orderBy,
          limit: limit,
          offset: offset);
      return list;
    });
  }
}
