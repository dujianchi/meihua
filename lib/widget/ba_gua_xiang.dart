import 'package:flutter/material.dart';
import 'package:meihua/enum/ba_gua_zhi.dart';
import 'package:meihua/util/consts.dart';
import 'package:meihua/widget/yao.dart';

/// 八卦 - 象
/// 乾一,兑二,离三,震四,巽五,坎六,艮七,坤八
/// 乾三连，兑上缺，离中虚，震仰盂，巽下断，坎中满，艮覆碗，坤六断
class BaGua extends StatelessWidget {
  final BaGuaZ? baGua;
  final double spacing;
  final Color background;

  const BaGua({
    super.key,
    this.baGua,
    this.spacing = 10,
    this.background = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    if (baGua == null) {
      return const SizedBox.shrink(); // 返回空白
    } else {
      final children = <Widget>[];
      if (baGua == BaGuaZ.qian) {
        final yang = Yao(
          true,
          BaGuaZ.qian.wuXing.color,
          spacing: spacing,
        );
        // 乾三连
        children.add(yang);
        children.add(yang);
        children.add(yang);
      } else if (baGua == BaGuaZ.dui) {
        final yin = Yao(
          false,
          BaGuaZ.dui.wuXing.color,
          spacing: spacing,
        );
        final yang = Yao(
          true,
          BaGuaZ.dui.wuXing.color,
          spacing: spacing,
        );
        // 兑上缺
        children.add(yin);
        children.add(yang);
        children.add(yang);
      } else if (baGua == BaGuaZ.li) {
        final yin = Yao(
          false,
          BaGuaZ.li.wuXing.color,
          spacing: spacing,
        );
        final yang = Yao(
          true,
          BaGuaZ.li.wuXing.color,
          spacing: spacing,
        );
        // 离中虚
        children.add(yang);
        children.add(yin);
        children.add(yang);
      } else if (baGua == BaGuaZ.zhen) {
        final yin = Yao(
          false,
          BaGuaZ.zhen.wuXing.color,
          spacing: spacing,
        );
        final yang = Yao(
          true,
          BaGuaZ.zhen.wuXing.color,
          spacing: spacing,
        );
        // 震仰盂
        children.add(yin);
        children.add(yin);
        children.add(yang);
      } else if (baGua == BaGuaZ.xun) {
        final yin = Yao(
          false,
          BaGuaZ.xun.wuXing.color,
          spacing: spacing,
        );
        final yang = Yao(
          true,
          BaGuaZ.xun.wuXing.color,
          spacing: spacing,
        );
        // 巽下断
        children.add(yang);
        children.add(yang);
        children.add(yin);
      } else if (baGua == BaGuaZ.kan) {
        final yin = Yao(
          false,
          BaGuaZ.kan.wuXing.color,
          spacing: spacing,
        );
        final yang = Yao(
          true,
          BaGuaZ.kan.wuXing.color,
          spacing: spacing,
        );
        // 坎中满
        children.add(yin);
        children.add(yang);
        children.add(yin);
      } else if (baGua == BaGuaZ.gen) {
        final yin = Yao(
          false,
          BaGuaZ.gen.wuXing.color,
          spacing: spacing,
        );
        final yang = Yao(
          true,
          BaGuaZ.gen.wuXing.color,
          spacing: spacing,
        );
        // 艮覆碗
        children.add(yang);
        children.add(yin);
        children.add(yin);
      } else if (baGua == BaGuaZ.kun) {
        final yin = Yao(
          false,
          BaGuaZ.kun.wuXing.color,
          spacing: spacing,
        );
        // 坤六断
        children.add(yin);
        children.add(yin);
        children.add(yin);
      }
      return Tooltip(
        message: Consts.guaStrs[baGua?.name],
        child: Stack(
          children: [
            Container(
              color: background, // 白底
              margin: EdgeInsets.all(spacing),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: children,
              ),
            ),
            Center(
              child: Text(
                baGua?.name ?? '',
                style: TextStyle(
                  fontSize: 18,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.5
                    ..strokeJoin = StrokeJoin.round
                    ..strokeCap = StrokeCap.round
                    ..color = Colors.blue,
                  background: Paint()..color = Colors.amber,
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
