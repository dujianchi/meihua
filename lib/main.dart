import 'package:flutter/material.dart';
import 'package:meihua/enum/ba_gua_zhi.dart';
import 'package:meihua/widget/ba_gua_xiang.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const _spacing = 10.0;

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    children.add(Text('data'));

    children.add(ElevatedButton(
      child: const Text('确定'),
      onPressed: () {},
    ));

    return MaterialApp(
      title: '梅花易数',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: ListView.separated(
            padding: const EdgeInsets.all(_spacing),
            itemBuilder: (conntext, index) => children[index],
            separatorBuilder: (conntext, index) => const SizedBox(
                  height: _spacing,
                ),
            itemCount: children.length),
      ),
    );
  }
}
