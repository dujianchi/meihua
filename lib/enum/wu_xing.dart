import 'package:flutter/material.dart';

/// 五行 - 值
/// 金木水火土
enum WuXingZ {
  jin('金', Colors.yellow),
  mu('木', Colors.green),
  shui('水', Colors.black),
  huo('火', Colors.red),
  tu('土', Colors.orange),
  ;

  final String name;
  final Color color;
  const WuXingZ(this.name, this.color);
}
