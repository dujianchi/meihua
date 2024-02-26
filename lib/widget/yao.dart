import 'package:flutter/widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    if (yang) {
      return Expanded(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Container(
            margin: EdgeInsets.all(spacing),
            color: froeground,
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
            color: froeground,
          )),
          Expanded(
              child: Container(
            margin: EdgeInsets.all(spacing),
            color: froeground,
          )),
        ],
      ));
    }
  }
}
