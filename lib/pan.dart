import 'package:flutter/material.dart';
import 'package:meihua/entity/pan_yao.dart';
import 'package:meihua/widget/gua.dart';

import 'widget/lunar_clock.dart';

class Pan extends StatelessWidget {
  static const double spacing = 5;
  const Pan({super.key});

  @override
  Widget build(BuildContext context) {
    PanYao? panYao = ModalRoute.of(context)?.settings.arguments as PanYao;
    return Scaffold(
      appBar: AppBar(title: const Text('梅花易数盘')),
      body: Column(
        children: [
          const LunarClock(),
          AspectRatio(
            aspectRatio: 1.2,
            child: Row(
              children: [
                Expanded(
                  child: Gua(
                    panYao.shang,
                    panYao.xia,
                    spacing: spacing,
                  ),
                ),
                Expanded(
                    child: Gua(
                  panYao.shang,
                  panYao.xia,
                  spacing: spacing,
                  hu: true,
                )),
                Expanded(
                    child: Gua(
                  panYao.shang,
                  panYao.xia,
                  spacing: spacing,
                  bian: panYao.dong,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
