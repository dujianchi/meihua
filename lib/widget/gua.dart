import 'package:flutter/widgets.dart';
import 'package:meihua/enum/ba_gua_zhi.dart';
import 'package:meihua/widget/ba_gua_xiang.dart';

/// 卦
class Gua extends StatelessWidget {
  final int shang, xia;
  final bool hu;
  final int? bian;

  const Gua(this.shang, this.xia, {super.key, this.hu = false, this.bian});

  @override
  Widget build(BuildContext context) {
    if (!hu && bian == null) {
      return Column(
        children: [
          Expanded(
              child: BaGua(
            baGua: BaGuaZ.fromValue(shang),
          )),
          Expanded(
              child: BaGua(
            baGua: BaGuaZ.fromValue(xia),
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
          )),
          Expanded(
              child: BaGua(
            baGua: BaGuaZ.fromBin(xia1),
          )),
        ],
      );
    } else if (bian != null) {
      return SizedBox.shrink();
    } else {
      return SizedBox.shrink();
    }
  }
}
