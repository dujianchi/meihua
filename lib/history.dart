import 'package:flutter/material.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('排盘历史'),
      ),
      body: _HistoryList(),
    );
  }
}

class _HistoryList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HistoryListState();
}

class _HistoryListState extends State<_HistoryList> {
  final historyList = [];

  @override
  void initState() {
    historyList.clear();
    DbHelper().transaction((db) async {
      final list = await db.query(DbHelper.dbName);
      setState(() {
        if (list.isNotEmpty) {
          historyList.addAll(list);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final item = historyList[index];
        /*
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
        */
        final id = item['id'] as int;
        final saveDate = item['save_date'] as int;
        final lunarDate = item['lunar_date'] as String;
        final shang = item['shang'] as int;
        final xia = item['xia'] as int;
        final bian = item['bian'] as int;
        final title = item['title'] as String;
        final describe = item['describe'] as String;
        return Column(
          children: [
            Text(title),
            Row(
              children: [
                Text('id:$id'),
                Text('上卦:${shang.baGua().name}'),
                Text('下卦:${xia.baGua().name}'),
                Text('变爻:${bian.yao()}'),
              ],
            ),
            Text('时间:${DateTime.fromMillisecondsSinceEpoch(saveDate)}'),
            Text('农历时间:$lunarDate'),
          ],
        );
      },
      itemCount: historyList.length,
    );
  }
}
