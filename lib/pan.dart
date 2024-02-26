import 'package:flutter/material.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/widget/chong_gua.dart';

import 'widget/lunar_clock.dart';

class Pan extends StatelessWidget {
  static const double spacing = 5;
  const Pan({super.key});

  @override
  Widget build(BuildContext context) {
    Yi? panYao = ModalRoute.of(context)?.settings.arguments as Yi;
    return Scaffold(
      appBar: AppBar(title: const Text('梅花易数盘')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const LunarClock(),
            AspectRatio(
              aspectRatio: 1.2,
              child: Row(
                children: [
                  Expanded(
                    child: ChongGua(
                      panYao.shang,
                      panYao.xia,
                      spacing: spacing,
                    ),
                  ),
                  Expanded(
                      child: ChongGua(
                    panYao.shang,
                    panYao.xia,
                    spacing: spacing,
                    hu: true,
                  )),
                  Expanded(
                      child: ChongGua(
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
      ),
    );
  }
}
