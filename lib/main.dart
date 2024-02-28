import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/enum/ba_gua.dart';
import 'package:meihua/pan.dart';
import 'package:meihua/widget/edit_text.dart';
import 'package:meihua/widget/lunar_clock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const _spacing = 10.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final editext1_1 = EditTextNum(label: '数字1'),
      editext2_1 = EditTextNum(label: '数字1'),
      editext2_2 = EditTextNum(label: '数字2'),
      editext3_1 = EditTextNum(label: '数字1'),
      editext3_2 = EditTextNum(label: '数字2'),
      editext3_3 = EditTextNum(label: '数字3');

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

    children.add(editext1_1);
    children.add(Tooltip(
      message: '比见有可数之物，即以此物起作上卦，以时数配作下卦即以卦数并时数，总除六，取动交。',
      child: ElevatedButton(
        onPressed: () => _calcNumber(1),
        child: const Text('以物数起卦'),
      ),
    ));

    children.add(editext2_1);
    children.add(editext2_2);
    children.add(Tooltip(
      message: '数1做上卦，数1+数2做下卦，取动爻',
      child: ElevatedButton(
        onPressed: () => _calcNumber(2),
        child: const Text('以2数起卦'),
      ),
    ));

    children.add(const Center(child: Text('乾一,兑二,离三,震四,巽五,坎六,艮七,坤八')));
    children.add(editext3_1);
    children.add(editext3_2);
    children.add(editext3_3);
    children.add(Tooltip(
      message: '数1做上卦，数2做下卦，数3做动爻',
      child: ElevatedButton(
        onPressed: () => _calcNumber(3),
        child: const Text('以3数起卦'),
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

  int _quyu(int zong, int yu) {
    final qu = zong % yu;
    return qu != 0 ? qu : yu;
  }

  void _showTipMaybe(String msg) {
    final context = _scaffoldKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 1),
      ));
    }
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

    final shang = _quyu(year + month + day, 8);
    final xia = _quyu(shang + hour, 8);
    final dong = _quyu(shang + hour, 6);

    debugPrint('shang = $shang, xia = $xia, dong = $dong');
    debugPrint(
        'shang = ${BaGua.fromValue(shang).name}, xia = ${BaGua.fromValue(xia).name}, dong = $dong');

    goPan(shang, xia, dong);
  }

  void _calcNumber(int numberCount) {
    if (numberCount == 1) {
      final num1Str = editext1_1.trim();
      if (num1Str.isEmpty) {
        _showTipMaybe('数字1不能为空');
        return;
      }
      final num1 = int.tryParse(num1Str);
      if (num1 == null) {
        _showTipMaybe('只能输入数字');
        return;
      }
      final lunar = Lunar.fromDate(DateTime.now());
      final hour = lunar.getTimeZhiIndex() + 1;
      final shang = _quyu(num1, 8);
      final zong = num1 + hour;
      final xia = _quyu(zong, 8);
      final dong = _quyu(zong, 6);
      goPan(shang, xia, dong);
    } else if (numberCount == 2) {
      final num1Str = editext2_1.trim();
      if (num1Str.isEmpty) {
        _showTipMaybe('数字1不能为空');
        return;
      }
      final num1 = int.tryParse(num1Str);
      if (num1 == null) {
        _showTipMaybe('数字1只能输入数字');
        return;
      }
      final num2Str = editext2_2.trim();
      if (num2Str.isEmpty) {
        _showTipMaybe('数字2不能为空');
        return;
      }
      final num2 = int.tryParse(num2Str);
      if (num2 == null) {
        _showTipMaybe('数字2只能输入数字');
        return;
      }
      final shang = _quyu(num1, 8);
      final zong = num1 + num2;
      final xia = _quyu(zong, 8);
      final dong = _quyu(zong, 6);
      goPan(shang, xia, dong);
    } else if (numberCount == 3) {
      final num1Str = editext3_1.trim();
      if (num1Str.isEmpty) {
        _showTipMaybe('数字1不能为空');
        return;
      }
      final num1 = int.tryParse(num1Str);
      if (num1 == null) {
        _showTipMaybe('数字1只能输入数字');
        return;
      }
      final num2Str = editext3_2.trim();
      if (num2Str.isEmpty) {
        _showTipMaybe('数字2不能为空');
        return;
      }
      final num2 = int.tryParse(num2Str);
      if (num2 == null) {
        _showTipMaybe('数字2只能输入数字');
        return;
      }

      final num3Str = editext3_3.trim();
      if (num3Str.isEmpty) {
        _showTipMaybe('数字3不能为空');
        return;
      }
      final num3 = int.tryParse(num3Str);
      if (num3 == null) {
        _showTipMaybe('数字3只能输入数字');
        return;
      }
      final shang = _quyu(num1, 8);
      final xia = _quyu(num2, 8);
      final dong = _quyu(num3, 6);
      goPan(shang, xia, dong);
    } else {
      throw UnsupportedError('错误的参数');
    }
  }
}
