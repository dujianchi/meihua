import 'package:get/route_manager.dart';
import 'package:get/utils.dart';
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
  String or([String defalutStr = '']) {
    return this ?? defalutStr;
  }

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
