import 'package:flutter/widgets.dart';
import 'package:meihua/enum/ba_gua.dart';
import 'package:meihua/widget/ba_gua_xiang.dart';

/// 卦
class ChongGua extends StatelessWidget {
  final int shang, xia;
  final bool hu;
  final int? bian;
  final double spacing;

  const ChongGua(this.shang, this.xia,
      {super.key, this.hu = false, this.bian, this.spacing = 10});

  Widget _bianYao(int bian1) {
    final bian = 7 - bian1;
    final bianIndex = bian - 1;
    final bins = BaGua.fromValue(shang).bin + BaGua.fromValue(xia).bin;
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
            child: Gua(
          baGua: BaGua.fromBin(shang1),
          spacing: spacing,
        )),
        Expanded(
            child: Gua(
          baGua: BaGua.fromBin(xia1),
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
              child: Gua(
            baGua: BaGua.fromValue(shang),
            spacing: spacing,
          )),
          Expanded(
              child: Gua(
            baGua: BaGua.fromValue(xia),
            spacing: spacing,
          )),
        ],
      );
    } else if (hu) {
      final bins = BaGua.fromValue(shang).bin + BaGua.fromValue(xia).bin;
      final shang1 = bins.substring(1, 4);
      final xia1 = bins.substring(2, 5);
      return Column(
        children: [
          Expanded(
              child: Gua(
            baGua: BaGua.fromBin(shang1),
            spacing: spacing,
          )),
          Expanded(
              child: Gua(
            baGua: BaGua.fromBin(xia1),
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
