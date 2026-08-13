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
/// [initialMessages] 传入历史对话可继续追问；[pendingUserContent] 非空时填入输入框,
/// 由用户点击发送后才开始第一轮对话；[onUpdate] 每次对话更新后回调(用于实时持久化)；
/// [onClear] 确认重新对话后回调(用于清除已持久化的对话记录)；
/// [buildPrompt] 重新对话时重新生成首轮提示词(含最新农历/季节等信息)。
class AiResultPage extends StatefulWidget {
  final String? systemPrompt;
  final List<Map<String, String>>? initialMessages;
  final String? pendingUserContent;
  final ValueChanged<List<Map<String, String>>>? onUpdate;
  final VoidCallback? onClear;
  final Future<String?> Function()? buildPrompt;
  const AiResultPage({
    super.key,
    this.systemPrompt,
    this.initialMessages,
    this.pendingUserContent,
    this.onUpdate,
    this.onClear,
    this.buildPrompt,
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

  /// 首轮提示词(重新对话后回填到输入框)
  String? _originalPrompt;

  @override
  void initState() {
    super.initState();
    final pending = widget.pendingUserContent;
    if (pending?.isNotEmpty == true) {
      // 不自动发送,先填入输入框,由用户点击发送后开始第一轮
      _originalPrompt = pending;
      _controller.text = pending!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 重新对话:确认后清空当前对话与已持久化记录,用重新生成的首轮提示词回填输入框
  void _restartConversation() {
    '确定重新对话吗？'.confirmDialog(() async {
      // 优先重新生成(含最新农历/季节),旧对话的首条消息可能是旧格式
      final rebuilt =
          widget.buildPrompt != null ? await widget.buildPrompt!() : null;
      _originalPrompt = rebuilt ??
          _originalPrompt ??
          _messages.firstWhereOrNull((m) => m['role'] == 'user')?['content'];
      _messages.clear();
      _controller.text = _originalPrompt ?? '';
      setState(() => _lastFailed = false);
      widget.onClear?.call();
    }, content: '将清除当前对话记录，并开始一段新对话');
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
      // 只发送 role/content,剔除 reasoning 等仅用于展示的字段
      final sendable = _messages.map((m) {
        final role = m['role'] ?? 'user';
        final content = m['content'] ?? '';
        return {'role': role, 'content': content};
      }).toList();
      final reply = await AiHelper.chat(config, sendable);
      _messages.add({
        'role': 'assistant',
        'content': reply.content,
        if (reply.reasoning != null) 'reasoning': reply.reasoning!,
      });
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
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: '重新对话',
            onPressed: _restartConversation,
          ),
        ],
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
                        if (message['role'] == 'system') {
                          // system提示词只进上下文与持久化,不在界面上渲染
                          return const SizedBox.shrink();
                        }
                        final isUser = message['role'] == 'user';
                        final content = message['content'] ?? '';
                        final reasoning = message['reasoning'];
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 思考过程:推理模型有才显示
                              if (reasoning?.isNotEmpty == true)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.black12,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border(
                                        left: BorderSide(
                                            color: isUser
                                                ? Colors.white38
                                                : Colors.grey.shade400,
                                            width: 3)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '思考过程',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isUser
                                              ? Colors.white70
                                              : (isDark
                                                  ? Colors.white60
                                                  : Colors.grey.shade600),
                                        ),
                                      ),
                                      MarkdownBody(
                                        data: reasoning!,
                                        styleSheet: MarkdownStyleSheet(
                                          p: TextStyle(
                                            fontSize: 13,
                                            height: 1.4,
                                            color: isUser
                                                ? Colors.white70
                                                : (isDark
                                                    ? Colors.white60
                                                    : Colors.grey.shade600),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              MarkdownBody(
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
                            ],
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

/// 系统提示词:内容可在AI设置页修改,这里返回当前默认值
String buildAiSystemPrompt() => AiHelper.defaultSystemPrompt;

/// 用户消息:本次卦象信息与问事背景。`question` 为用户输入的"问的是什么"，可空。
String buildAiUserContent({
  required Yi yi,
  required String date,
  String? question,
  String? lunarDate,
  String? season,
}) {
  final gua = yi.gua();
  final bg =
      question == null || question.trim().isEmpty ? '未提供' : question.trim();
  final buffer = StringBuffer('''请根据以下卦象信息解卦：

- 本卦：${gua[0].name()}
- 互卦：${gua[1].name()}
- 变卦：${gua[2].name()}
- 动爻：${yi.dong}
- 时间：$date''');
  if (lunarDate?.isNotEmpty == true) {
    buffer.write('\n- 农历：$lunarDate');
  }
  if (season?.isNotEmpty == true) {
    buffer.write('\n- 季节：$season');
  }
  buffer.write('\n- 问事背景：$bg');
  return buffer.toString();
}

/// 拼接完整解卦提示词(系统提示词+卦象信息)，供复制使用
String buildAiPrompt({
  required Yi yi,
  required String date,
  String? question,
  String? lunarDate,
  String? season,
  String? systemPrompt,
}) {
  return '${systemPrompt ?? buildAiSystemPrompt()}\n\n'
      '${buildAiUserContent(
          yi: yi, date: date, question: question, lunarDate: lunarDate, season: season)}';
}
