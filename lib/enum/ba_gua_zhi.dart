import 'package:meihua/enum/wu_xing.dart';

/// 八卦 - 值
/// 乾一,兑二,离三,震四,巽五,坎六,艮七,坤八
enum BaGuaZ {
  qian(1, WuXingZ.jin),
  dui(2, WuXingZ.jin),
  li(3, WuXingZ.huo),
  zhen(4, WuXingZ.mu),
  xun(5, WuXingZ.mu),
  kan(6, WuXingZ.shui),
  gen(7, WuXingZ.tu),
  kun(8, WuXingZ.tu),
  ;

  final int value;
  final WuXingZ wuXing;
  const BaGuaZ(this.value, this.wuXing);
}
