import 'package:get/route_manager.dart';
import 'package:get/utils.dart';
import 'package:lunar/lunar.dart';
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
}

extension LunarExt on Lunar {
  /// 当前时间的农历格式化
  String niceStr() =>
      '${getYearGan()}${getYearZhi()}年 ${getMonthInChinese()}月 ${getDayInChinese()}日 ${getTimeZhi()}时 ${getSeason()}';
}
