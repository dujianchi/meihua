import 'dart:io';

import 'package:flutter/services.dart';
import 'package:lunar/lunar.dart';
import 'package:meihua/util/exts.dart';
import 'package:sqflite/sqflite.dart';

typedef DatabaseExec = Future<dynamic> Function(Database db);
typedef StatementExec = Future<dynamic> Function(Transaction txn);

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  DbHelper._internal();
  factory DbHelper() {
    return _instance;
  }
  static const dbName = 'history', dbNameConfig = "config";

  static Future<dynamic> database(DatabaseExec exec) async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath/meihua.db';
    final dbFile = File(path);
    if (!dbFile.existsSync()) {
      final databaseBytes = await rootBundle.load('assets/meihua.db');
      await dbFile.writeAsBytes(databaseBytes.buffer.asInt8List());
    }
    path.log('database path = ');
    Database database = await openDatabase(
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

  static Future<void> save({
    required int shang,
    required int xia,
    required int bian,
    required String title,
    int? saveDate,
    String? lunarDate,
    String? describe,
  }) async {
    final now = DateTime.now();
    saveDate ??= now.millisecondsSinceEpoch;
    if (lunarDate == null) {
      final lunar = Lunar.fromDate(now);
      lunarDate = lunar.niceStr();
    }
    await transaction((db) async {
      await db.insert(dbName, {
        'save_date': saveDate,
        'lunar_date': lunarDate,
        'shang': shang,
        'xia': xia,
        'bian': bian,
        'title': title,
        'describe': describe,
      });
    });
  }

  static Future<void> update(int id, {String? title, String? describe}) async {
    if (title == describe && describe == null) return;
    final values = <String, dynamic>{};
    if (title != null) {
      values['title'] = title;
    }
    if (describe != null) {
      values['describe'] = describe;
    }
    await transaction((db) async {
      await db
          .update(DbHelper.dbName, values, where: "id = ?", whereArgs: [id]);
    });
  }

  static Future<void> saveConfig(Map<String, String> configs) async {
    await transaction((db) async {
      configs.forEach(
        (key, val) async {
          final exists = await db.query(dbNameConfig,
              where: 'key = ?', whereArgs: [key], limit: 1);
          if (exists.isEmpty) {
            await db.insert(dbNameConfig, {
              'key': key,
              'val': val,
            });
          } else {
            await db.update(dbNameConfig, {'key': key, 'val': val},
                where: 'id = ?', whereArgs: [exists.first['id']]);
          }
        },
      );
    });
  }

  static Future<void> deleteConfig(String key) async {
    await transaction((db) async {
      await db.delete(dbNameConfig, where: 'key = ?', whereArgs: [key]);
    });
  }

  static Future<String?> getConfig(String key) async {
    return await transaction((db) async {
      final exists = await db.query(dbNameConfig,
          where: 'key = ?', whereArgs: [key], limit: 1);
      return exists.isEmpty ? null : exists.first['val'];
    });
  }

  static Future<void> saveList(Iterable<dynamic>? cloudList) async {
    if (cloudList?.isNotEmpty == true) {
      await transaction((db) async {
        for (var item in cloudList!) {
          //final id = item['id'] as int;
          final saveDate = item['save_date'] as int?;
          final lunarDate = item['lunar_date'] as String?;
          final shang = item['shang'] as int;
          final xia = item['xia'] as int;
          final bian = item['bian'] as int;
          final title = item['title'] as String;
          final describe = item['describe'] as String?;
          db.insert(dbName, {
            'save_date': saveDate,
            'lunar_date': lunarDate,
            'shang': shang,
            'xia': xia,
            'bian': bian,
            'title': title,
            'describe': describe,
          });
        }
      });
    }
  }
}
