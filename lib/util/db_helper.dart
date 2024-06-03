import 'package:lunar/lunar.dart';
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

  void database(DatabaseExec exec) async {
    var databasesPath = await getDatabasesPath();
    String path = '$databasesPath/database.db';
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
    database.close();
  }

  void transaction(StatementExec exec) async {
    database((db) async {
      await db.transaction(
        (txn) async {
          await exec(txn);
        },
      );
    });
  }

  void save({
    required int shang,
    required int xia,
    required int bian,
    required String title,
    int? saveDate,
    String? lunarDate,
    String? describe,
  }) {
    final now = DateTime.now();
    saveDate ??= now.millisecondsSinceEpoch;
    if (lunarDate == null) {
      final lunar = Lunar.fromDate(now);
      lunarDate =
          '${lunar.getYearGan()}${lunar.getYearZhi()}年 ${lunar.getMonthInChinese()}月 ${lunar.getDayInChinese()}日 ${lunar.getTimeZhi()}时 ${lunar.getSeason()}';
    }
    transaction((db) => db.insert(dbName, {
          'save_date': saveDate,
          'lunar_date': lunarDate,
          'shang': shang,
          'xia': xia,
          'bian': bian,
          'title': title,
          'describe': describe,
        }));
  }
}
