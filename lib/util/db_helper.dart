import 'package:lunar/lunar.dart';
import 'package:meihua/util/exts.dart';
import 'package:sqflite/sqflite.dart';

typedef DatabaseExec = Future<void> Function(Database db);
typedef StatementExec = Future<void> Function(Transaction txn);

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  DbHelper._internal();
  factory DbHelper() {
    return _instance;
  }
  static const dbName = 'pan_history';

  static Future<void> database(DatabaseExec exec) async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath/database.db';
    Database database = await openDatabase(
      path,
      version: 1,
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
      },
      onUpgrade: (db, oldVersion, newVersion) {},
    );
    await exec(database);
    await database.close();
  }

  static Future<void> transaction(StatementExec exec) async {
    await database((db) async {
      await db.transaction(
        (txn) async {
          await exec(txn);
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
}
