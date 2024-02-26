import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import 'package:meihua/enum/ba_gua_zhi.dart';
import 'package:meihua/widget/ba_gua_xiang.dart';
import 'package:meihua/widget/lunar_clock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const _spacing = 10.0;

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    children.add(const LunarClock());

    children.add(ElevatedButton(
      onPressed: _calcCurrentDatetime,
      child: const Text('以当下时辰起卦'),
    ));

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            '梅花易数排盘',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepPurpleAccent,
        ),
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

  void _calcCurrentDatetime() {
     final lunar = Lunar.fromDate(DateTime.now());
     Text(
      '${lunar.getYearGan()}${lunar.getYearZhi()}年 ${lunar.getMonthInChinese()}月 ${lunar.getDayInChinese()}日 ${lunar.getTimeZhi()}时',
      // style: const TextStyle(fontSize: 20.0),
    );
  }
}
