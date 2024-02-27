import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/enum/ba_gua.dart';
import 'package:meihua/pan.dart';
import 'package:meihua/widget/lunar_clock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const _spacing = 10.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    children.add(const Text(
      '不(发生变)动不占，不因(有)事不占',
      style: TextStyle(color: Colors.redAccent),
    ));

    children.add(const LunarClock());

    children.add(Tooltip(
      message:
          '年、月、日为上卦，年、月、日加时总为下卦。又以年、月、日、时总数取爻。如子年一数，丑年二数，直至亥年十二数。月如正月一数，直至十二月亦作十二数。日数，如初一一数，直至三十日为三十数。以上年、月、日，共计几数，以八除之，以零数作上卦。时如子时一数，直至亥时为十二数。就将年、月、日数总计几数，以八除之，零数作下卦，就以除六数作动爻。',
      child: ElevatedButton(
        onPressed: _calcCurrentDatetime,
        child: const Text('以当下时辰起卦'),
      ),
    ));

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        'pan': (context) => const Pan(),
      },
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: const Text('梅花易数排盘')),
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

  void goPan(int shang, int xia, int dong) {
    Navigator.of(_scaffoldKey.currentContext!).pushNamed('pan',
        arguments: Yi(
            shang: shang == 0 ? 8 : shang,
            xia: xia == 0 ? 8 : xia,
            dong: dong == 0 ? 6 : dong));
  }

  void _calcCurrentDatetime() {
    final lunar = Lunar.fromDate(DateTime.now());
    Text(
      '${lunar.getYearGan()}${lunar.getYearZhi()}年 ${lunar.getMonthInChinese()}月 ${lunar.getDayInChinese()}日 ${lunar.getTimeZhi()}时',
      // style: const TextStyle(fontSize: 20.0),
    );
    final year = lunar.getYearZhiIndex() + 1,
        month = lunar.getMonth().abs(),
        day = lunar.getDay(),
        hour = lunar.getTimeZhiIndex() + 1;

    debugPrint('year = $year, month = $month, day = $day, hour = $hour');

    final shang = (year + month + day) % 8;
    final xia = (shang + hour) % 8;
    final dong = (shang + hour) % 6;

    debugPrint('shang = $shang, xia = $xia, dong = $dong');
    debugPrint(
        'shang = ${BaGua.fromValue(shang).name}, xia = ${BaGua.fromValue(xia).name}, dong = $dong');

    goPan(shang, xia, dong);
  }
}
