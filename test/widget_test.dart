// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:lunar/lunar.dart';
import 'package:meihua/util/exts.dart';

void main() {
  const month = 11;
  final datetime1 = Solar.fromYmd(2024, month, 3),
      datetime2 = Solar.fromYmd(2024, month, 4),
      datetime3 = Solar.fromYmd(2024, month, 7),
      datetime4 = Solar.fromYmd(2024, month, 8);
  Lunar.fromSolar(datetime1).seasion.log();
  Lunar.fromSolar(datetime2).seasion.log();
  Lunar.fromSolar(datetime3).seasion.log();
  Lunar.fromSolar(datetime4).seasion.log();
}
