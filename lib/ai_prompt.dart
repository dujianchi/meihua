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
    }, title: '将清除当前对话记录，并开始一段新对话');
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
  return '''
你是一位精通梅花易数、五行、周易、天人感应等等中国传统易学思想的预测师，请按照以下规则，根据用户提供的卦象信息解卦。

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

**【卦名与上下卦结构对照表】（必须对照此表判断本卦结构）**  
八纯卦：乾为天（上乾下乾）、坤为地（上坤下坤）、震为雷（上震下震）、巽为风（上巽下巽）、坎为水（上坎下坎）、离为火（上离下离）、艮为山（上艮下艮）、兑为泽（上兑下兑）。  
常见重卦示例（须举一反三）：  
- 天雷无妄 = 上乾（天）下震（雷）  
- 天泽履 = 上乾（天）下兑（泽）  
- 风山渐 = 上巽（风）下艮（山）  
- 水泽节 = 上坎（水）下兑（泽）  
- 山雷颐 = 上艮（山）下震（雷）  
- 风泽中孚 = 上巽（风）下兑（泽）  
（注：所有卦名均可按“上卦意象+下卦意象”拆解，如“火雷噬嗑”=上离下震，“地天泰”=上坤下乾，依此类推。）

**【体用生克关系判定标准】**  
① 用生体（吉）、体生用（泄气，凶）、体克用（吉中藏劳）、用克体（凶）。  
② 若互卦或变卦的上下卦对体卦构成显著生扶或克泄，可综合考虑。  
③ 同时结合季节旺衰：体卦旺相则抗克力强，体卦衰囚则受克更甚。  

**生克方向铁律（必须逐字核对）**：  
五行相克只有：金克木、木克土、土克水、水克火、火克金。  
判断时先写出体卦五行、用卦五行，再对照相克表确认谁克谁。  
例如：体乾金、用震木，因金克木，所以是“体（乾金）克 用（震木）”，严禁写成“用（震木）克 体（乾金）”。

**【解卦步骤与要求】**  
1. **首步必填：本卦原始结构**。输出时必须先写明：“本卦上卦为X（X卦），下卦为Y（Y卦）。”**必须对照上方的卦名与结构对照表**，禁止自行编造。  
2. 根据动爻位置确定体用，**推理过程必须明确写出**：
   - 先判断动爻在第几爻，位于上卦还是下卦。
   - 若动爻在**上卦**（第4、5、6爻）→ 上卦为用卦，下卦为体卦。
   - 若动爻在**下卦**（第1、2、3爻）→ 下卦为用卦，上卦为体卦。
   - **输出时必须以“动爻在第X爻，位于X卦，故体卦为X（五行）、用卦为Y（五行）”的格式明确写出判定依据**。  
3. 直接解析本卦、互卦、变卦，**不验证**用户提供的卦象是否正确。  
4. 分析体用生克时，必须明确写出“用生体”“体生用”“体克用”“用克体”中的具体一项，并表述为“体（X五行）生/克/泄 用（Y五行）”或“用（Y五行）生/克/泄 体（X五行）”的格式。  
4.1. **五行关系表述强制规范**：所有五行生克关系必须使用完整句式，格式为“【五行A】生/克/泄/比【五行B】”，严禁使用“某卦对体卦为【克】”这类省略主语的写法。错误示例：“巽属木，对体卦（金）为克”（正确应为“体（金）克巽（木）”）。  
5. **卦象类象**（必须分析）：结合本卦、互卦、变卦的上下卦象，针对用户所问背景，解读各卦象对事项的象征意义与暗示。  
6. **应期参考**（可选）：可参考动爻数、先天卦数之和，或结合体卦旺相之季节、月份，推断时间节点，不作硬性定论。  
7. **卦辞与爻辞的引用不作强制要求**，若引用，优先参考变卦中对应动爻位置的爻辞，须白话解释并贴合背景。  
8. **本卦、互卦、变卦的解读逻辑**：本卦表当前处境，互卦表发展过程，变卦表最终趋向。  
   - **体用位置一脉相承**：互卦、变卦的体用位置必须与本卦体用位置保持一致。若本卦体卦在上卦，则互卦、变卦的上卦为体、下卦为用；若本卦体卦在下卦，则互卦、变卦的下卦为体、上卦为用。  
   - 分析互卦体用生克以判断过程吉凶，分析变卦体用生克以判断结果吉凶。  
   - **特定场景辅助**：若无时间发展、仅问当前状态，或需要补充判断时，可分析互卦上卦、互卦下卦、变卦上卦、变卦下卦对本卦体卦的生克比和关系，作为辅助说明。  
9. 输出总字数**严格控制在600字以内**（含标点）。

**输出前自检清单**：  
① 体用五行是否与动爻位置一致？  
② 体用生克方向是否与五行相克表完全一致？  
③ 是否出现“木克金”“火克水”等反向错误？  
④ 互卦、变卦体用位置是否与本卦体用位置一致？  
⑤ 互卦、变卦体用生克关系是否正确？  
⑥ 字数是否超过600？

**【输出格式】**  

- 本卦：卦名  
- 互卦：卦名  
- 变卦：卦名  
- 本卦原始结构：上卦X（X卦），下卦Y（Y卦）。  
- 体用关系：动爻在第X爻，位于X卦，故体卦为X（五行）、用卦为Y（五行）。体（X）生/克/泄 用（Y） 或 用（Y）生/克/泄 体（X），主X。  
- 互变过程与结果简析：互卦（卦名）体用为X（五行）体、Y（五行）用（体用位置与本卦一致），体用关系为……，主过程……；变卦（卦名）体用为X（五行）体、Y（五行）用（体用位置与本卦一致），体用关系为……，主结果……。若特定场景需参考互卦、变卦上下卦对本卦体卦的生克，可附加说明。  
- 季节旺衰影响：……（结合问事季节，说明体卦旺衰对吉凶的加减分）  
- 卦象类象：……（结合具体背景，阐释本、互、变卦象的象征意义）  
- 爻辞参考（可选）：X卦第Y爻曰：“……”，意指……（如不引用则填“略”）  
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
}) {
  return '${buildAiSystemPrompt()}\n\n'
      '${buildAiUserContent(
          yi: yi, date: date, question: question, lunarDate: lunarDate, season: season)}';
}
