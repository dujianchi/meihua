import 'package:flutter/material.dart';
import 'package:meihua/enum/sheng_ke_bihe.dart';

/// 五行 - 值
/// 金木水火土
enum WuXingZ {
  jin('金', Colors.orange),
  mu('木', Colors.green),
  shui('水', Colors.black),
  huo('火', Colors.red),
  tu('土', Colors.grey),
  ;

  final String name;
  final Color color;
  const WuXingZ(this.name, this.color);

  /// 生克比和
  ShengKeBihe shengKeBihe(WuXingZ wx) {
    switch (this) {
      case WuXingZ.jin:
        switch (wx) {
          case WuXingZ.jin:
            return ShengKeBihe.bihe;
          case WuXingZ.mu:
            return ShengKeBihe.woKe;
          case WuXingZ.shui:
            return ShengKeBihe.woSheng;
          case WuXingZ.huo:
            return ShengKeBihe.keWo;
          case WuXingZ.tu:
            return ShengKeBihe.shengWo;
        }
      case WuXingZ.mu:
        switch (wx) {
          case WuXingZ.jin:
            return ShengKeBihe.keWo;
          case WuXingZ.mu:
            return ShengKeBihe.bihe;
          case WuXingZ.shui:
            return ShengKeBihe.shengWo;
          case WuXingZ.huo:
            return ShengKeBihe.woSheng;
          case WuXingZ.tu:
            return ShengKeBihe.woKe;
        }
      case WuXingZ.shui:
        switch (wx) {
          case WuXingZ.jin:
            return ShengKeBihe.shengWo;
          case WuXingZ.mu:
            return ShengKeBihe.woSheng;
          case WuXingZ.shui:
            return ShengKeBihe.bihe;
          case WuXingZ.huo:
            return ShengKeBihe.woKe;
          case WuXingZ.tu:
            return ShengKeBihe.keWo;
        }
      case WuXingZ.huo:
        switch (wx) {
          case WuXingZ.jin:
            return ShengKeBihe.woKe;
          case WuXingZ.mu:
            return ShengKeBihe.shengWo;
          case WuXingZ.shui:
            return ShengKeBihe.keWo;
          case WuXingZ.huo:
            return ShengKeBihe.bihe;
          case WuXingZ.tu:
            return ShengKeBihe.woSheng;
        }
      case WuXingZ.tu:
        switch (wx) {
          case WuXingZ.jin:
            return ShengKeBihe.woSheng;
          case WuXingZ.mu:
            return ShengKeBihe.keWo;
          case WuXingZ.shui:
            return ShengKeBihe.woKe;
          case WuXingZ.huo:
            return ShengKeBihe.shengWo;
          case WuXingZ.tu:
            return ShengKeBihe.bihe;
        }
    }
  }
}
