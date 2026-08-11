import 'package:flutter/material.dart';

/// 爻：阴爻、阳爻
class Yao extends StatelessWidget {
  final bool yang;
  final Color froeground;
  final double spacing;

  const Yao(
    this.yang,
    this.froeground, {
    super.key,
    this.spacing = 10,
  });

  /// 暗黑模式下偏暗的爻色(水黑、土灰)提亮,保证在深色卦底上可见
  Color _barColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Color.lerp(froeground, Colors.white, .45)!;
    }
    return froeground;
  }

  @override
  Widget build(BuildContext context) {
    final color = _barColor(context);
    if (yang) {
      return Expanded(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Container(
            margin: EdgeInsets.all(spacing),
            color: color,
          )),
        ],
      ));
    } else {
      return Expanded(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Container(
            margin: EdgeInsets.all(spacing),
            color: color,
          )),
          Expanded(
              child: Container(
            margin: EdgeInsets.all(spacing),
            color: color,
          )),
        ],
      ));
    }
  }
}
