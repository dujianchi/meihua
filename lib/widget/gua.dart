import 'package:flutter/widgets.dart';
import 'package:meihua/enum/ba_gua_zhi.dart';
import 'package:meihua/widget/ba_gua_xiang.dart';

/// 卦
class Gua extends StatelessWidget {
  final int shang, xia;
  final bool hu;
  final int? bian;
  final double spacing;

  const Gua(this.shang, this.xia,
      {super.key, this.hu = false, this.bian, this.spacing = 10});

  Widget _bianYao(int bian1) {
    final bian = 7 - bian1;
    final bianIndex = bian - 1;
    final bins = BaGuaZ.fromValue(shang).bin + BaGuaZ.fromValue(xia).bin;
    final bianStr = bins[bianIndex];
    final String b;
    if (bianStr == '1') {
      b = bins.replaceRange(bianIndex, bian, '0');
    } else {
      b = bins.replaceRange(bianIndex, bian, '1');
    }
    final shang1 = b.substring(0, 3);
    final xia1 = b.substring(3, 6);
    return Column(
      children: [
        Expanded(
            child: BaGua(
          baGua: BaGuaZ.fromBin(shang1),
          spacing: spacing,
        )),
        Expanded(
            child: BaGua(
          baGua: BaGuaZ.fromBin(xia1),
          spacing: spacing,
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!hu && bian == null) {
      return Column(
        children: [
          Expanded(
              child: BaGua(
            baGua: BaGuaZ.fromValue(shang),
            spacing: spacing,
          )),
          Expanded(
              child: BaGua(
            baGua: BaGuaZ.fromValue(xia),
            spacing: spacing,
          )),
        ],
      );
    } else if (hu) {
      final bins = BaGuaZ.fromValue(shang).bin + BaGuaZ.fromValue(xia).bin;
      final shang1 = bins.substring(1, 4);
      final xia1 = bins.substring(2, 5);
      return Column(
        children: [
          Expanded(
              child: BaGua(
            baGua: BaGuaZ.fromBin(shang1),
            spacing: spacing,
          )),
          Expanded(
              child: BaGua(
            baGua: BaGuaZ.fromBin(xia1),
            spacing: spacing,
          )),
        ],
      );
    } else if (bian != null) {
      return _bianYao(bian!);
    } else {
      return SizedBox.shrink();
    }
  }
}
