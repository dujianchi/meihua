import 'dart:math';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/enum/ba_gua.dart';
import 'package:meihua/history.dart';
import 'package:meihua/lei_xiang.dart';
import 'package:meihua/pan.dart';
import 'package:meihua/util/exts.dart';
import 'package:meihua/widget/edit_text.dart';
import 'package:meihua/widget/lunar_clock.dart';
import 'package:meihua/yi_jing.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const _spacing = 8.0;
  final editext1_1 = EditTextNum(
        label: '数字1',
        focusNode: FocusNode(),
        selectAllAfterRequestedFocus: true,
      ),
      editext2_1 = EditTextNum(
        label: '数字1',
        focusNode: FocusNode(),
        selectAllAfterRequestedFocus: true,
      ),
      editext2_2 = EditTextNum(
        label: '数字2',
        focusNode: FocusNode(),
        selectAllAfterRequestedFocus: true,
      ),
      editext3_1 = EditTextNum(
        label: '上卦数字',
        focusNode: FocusNode(),
        selectAllAfterRequestedFocus: true,
      ),
      editext3_2 = EditTextNum(
        label: '下卦数字',
        focusNode: FocusNode(),
        selectAllAfterRequestedFocus: true,
      ),
      editext3_3 = EditTextNum(
        label: '变爻数字',
        focusNode: FocusNode(),
        selectAllAfterRequestedFocus: true,
      );

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
        onPressed: () => _calcCurrentDatetime(DateTime.now()),
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

    children.add(Center(
        child: SelectableText.rich(TextSpan(children: [
      // 乾一,兑二,离三,震四,巽五,坎六,艮七,坤八
      TextSpan(
          text: '☰${BaGua.qian.name}一 ',
          style: TextStyle(
            color: BaGua.qian.wuXing.color,
          )),
      TextSpan(
          text: '☱${BaGua.dui.name}二 ',
          style: TextStyle(
            color: BaGua.dui.wuXing.color,
          )),
      TextSpan(
          text: '☲${BaGua.li.name}三 ',
          style: TextStyle(color: BaGua.li.wuXing.color)),
      TextSpan(
          text: '☳${BaGua.zhen.name}四 ',
          style: TextStyle(
            color: BaGua.zhen.wuXing.color,
          )),
      TextSpan(
          text: '☴${BaGua.xun.name}五 ',
          style: TextStyle(
            color: BaGua.xun.wuXing.color,
          )),
      TextSpan(
          text: '☵${BaGua.kan.name}六 ',
          style: TextStyle(
            color: BaGua.kan.wuXing.color,
          )),
      TextSpan(
          text: '☶${BaGua.gen.name}七 ',
          style: TextStyle(
            color: BaGua.gen.wuXing.color,
          )),
      TextSpan(
          text: '☷${BaGua.kun.name}八 ',
          style: TextStyle(
            color: BaGua.kun.wuXing.color,
          )),
    ]))));
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

    children.add(Tooltip(
      message: '以随机数起卦',
      child: ElevatedButton(
        onPressed: () => _calcNumber(0),
        child: const Text('随机起卦'),
      ),
    ));

    children.add(ElevatedButton(
      onPressed: () => _calcNumber(4),
      child: const Text('选择指定日期起卦'),
    ));

    return GetMaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        'pan': (context) => const Pan(),
        'yi': (context) => const YiJing(),
        'lx': (context) => const LeiXiang(),
        'ls': (context) => const History(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text('梅花易数排盘'),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 0, child: Text('易经原文')),
                const PopupMenuItem(value: 1, child: Text('八卦类象')),
                const PopupMenuItem(value: 2, child: Text('排盘历史')),
              ],
              onSelected: (value) => _actionSelected(value),
            )
          ],
        ),
        body: SafeArea(
          child: ListView.separated(
              padding: const EdgeInsets.all(_spacing),
              itemBuilder: (conntext, index) => children[index],
              separatorBuilder: (conntext, index) => const SizedBox(
                    height: _spacing,
                  ),
              itemCount: children.length),
        ),
      ),
    );
  }

  void goPan(int shang, int xia, int dong) {
    Get.toNamed('pan',
        arguments: Yi(
            shang: shang == 0 ? 8 : shang,
            xia: xia == 0 ? 8 : xia,
            dong: dong == 0 ? 6 : dong));
  }

  void _actionSelected(int value) {
    'value = $value'.log();
    switch (value) {
      case 0:
        Get.toNamed('yi');
        break;
      case 1:
        Get.toNamed('lx');
        break;
      case 2:
        Get.toNamed('ls');
        break;
      default:
        break;
    }
  }

  void _calcCurrentDatetime(DateTime datetime) {
    final lunar = datetime.toLunar();
    final year = lunar.getYearZhiIndex() + 1,
        month = lunar.getMonth().abs(),
        day = lunar.getDay(),
        hour = lunar.getTimeZhiIndex() + 1;

    'year = $year, month = $month, day = $day, hour = $hour'.log();

    final shang = (year + month + day).gua();
    final xia = (shang + hour).gua();
    final dong = (shang + hour).yao();

    'shang = $shang, xia = $xia, dong = $dong'.log();
    'shang = ${BaGua.fromValue(shang).name}, xia = ${BaGua.fromValue(xia).name}, dong = $dong'
        .log();

    goPan(shang, xia, dong);
  }

  /// 1 = 一数起卦
  /// 2 = 二数起卦
  /// 3 = 三数起卦
  /// 0 = 随机起卦
  /// 4 = 选择指定日期起卦
  void _calcNumber(int numberCount) async {
    if (numberCount == 1) {
      final num1Str = editext1_1.trim();
      if (num1Str.isEmpty) {
        '数字1不能为空'.toast();
        return;
      }
      final num1 = int.tryParse(num1Str);
      if (num1 == null) {
        '只能输入数字'.toast();
        return;
      }
      final lunar = DateTime.now().toLunar();
      final hour = lunar.getTimeZhiIndex() + 1;
      final shang = num1.gua();
      final zong = num1 + hour;
      final xia = zong.gua();
      final dong = zong.yao();
      goPan(shang, xia, dong);
    } else if (numberCount == 2) {
      final num1Str = editext2_1.trim();
      if (num1Str.isEmpty) {
        '数字1不能为空'.toast();
        return;
      }
      final num1 = int.tryParse(num1Str);
      if (num1 == null) {
        '数字1只能输入数字'.toast();
        return;
      }
      final num2Str = editext2_2.trim();
      if (num2Str.isEmpty) {
        '数字2不能为空'.toast();
        return;
      }
      final num2 = int.tryParse(num2Str);
      if (num2 == null) {
        '数字2只能输入数字'.toast();
        return;
      }
      final shang = num1.gua();
      final zong = num1 + num2;
      final xia = zong.gua();
      final dong = zong.yao();
      goPan(shang, xia, dong);
    } else if (numberCount == 3) {
      final num1Str = editext3_1.trim();
      if (num1Str.isEmpty) {
        '上卦数字不能为空'.toast();
        return;
      }
      final num1 = int.tryParse(num1Str);
      if (num1 == null) {
        '下卦数字只能输入数字'.toast();
        return;
      }
      final num2Str = editext3_2.trim();
      if (num2Str.isEmpty) {
        '下卦数字不能为空'.toast();
        return;
      }
      final num2 = int.tryParse(num2Str);
      if (num2 == null) {
        '下卦数字只能输入数字'.toast();
        return;
      }

      final num3Str = editext3_3.trim();
      if (num3Str.isEmpty) {
        '变爻数字不能为空'.toast();
        return;
      }
      final num3 = int.tryParse(num3Str);
      if (num3 == null) {
        '变爻数字只能输入数字'.toast();
        return;
      }
      final shang = num1.gua();
      final xia = num2.gua();
      final dong = num3.yao();
      goPan(shang, xia, dong);
    } else if (numberCount == 0) {
      final random = Random();
      final num1 = 100 + random.nextInt(100),
          num2 = 100 + random.nextInt(100),
          num3 = 100 + random.nextInt(100);
      final shang = num1.gua();
      final xia = num2.gua();
      final dong = num3.yao();
      '随机：上卦$shang，下卦$xia，$dong爻动'.toast(10);
      goPan(shang, xia, dong);
    } else if (numberCount == 4) {
      final result = await showBoardDateTimePicker(
        context: Get.context!,
        pickerType: DateTimePickerType.datetime,
      );
      if (result != null) {
        result.log('selected time = ');
        _calcCurrentDatetime(result);
      }
    } else {
      throw UnsupportedError('错误的参数');
    }
  }
}
