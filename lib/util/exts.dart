import 'dart:convert';

import 'package:crypto/crypto.dart' as c;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/utils.dart';
import 'package:lunar/lunar.dart';
import 'package:meihua/entity/database/base.dart';
import 'package:meihua/enum/ba_gua.dart';

extension IntExt on int {
  // 卦数取余
  int yu(int yu) {
    final qu = this % yu;
    return qu != 0 ? qu : yu;
  }

  // 取卦数
  int gua() {
    return yu(8);
  }

  // 取爻数
  int yao() {
    return yu(6);
  }

  // 转换为八个卦名
  BaGua baGua() {
    final g = gua();
    return BaGua.fromValue(g);
  }
}

extension IntExtNullable on int? {
  DateTime? date() {
    if (this != null) {
      return DateTime.fromMillisecondsSinceEpoch(this!);
    } else {
      return null;
    }
  }

  String dateStr() {
    return date()?.toString() ?? '';
  }
}

String _hex(List<int> bytes) {
  final buffer = StringBuffer();
  for (final byte in bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

extension StringExtNullable on String? {
  /// 字符串为null处理
  String or([String defalutStr = '']) {
    return this ?? defalutStr;
  }

  /// toast一个字符串
  void toast([int duration = 2]) async {
    if (this?.isNotEmpty == true) {
      if (SnackbarController.isSnackbarBeingShown) {
        try {
          await SnackbarController.closeCurrentSnackbar();
        } catch (e) {
          e.printError();
        }
      }
      Get.showSnackbar(GetSnackBar(
        message: this,
        duration: Duration(seconds: duration),
      ));
    }
  }

  String? md5() {
    if (this == null) return null;
    final bytes = c.md5.convert(utf8.encode(this!)).bytes;
    return _hex(bytes);
  }

  Map<String, dynamic> jsonToMap() {
    if (this?.isNotEmpty == true) {
      return jsonDecode(this!);
    } else {
      return const {};
    }
  }

  int toInt([int defVal = 0]) {
    if (isBlank) return defVal;
    return int.tryParse(this!) ?? defVal;
  }

  bool get isBlank => this == null || this!.isEmpty || this!.trim().isEmpty;
  bool get isNotBlank => !isBlank;

  void confirmDialog(Future<dynamic> Function() onPressed,
      {String? title, String? cancel, String? confirm}) {
    if (isBlank) return;
    Get.generalDialog(
      pageBuilder: (context, animation1, animation2) => AlertDialog(
        title: Text(this!),
        content: Visibility(visible: title.isNotBlank, child: Text('$title')),
        actions: [
          TextButton(
            onPressed: () {
              Get.until((route) => Get.isDialogOpen != true);
            },
            child: Text(cancel.isNotBlank ? cancel! : '取消'),
          ),
          TextButton(
            onPressed: () async {
              await onPressed();
              Get.until((route) => Get.isDialogOpen != true);
            },
            child: Text(confirm.isNotBlank ? confirm! : '确定'),
          ),
        ],
        scrollable: true,
      ),
    );
  }

  DateTime toDatetimeOrNow() =>
      this == null ? DateTime.now() : DateTime.parse(this!);
}

extension DatetimeExt on DateTime {
  Lunar toLunar() => Lunar.fromDate(this);
}

extension LunarExt on Lunar {
  /// 当前时间的农历格式化
  String niceStr() =>
      '${getYearGan()}${getYearZhi()}年 ${getMonthInChinese()}月 ${getDayInChinese()}日 ${getTimeZhi()}时 $seasion';

  String get seasion {
    final now = getSolar();
    final jieqiTable = getJieQiTable();
    final dong = jieqiTable['立冬'];
    if (dong?.isBefore(now) == true) return '冬';
    final qiu = jieqiTable['立秋'];
    if (qiu?.isBefore(now) == true) return '秋';
    final xia = jieqiTable['立夏'];
    if (xia?.isBefore(now) == true) return '夏';
    final chun = jieqiTable['立春'];
    if (chun?.isBefore(now) == true) return '春';
    return '冬';
  }
}

extension DynamicExt on dynamic {
  void log([prefix]) {
    if (kDebugMode) {
      debugPrint('${prefix ?? ''}${this?.toString()}');
    }
  }

  String? toJson() {
    if (this == null) return null;
    return jsonEncode(this);
  }
}

extension IterableExt<E> on Iterable<E>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNoneEmpty => !isNullOrEmpty;

  E? firstWhereOrNull(bool Function(E element) test, {E Function()? orElse}) {
    final this_ = this;
    if (this_ == null || this_.isEmpty) return null;
    for (E element in this_) {
      if (test(element)) return element;
    }
    return orElse == null ? null : orElse();
  }
}

extension BaseExt on Base? {
  List<Base> get toList {
    final list = <Base>[];
    if (this != null) {
      list.add(this!);
    }
    return list;
  }
}
