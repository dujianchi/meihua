import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:meihua/entity/database/db_64gua.dart';
import 'package:meihua/util/db_helper.dart';

class YiJing extends StatefulWidget {
  const YiJing({super.key});

  @override
  State<StatefulWidget> createState() => _StateYiJing();
}

class _StateYiJing extends State<YiJing> {
  final _list = <Db64gua>[];

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData() async {
    final list = await DbHelper.query(Db64gua.nameDb);
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
      body: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (ctx, index) => ListTile(
          title: Text('第${_list[index].id}卦 ${_list[index].fullName!}'),
          onTap: () {
            Get.to(YiJingDetail(db64gua: _list[index]));
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
