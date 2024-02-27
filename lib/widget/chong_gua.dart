import 'package:flutter/material.dart';
import 'package:meihua/entity/gua64.dart';
import 'package:meihua/enum/ba_gua.dart';
import 'package:meihua/util/consts.dart';
import 'package:meihua/widget/gua.dart';

/// 重卦，主卦、互卦、变卦
class ChongGua extends StatelessWidget {
  final int shang, xia;
  final bool hu;
  final int? bian;
  final double spacing;

  const ChongGua(this.shang, this.xia,
      {super.key, this.hu = false, this.bian, this.spacing = 10});

  Gua64? gua() {
    if (!hu && bian == null) {
      return Gua64(shang: BaGua.fromValue(shang), xia: BaGua.fromValue(xia));
    } else if (hu) {
      final bins = BaGua.fromValue(shang).bin + BaGua.fromValue(xia).bin;
      final shang1 = bins.substring(1, 4);
      final xia1 = bins.substring(2, 5);
      return Gua64(shang: BaGua.fromBin(shang1), xia: BaGua.fromBin(xia1));
    } else if (bian != null) {
      final bianFan = 7 - bian!;
      final bianIndex = bianFan - 1;
      final bins = BaGua.fromValue(shang).bin + BaGua.fromValue(xia).bin;
      final bianStr = bins[bianIndex];
      final String b;
      if (bianStr == '1') {
        b = bins.replaceRange(bianIndex, bianFan, '0');
      } else {
        b = bins.replaceRange(bianIndex, bianFan, '1');
      }
      final shang1 = b.substring(0, 3);
      final xia1 = b.substring(3, 6);
      return Gua64(shang: BaGua.fromBin(shang1), xia: BaGua.fromBin(xia1));
    } else {
      return null;
    }
  }

  Widget _yaoWidget(Gua64 gua64) {
    final name = gua64.name();
    debugPrint('name = $name');
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
                child: Gua(
              baGua: gua64.shang,
              spacing: spacing,
            )),
            Expanded(
                child: Gua(
              baGua: gua64.xia,
              spacing: spacing,
            )),
          ],
        ),
        Center(
          child: Tooltip(
            message: Consts.chongGuaStr[name],
            child: Text(name),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gua64 = gua();
    if (gua64 != null) {
      return _yaoWidget(gua64);
    } else {
      return const SizedBox.shrink();
    }
  }
}
