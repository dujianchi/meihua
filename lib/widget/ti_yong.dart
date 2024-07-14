import 'package:flutter/material.dart';

class TiYong extends StatelessWidget {
  final int dong;

  const TiYong({super.key, required this.dong});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(child: Center(child: Text(dong > 3 ? '用' : '体'))),
          Expanded(child: Center(child: Text(dong > 3 ? '体' : '用'))),
        ],
      );
}
