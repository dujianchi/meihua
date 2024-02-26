import 'package:flutter/material.dart';

/// 八卦 - 值
/// 乾一,兑二,离三,震四,巽五,坎六,艮七,坤八
enum WuXingZ {
  jin(Colors.yellow),
  mu(Colors.green),
  shui(Colors.black),
  huo(Colors.red),
  tu(Colors.orange),
  ;

  final Color color;
  const WuXingZ(this.color);
}
