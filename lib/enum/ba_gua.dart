import 'package:meihua/enum/wu_xing.dart';

/// 八卦 - 值
/// 乾一,兑二,离三,震四,巽五,坎六,艮七,坤八
/// 乾三连，兑上缺，离中虚，震仰盂，巽下断，坎中满，艮覆碗，坤六断
enum BaGua {
  qian(1, '乾', WuXingZ.jin, '111'),
  dui(2, '兑', WuXingZ.jin, '011'),
  li(3, '离', WuXingZ.huo, '101'),
  zhen(4, '震', WuXingZ.mu, '001'),
  xun(5, '巽', WuXingZ.mu, '110'),
  kan(6, '坎', WuXingZ.shui, '010'),
  gen(7, '艮', WuXingZ.tu, '100'),
  kun(8, '坤', WuXingZ.tu, '000'),
  ;

  final int value;
  final String name;
  final WuXingZ wuXing;
  final String bin;
  const BaGua(this.value, this.name, this.wuXing, this.bin);

  static BaGua fromValue(int value) {
    if (value == 0) return BaGua.kun;
    for (var bg in BaGua.values) {
      if (value == bg.value) return bg;
    }
    throw UnsupportedError('错误的八卦值value');
  }

  static BaGua fromBin(String bin) {
    for (var bg in BaGua.values) {
      if (bin == bg.bin) return bg;
    }
    throw UnsupportedError('错误的八卦值bin');
  }
}
