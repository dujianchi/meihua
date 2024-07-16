import 'package:flutter/material.dart';
import 'package:meihua/entity/database/db_8gua.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';

class LeiXiang extends StatefulWidget {
  const LeiXiang({super.key});

  @override
  State<StatefulWidget> createState() => _StateLeiXiang();
}

class _StateLeiXiang extends State<LeiXiang> {
  final _bagua = <Db8gua>[];
  final _ctrl = TextEditingController();
  static const _padding = EdgeInsets.all(10);
  String? _keyword;

  @override
  void initState() {
    _loadData(null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('八卦万物类象'),
      ),
      body: ListView.builder(
        itemBuilder: (ctx, index) {
          if (index == 0) {
            return Padding(
              padding: _padding,
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
            final gua8 = _bagua[index - 1];
            final text = '''${gua8.shuLei}
            
${gua8.leiXiang}''';
            final children = [
              TextSpan(
                  text: '${gua8.name} ',
                  style: const TextStyle(fontSize: 18, color: Colors.redAccent))
            ];
            if (_keyword.isBlank) {
              children.add(TextSpan(text: text));
            } else {
              final texts = text.split(_keyword!);
              for (var index = 0; index < texts.length - 1; index++) {
                children.add(TextSpan(text: texts[index]));
                children.add(TextSpan(
                    text: _keyword,
                    style: const TextStyle(color: Colors.blueAccent)));
              }
              children.add(TextSpan(text: texts.last));
            }
            return Padding(
              padding: _padding,
              child: SelectableText.rich(TextSpan(children: children)),
            );
          }
        },
        itemCount: _bagua.length + 1,
      ),
    );
  }

  void _loadData(String? keyword) async {
    _keyword = keyword;
    final List<Map<String, dynamic>> list;
    if (keyword.isNotBlank) {
      final kw = '%$keyword%';
      final args = [kw, kw];
      list = await DbHelper.query(Db8gua.nameDb,
          where: 'shu_lei like ? or lei_xiang like ?', whereArgs: args);
    } else {
      list = await DbHelper.query(Db8gua.nameDb);
    }
    _bagua.clear();
    _bagua.addAll(list.map((m) => Db8gua()..fromMap(m)));
    setState(() {});
  }
}
