import 'package:flutter/widgets.dart';
import 'package:meihua/enum/ba_gua_zhi.dart';
import 'package:meihua/widget/ba_gua_xiang.dart';

/// 卦
class Gua extends StatelessWidget {
  final int shang, xia;

  const Gua(this.shang, this.xia, {super.key});

  @override
  Widget build(BuildContext context) => const Column(
        children: [
          Expanded(
              child: BaGua(
            baGua: BaGuaZ.qian,
          )),
          Expanded(
              child: BaGua(
            baGua: BaGuaZ.li,
          )),
        ],
      );
}
