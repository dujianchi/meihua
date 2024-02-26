import 'package:flutter/material.dart';
import 'package:meihua/entity/pan_yao.dart';
import 'package:meihua/widget/gua.dart';

class Pan extends StatelessWidget {
  const Pan({super.key});

  @override
  Widget build(BuildContext context) {
    PanYao? panYao = ModalRoute.of(context)?.settings.arguments as PanYao;
    return Scaffold(
      appBar: AppBar(title: const Text('梅花易数盘')),
      body: Row(
        children: [
          Expanded(
            child: Gua(
              panYao.shang,
              panYao.xia,
            ),
          ),
          Expanded(
              child: Gua(
            panYao.shang,
            panYao.xia,
            hu: true,
          ))
        ],
      ),
    );
  }
}
