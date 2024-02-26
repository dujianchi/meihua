import 'package:flutter/material.dart';
import 'package:meihua/enum/ba_gua.dart';
import 'package:meihua/util/consts.dart';
import 'package:meihua/widget/yao.dart';

/// 八卦 - 象
/// 乾一,兑二,离三,震四,巽五,坎六,艮七,坤八
/// 乾三连，兑上缺，离中虚，震仰盂，巽下断，坎中满，艮覆碗，坤六断
class Gua extends StatelessWidget {
  final BaGua? baGua;
  final double spacing;
  final Color background;

  const Gua({
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
      if (baGua == BaGua.qian) {
        final yang = Yao(
          true,
          BaGua.qian.wuXing.color,
          spacing: spacing,
        );
        // 乾三连
        children.add(yang);
        children.add(yang);
        children.add(yang);
      } else if (baGua == BaGua.dui) {
        final yin = Yao(
          false,
          BaGua.dui.wuXing.color,
          spacing: spacing,
        );
        final yang = Yao(
          true,
          BaGua.dui.wuXing.color,
          spacing: spacing,
        );
        // 兑上缺
        children.add(yin);
        children.add(yang);
        children.add(yang);
      } else if (baGua == BaGua.li) {
        final yin = Yao(
          false,
          BaGua.li.wuXing.color,
          spacing: spacing,
        );
        final yang = Yao(
          true,
          BaGua.li.wuXing.color,
          spacing: spacing,
        );
        // 离中虚
        children.add(yang);
        children.add(yin);
        children.add(yang);
      } else if (baGua == BaGua.zhen) {
        final yin = Yao(
          false,
          BaGua.zhen.wuXing.color,
          spacing: spacing,
        );
        final yang = Yao(
          true,
          BaGua.zhen.wuXing.color,
          spacing: spacing,
        );
        // 震仰盂
        children.add(yin);
        children.add(yin);
        children.add(yang);
      } else if (baGua == BaGua.xun) {
        final yin = Yao(
          false,
          BaGua.xun.wuXing.color,
          spacing: spacing,
        );
        final yang = Yao(
          true,
          BaGua.xun.wuXing.color,
          spacing: spacing,
        );
        // 巽下断
        children.add(yang);
        children.add(yang);
        children.add(yin);
      } else if (baGua == BaGua.kan) {
        final yin = Yao(
          false,
          BaGua.kan.wuXing.color,
          spacing: spacing,
        );
        final yang = Yao(
          true,
          BaGua.kan.wuXing.color,
          spacing: spacing,
        );
        // 坎中满
        children.add(yin);
        children.add(yang);
        children.add(yin);
      } else if (baGua == BaGua.gen) {
        final yin = Yao(
          false,
          BaGua.gen.wuXing.color,
          spacing: spacing,
        );
        final yang = Yao(
          true,
          BaGua.gen.wuXing.color,
          spacing: spacing,
        );
        // 艮覆碗
        children.add(yang);
        children.add(yin);
        children.add(yin);
      } else if (baGua == BaGua.kun) {
        final yin = Yao(
          false,
          BaGua.kun.wuXing.color,
          spacing: spacing,
        );
        // 坤六断
        children.add(yin);
        children.add(yin);
        children.add(yin);
      }
      return Stack(
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
            child: Tooltip(
              message: Consts.guaStrs[baGua?.name],
              child: Text(
                baGua?.name ?? '',
                style: TextStyle(
                  fontSize: 28,
                  background: Paint()..color = Colors.white54,
                  foreground: Paint()..color = Colors.blueAccent,
                ),
              ),
            ),
          )
        ],
      );
    }
  }
}
