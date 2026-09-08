// AI 气泡内容换行回归测试(见 lib/ai_prompt.dart 的 unwrapOuterCodeFence)。
// 用法: flutter test test/ai_bubble_wrap_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meihua/ai_prompt.dart';

const _sample = '''- 本卦：泽水困
- 互卦：风火家人
- 综合断语：此卦显示当前做村委之事面临“困”局，初始阶段将颇为辛劳且耗神（体用泄气），过程中人事协调复杂，压力不小。''';

Widget _bubble(String data) {
  return MaterialApp(
    home: Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: MarkdownBody(
                    data: data,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// 渲染后是否存在横向滚动容器(代码块的横向滚动正是"不换行"的元凶)
bool _hasHorizontalScroll(WidgetTester tester) {
  final scrollables = tester
      .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView));
  return scrollables.any((w) => w.scrollDirection == Axis.horizontal);
}

void main() {
  group('unwrapOuterCodeFence', () {
    test('剥掉 ```markdown 整段围栏', () {
      expect(unwrapOuterCodeFence('```markdown\n$_sample\n```'), _sample);
    });
    test('剥掉 ``` 与 ``` markdown 变体及结尾多余空行', () {
      expect(unwrapOuterCodeFence('```\n$_sample\n```\n'), _sample);
      expect(unwrapOuterCodeFence('``` markdown\n$_sample\n```'), _sample);
    });
    test('保留正文中的代码块与无围栏内容', () {
      expect(unwrapOuterCodeFence('正文\n```dart\nint a = 1;\n```\n结尾'),
          '正文\n```dart\nint a = 1;\n```\n结尾');
      expect(unwrapOuterCodeFence(_sample), _sample);
    });
  });

  testWidgets('剥围栏后不再出现横向滚动容器', (tester) async {
    // 复现路径:模型照提示词用 ``` 包裹整段答案
    final raw = '```markdown\n$_sample\n```';
    await tester.pumpWidget(_bubble(raw));
    expect(_hasHorizontalScroll(tester), isTrue,
        reason: '未修复时整段被渲染为横向滚动代码块');

    await tester.pumpWidget(_bubble(unwrapOuterCodeFence(raw)));
    expect(_hasHorizontalScroll(tester), isFalse,
        reason: '修复后按普通 markdown 软换行');
    expect(tester.takeException(), isNull);
  });
}
