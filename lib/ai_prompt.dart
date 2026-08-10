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
                        final bubble = Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.purple
                                : Colors.grey.shade200,
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
                                    : Colors.black87,
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
                          color: Colors.grey.shade500,
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
  return '''你是一位精通梅花易数的预测师，请直接根据用户提供的卦象信息解卦。

五行：乾、兑属金；离属火；震、巽属木；坎属水；艮、坤属土

要求：
1. 根据提供的通过动爻确定体、用，并且直接解析本卦、互卦、变卦，不用验证用户给的卦对不对。
2. 分析体用生克关系（用生体/体克用等），并说明吉凶倾向（有时候体用生克需要结合互卦和变卦，比如互卦和变卦的上下卦都克或泄本卦的体卦；有时候也需要结合当前时间的季节与五行的卦气旺衰）。
3. 引用本卦卦辞，结合互卦、变卦的动爻所在爻辞（白话解释），贴合所问背景。
4. 通常情况下，本卦代表当前，互卦代表过程，变卦代表结果，但这并非确定，有时候也需要结合问事背景将3个卦结合解析。
5. 给出300字以内综合断语和简短建议，最后需要结合问事背景提醒本解析属于AI解析，需要理性对待，相信科学。
6. 按以下格式输出：

  - 本卦：卦名
  - 互卦：卦名
  - 变卦：卦名
  - 体用五行：体卦属X，用卦属Y，互卦、变卦的体用与本卦体卦的五行关系……
  - 生克关系：……（简要说明）
  - 动爻爻辞：X卦第Y爻曰："……"，意指……
  - 综合断语：……
  - 建议：……。……（提醒）

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
