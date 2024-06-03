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
