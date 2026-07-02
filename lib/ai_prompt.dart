import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              '已复制到粘贴板'.toast();
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
  required int shang,
  required int xia,
  required int dong,
  String? question,
}) {
  final bg =
      question == null || question.trim().isEmpty ? '未提供' : question.trim();
  return '''你是一位精通梅花易数的预测师。请根据以下信息解卦：

- 上卦数：$shang
- 下卦数：$xia
- 动爻数：$dong
- 问事背景：$bg

八卦对应：1乾☰ 2兑☱ 3离☲ 4震☳ 5巽☴ 6坎☵ 7艮☶ 8坤☷
五行：乾兑金 离火 震巽木 坎水 艮坤土

要求：
1. 根据上下卦数和动爻确定本卦、体卦、用卦、互卦、变卦。
2. 分析体用生克关系（用生体/体克用等），并说明吉凶倾向。
3. 引用本卦卦辞和动爻爻辞（白话解释），贴合所问背景。
4. 给出200字以内综合断语和简短建议。
5. 按以下格式输出：

本卦：上X下Y → 卦名
互卦：卦名
变卦：卦名
体用五行：体卦属X，用卦属Y
生克关系：……（简要说明）
动爻爻辞：第X爻曰："……"，意指……
综合断语：……
建议：……

现在开始解卦。''';
}
