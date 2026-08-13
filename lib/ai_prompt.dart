import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/util/ai_helper.dart';
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

/// AI 解析结果页：展示模型返回的解卦内容，可继续追问，气泡旁小图标复制单条消息。
/// [systemPrompt] 首次调用时作为 system 消息注入(已含 system 消息的历史对话不会重复注入)；
/// [initialMessages] 传入历史对话可继续追问；[pendingUserContent] 非空时进入页面自动发送首轮消息；
/// [onUpdate] 每次对话更新后回调(用于实时持久化)。
class AiResultPage extends StatefulWidget {
  final String? systemPrompt;
  final List<Map<String, String>>? initialMessages;
  final String? pendingUserContent;
  final ValueChanged<List<Map<String, String>>>? onUpdate;
  const AiResultPage({
    super.key,
    this.systemPrompt,
    this.initialMessages,
    this.pendingUserContent,
    this.onUpdate,
  });

  @override
  State<StatefulWidget> createState() => _AiResultPageState();
}

class _AiResultPageState extends State<AiResultPage> {
  late final List<Map<String, String>> _messages =
      List.of(widget.initialMessages ?? []);
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _loading = false;
  bool _lastFailed = false;

  @override
  void initState() {
    super.initState();
    final pending = widget.pendingUserContent;
    if (pending?.isNotEmpty == true) {
      _send(pending!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 直接复制指定消息内容
  void _copyMessage(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    '已复制到粘贴板'.toast();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? preset]) async {
    final question = (preset ?? _controller.text).trim();
    if (question.isEmpty || _loading) return;
    _controller.clear();
    final system = widget.systemPrompt;
    if (system?.isNotEmpty == true &&
        (_messages.isEmpty || _messages.first['role'] != 'system')) {
      _messages.insert(0, {'role': 'system', 'content': system!});
    }
    _messages.add({'role': 'user', 'content': question});
    await _request();
  }

  /// 发起AI请求(失败后点击"重试"时复用现有消息,不重复添加)
  Future<void> _request() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _lastFailed = false;
    });
    _scrollToBottom();
    try {
      final config = await AiHelper.loadConfig();
      final result = await AiHelper.chat(config, List.of(_messages));
      _messages.add({'role': 'assistant', 'content': result});
      widget.onUpdate?.call(List.of(_messages));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _lastFailed = true;
      });
      e.log('AI请求失败: ');
      e.toString().replaceFirst('Exception: ', '').toast(4);
      return;
    }
    if (!mounted) return;
    setState(() => _loading = false);
    _scrollToBottom();
  }

  /// 失败后重试
  Future<void> _retry() => _request();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI解析结果'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty && !_loading
                  ? const Center(
                      child: Text(
                        '暂无AI解析记录',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length +
                          (_loading ? 1 : 0) +
                          (_lastFailed ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _messages.length) {
                          if (_lastFailed && !_loading) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      size: 16, color: Colors.redAccent),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'AI请求失败',
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('重试'),
                                    onPressed: _retry,
                                  ),
                                ],
                              ),
                            );
                          }
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('AI思考中…'),
                              ],
                            ),
                          );
                        }
                        final message = _messages[index];
                        final isUser = message['role'] == 'user';
                        final content = message['content'] ?? '';
                        final maxWidth =
                            MediaQuery.sizeOf(context).width * 0.8;
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        final bubble = Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.purple
                                : (isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: MarkdownBody(
                            data: content,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: isUser
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white
                                        : Colors.black87),
                              ),
                            ),
                          ),
                        );
                        final copyBtn = IconButton(
                          icon: const Icon(Icons.copy, size: 14),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 28, minHeight: 28),
                          visualDensity: VisualDensity.compact,
                          tooltip: '复制',
                          color: isUser
                              ? Colors.white70
                              : (isDark
                                  ? Colors.white38
                                  : Colors.grey.shade500),
                          onPressed: () => _copyMessage(content),
                        );
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: isUser
                                ? [bubble, copyBtn]
                                : [copyBtn, bubble],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: '输入追问内容…',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    tooltip: '发送',
                    onPressed: _loading ? null : _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 系统提示词:设定AI角色、解卦要求与输出格式(首次调用时作为 system 消息注入)
String buildAiSystemPrompt() {
  return '''你是一位精通梅花易数、五行、周易、天人感应等等中国传统易学思想的预测师，请按照以下规则，根据用户提供的卦象信息解卦。

**【五行基本规则】（必须严格遵循）**  
- 五行相生：金生水，水生木，木生火，火生土，土生金。  
- 五行相克：金克木，木克土，土克水，水克火，火克金。  
- 八卦五行属性：乾、兑属金；震、巽属木；坎属水；离属火；艮、坤属土。  
- 季节卦气旺衰（以问事时间所在季节判断）：  
  - 春季（寅卯月）：木旺，火相，水休，金囚，土死。  
  - 夏季（巳午月）：火旺，土相，木休，水囚，金死。  
  - 秋季（申酉月）：金旺，水相，土休，火囚，木死。  
  - 冬季（亥子月）：水旺，木相，金休，土囚，火死。  
  - 四季末（辰戌丑未月）：土旺，金相，火休，木囚，水死。  
- 体用生克关系判定标准（优先级从高到低）：  
  ① 用生体（吉）、体生用（泄气，凶）、体克用（吉中藏劳）、用克体（凶）。  
  ② 若互卦或变卦的上下卦对体卦构成生扶或克泄，需综合考虑（例如互卦、变卦均克体，则凶性加重；若互变生体，则可解厄）。  
  ③ 同时结合季节旺衰：体卦旺相则抗克力强，体卦衰囚则受克更甚。

**【解卦步骤与要求】**  
1. 根据动爻位置确定体用：  
   - 动爻在**上卦** → 上卦为用卦，下卦为体卦。  
   - 动爻在**下卦** → 下卦为用卦，上卦为体卦。  
   （仅以动爻所在经卦为用，另一经卦为体；互卦、变卦中的上下卦仅作参考，不另立体用）  
2. 直接解析本卦、互卦、变卦，**不验证**用户提供的卦象是否正确。  
3. 分析体用生克时，必须明确写出“用生体”“体生用”“体克用”“用克体”中的具体一项，并结合互卦、变卦对体卦的生克影响，以及季节旺衰，综合判断吉凶倾向。  
4. **卦象类象**（必须分析）：结合本卦、互卦、变卦的上下卦象（如乾为天、刚健；坤为地、柔顺；坎为水、险陷；离为火、明丽；震为雷、动荡；巽为风、渗透；艮为山、阻滞；兑为泽、愉悦等），针对用户所问背景（如出行、事业、感情、财运等），解读各卦象对事项的象征意义与暗示。  
5. **应期参考**（可选，视情况增删）：可参考动爻数、先天卦数（乾1兑2离3震4巽5坎6艮7坤8）之和，或结合体卦旺相之季节、月份，推断事情发展或结果可能出现的时间节点（如“近期”“秋冬季”“某月前后”等），不作硬性定论，仅作辅助提示。  
6. **卦辞与爻辞的引用不作强制要求**，由你根据断卦需要灵活取舍。若引用，**优先参考变卦中对应动爻位置的爻辞**（梅花易数实践中常以变卦爻辞为占断核心），也可辅以本卦卦辞或本卦动爻爻辞；全部需白话解释，并贴合所问背景。互卦爻辞一般不引，以卦象象征辅助过程分析即可。  
7. 本卦表当前处境，互卦表发展过程，变卦表最终趋向；也可根据问事背景灵活交叉解读，需在断语中体现。  
8. 输出总字数**严格控制在600字以内**（含标点），最后必须附上理性提醒。

**【输出格式】**  

  - 本卦：卦名  
  - 互卦：卦名  
  - 变卦：卦名  
  - 体用五行：体卦属X，用卦属Y，用（生/克/泄/扶）体；互卦上X属Y，下X属Y，……（结合具体背景，简要分析互卦对主卦的五行影响，可选）；变卦上X属Y，下X属Y，……（结合具体背景，简要分析变卦对主卦的五行影响，可选）。  
  - 生克关系：……（结合具体背景，简要说明，包含季节旺衰结论）  
  - 卦象类象：……（结合具体背景，阐释本、互、变卦象的象征意义）  
  - 爻辞参考（可选）：X卦第Y爻曰：“……”，意指……（白话解释，如不引用则填“略”）  
  - 应期参考（可选）：……（如不推算则填“略”）  
  - 综合断语：……（融合本互变、体用、类象，给出结论）  
  - 建议：……（具体行动建议）。
  - 本解析为AI推演，需理性对待，请结合现实信息与科学方法做最终决策。

''';
}

/// 用户消息:本次卦象信息与问事背景。`question` 为用户输入的"问的是什么"，可空。
String buildAiUserContent({
  required Yi yi,
  required String date,
  String? question,
}) {
  final gua = yi.gua();
  final bg =
      question == null || question.trim().isEmpty ? '未提供' : question.trim();
  return '''请根据以下卦象信息解卦：

- 本卦：${gua[0].name()}
- 互卦：${gua[1].name()}
- 变卦：${gua[2].name()}
- 动爻：${yi.dong}
- 时间：$date
- 问事背景：$bg''';
}

/// 拼接完整解卦提示词(系统提示词+卦象信息)，供复制使用
String buildAiPrompt({
  required Yi yi,
  required String date,
  String? question,
}) {
  return '${buildAiSystemPrompt()}\n\n'
      '${buildAiUserContent(yi: yi, date: date, question: question)}';
}
