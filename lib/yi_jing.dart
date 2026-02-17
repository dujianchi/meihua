import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:meihua/entity/database/db_64gua.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';

class YiJing extends StatefulWidget {
  const YiJing({super.key});

  @override
  State<StatefulWidget> createState() => _StateYiJing();
}

class _StateYiJing extends State<YiJing> {
  final _list = <Db64gua>[];
  final _ctrl = TextEditingController();

  @override
  void initState() {
    _loadData(null);
    super.initState();
  }

  void _loadData(String? keyword) async {
    final List<Map<String, dynamic>> list;
    if (keyword.isNotBlank) {
      list = (await DbHelper.query(
                  Db64gua.nameDb,
                  (ls) => ls?.where((t) =>
                      t.toMap()['full_name'].toString().contains(keyword!))))
              ?.map((t) => t.toMap())
              .toList() ??
          [];
    } else {
      list = (await DbHelper.query(Db64gua.nameDb, (ls) => ls))
              ?.map((t) => t.toMap())
              .toList() ??
          [];
    }
    _list.clear();
    _list.addAll(list.map((map) => Db64gua()..fromMap(map)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('易经原文'),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _list.length + 1,
          itemBuilder: (ctx, idx) {
            if (idx == 0) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _ctrl,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    value.log();
                    _loadData(value);
                  },
                  decoration: const InputDecoration(hintText: '搜索关键字'),
                ),
              );
            } else {
              final index = idx - 1;
              return ListTile(
                title: Text('第${_list[index].id}卦 ${_list[index].fullName!}'),
                onTap: () {
                  Get.to(YiJingDetail(db64gua: _list[index]));
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class YiJingDetail extends StatelessWidget {
  final Db64gua db64gua;

  const YiJingDetail({super.key, required this.db64gua});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(db64gua.fullName!),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SelectableText.rich(TextSpan(children: [
            TextSpan(
                text:
                    '第${db64gua.id}卦 ${db64gua.name}卦，${db64gua.fullName}，上${db64gua.shang}下${db64gua.xia}\n\n',
                style: const TextStyle(color: Colors.blueGrey, fontSize: 18)),
            db64gua.toText(fontSize: 17),
          ])),
        ),
      );
}
