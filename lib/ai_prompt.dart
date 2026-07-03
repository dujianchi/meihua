import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/util/exts.dart';

/// AI 提示词展示页：展示拼接好的解卦提示词，右上角可复制到粘贴板。
class AiPromptPage extends StatelessWidget {
  final String prompt;
  const AiPromptPage({super.key, required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 提示词'),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_copy),
            tooltip: '复制',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: prompt));
              '已复制到粘贴板，可粘贴到AI对话框解析'.toast();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: SelectableText(
              prompt,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// 拼接解卦提示词。`question` 为用户输入的"问的是什么"，可空。
String buildAiPrompt({
  required Yi yi,
  required String date,
  String? question,
}) {
  final gua = yi.gua();
  final bg =
      question == null || question.trim().isEmpty ? '未提供' : question.trim();
  return '''你是一位精通梅花易数的预测师。请根据以下信息解卦：

- 本卦：${gua[0].name()}
- 互卦：${gua[1].name()}
- 变卦：${gua[2].name()}
- 动爻：${yi.dong}
- 时间：$date
- 问事背景：$bg

五行：乾、兑属金；离属火；震、巽属木；坎属水；艮、坤属土

要求：
1. 根据提供的通过动爻确定体、用，并且直接解析本卦、互卦、变卦，不用验证我给的卦对不对。
2. 分析体用生克关系（用生体/体克用等），并说明吉凶倾向（有时候体用生克需要结合互卦和变卦，比如互卦和变卦的上下卦都克或泄本卦的体卦；有时候也需要结合当前时间的季节与五行的卦气旺衰）。
3. 引用本卦卦辞，结合互卦、变卦的动爻所在爻辞（白话解释），贴合所问背景。
4. 通常情况下，本卦代表当前，互卦代表过程，变卦代表结果，但这并非确定，有时候也需要结合问事背景将3个卦结合解析。
5. 给出300字以内综合断语和简短建议，最后需要结合问事背景提醒本解析属于AI解析，需要理性对待，相信科学。
6. 按以下格式输出：

本卦：卦名
互卦：卦名
变卦：卦名
体用五行：体卦属X，用卦属Y，互卦、变卦的体用与本卦体卦的五行关系……
生克关系：……（简要说明）
动爻爻辞：X卦第Y爻曰："……"，意指……
综合断语：……
建议：……。……（提醒）

现在开始解卦。''';
}
