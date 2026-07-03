import 'package:meihua/entity/gua64.dart';
import 'package:meihua/enum/ba_gua.dart';
import 'package:meihua/widget/chong_gua.dart';

/// 易数：上爻、下爻、动爻
// @JsonCodable()
class Yi {
  final int shang, xia, dong;
  final String? historyDate;
  final int? historyId;
  Yi({
    required this.shang,
    required this.xia,
    required this.dong,
    this.historyDate,
    this.historyId,
  }) {
    assert(shang >= 1 && shang <= 8);
    assert(xia >= 1 && xia <= 8);
    assert(dong >= 1 && dong <= 6);
  }

  /// 返回：主卦、互卦、变卦
  List<Gua64> gua() {
    final zhu = Gua64(shang: BaGua.fromValue(shang), xia: BaGua.fromValue(xia));
    // 乾坤无互，互其变卦
    final bool huBian = (shang == xia && (shang == 1 || shang == 8));
    final Gua64 hu, bian = ChongGua.calcBian(shang, xia, dong);
    if (huBian) {
      hu = ChongGua.calcHu(bian.shang.value, bian.xia.value);
    } else {
      hu = ChongGua.calcHu(shang, xia);
    }
    return [zhu, hu, bian];
  }
}
