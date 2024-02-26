import 'package:meihua/enum/wu_xing.dart';

/// 八卦 - 值
/// 乾一,兑二,离三,震四,巽五,坎六,艮七,坤八
enum BaGuaZ {
  qian(1, '乾', WuXingZ.jin),
  dui(2, '兑', WuXingZ.jin),
  li(3, '离', WuXingZ.huo),
  zhen(4, '震', WuXingZ.mu),
  xun(5, '巽', WuXingZ.mu),
  kan(6, '坎', WuXingZ.shui),
  gen(7, '艮', WuXingZ.tu),
  kun(8, '坤', WuXingZ.tu),
  ;

  final int value;
  final String name;
  final WuXingZ wuXing;
  const BaGuaZ(this.value, this.name, this.wuXing);

  static BaGuaZ fromValue(int value) {
    if (value == 0) return BaGuaZ.kun;
    for (var bg in BaGuaZ.values) {
      if (value == bg.value) return bg;
    }
    throw UnsupportedError('错误的八卦值');
  }
}
