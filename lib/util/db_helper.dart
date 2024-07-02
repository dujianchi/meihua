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
  static const dbName = 'pan_history', dbNameConfig = "config";

  static Future<dynamic> database(DatabaseExec exec) async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath/database.db';
    Database database = await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute('''
CREATE TABLE $dbName (
	`id` INTEGER PRIMARY KEY AUTOINCREMENT,
	`save_date` INTEGER,
	`lunar_date` TEXT,
	`shang` INTEGER NOT NULL,
	`xia` INTEGER NOT NULL,
	`bian` INTEGER NOT NULL,
	`title` TEXT NOT NULL,
	`describe` TEXT
);
''');
        await db.execute('''
CREATE TABLE $dbNameConfig (
	`id` INTEGER PRIMARY KEY AUTOINCREMENT,
	`key` TEXT NOT NULL UNIQUE,
	`val` TEXT
);
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion == 1 && newVersion == 2) {
          await db.execute('''
CREATE TABLE $dbNameConfig (
	`id` INTEGER PRIMARY KEY AUTOINCREMENT,
	`key` TEXT NOT NULL UNIQUE,
	`val` TEXT
);
''');
        }
      },
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
}
