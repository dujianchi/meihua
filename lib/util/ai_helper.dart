import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meihua/util/config_helper.dart';
import 'package:meihua/util/exts.dart';

/// AI 接口配置
class AiConfig {
  final String endpoint, apiKey, model, customPrompt, systemPrompt;
  const AiConfig({
    required this.endpoint,
    required this.apiKey,
    required this.model,
    required this.customPrompt,
    required this.systemPrompt,
  });
}

/// AI 回复:正文 + 可选的思考过程(推理模型才有)
class AiReply {
  final String content;
  final String? reasoning;
  const AiReply({required this.content, this.reasoning});
}

/// AI 接入助手：配置与调用 OpenAI 兼容的 chat/completions 接口解析卦象
class AiHelper {
  static const keyEndpoint = 'ai_endpoint';
  static const keyKey = 'ai_key';
  static const keyModel = 'ai_model';
  static const keyPrompt = 'ai_prompt';
  static const keySystemPrompt = 'ai_system_prompt';

  /// AI配置的版本时间戳(配置表键):保存配置时刷新,同步时新者胜
  static const keyUpdateTime = 'ai_config_update_time';

  /// 参与同步的配置键(不含版本时间戳 keyUpdateTime)
  static const configKeys = [
    keyEndpoint,
    keyKey,
    keyModel,
    keyPrompt,
    keySystemPrompt,
  ];

  /// 默认系统提示词(可在AI设置页修改,无需重新打包)
  static const defaultSystemPrompt = '''
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

  /// 加载配置，未设置的项使用默认值
  static Future<AiConfig> loadConfig() async {
    return AiConfig(
      endpoint: (await ConfigHelper.getConfig(keyEndpoint)).or('https://api.agnes-ai.cn/v1/chat/completions'),
      apiKey: (await ConfigHelper.getConfig(keyKey)).or('sk-gVla6Pca3kbNCcybrTPbFTSnz7FmtUwEHIpBSTM97UgyTHJf'),
      model: (await ConfigHelper.getConfig(keyModel)).or('agnes-2.5-flash'),
      customPrompt: (await ConfigHelper.getConfig(keyPrompt)).or('{卦象}'),
      systemPrompt: (await ConfigHelper.getConfig(keySystemPrompt))
          .or(defaultSystemPrompt),
    );
  }

  static Future<void> saveConfig({
    String? endpoint,
    String? apiKey,
    String? model,
    String? customPrompt,
    String? systemPrompt,
  }) async {
    await ConfigHelper.saveConfig(keyEndpoint, endpoint);
    await ConfigHelper.saveConfig(keyKey, apiKey);
    await ConfigHelper.saveConfig(keyModel, model);
    await ConfigHelper.saveConfig(keyPrompt, customPrompt);
    await ConfigHelper.saveConfig(keySystemPrompt, systemPrompt);
    // 刷新配置版本时间戳,供AI设置同步以"新覆盖旧"
    await ConfigHelper.saveConfig(
        keyUpdateTime, '${DateTime.now().millisecondsSinceEpoch}');
  }

  /// 拼接发给AI的用户消息：自定义提示词优先，{卦象}占位符会被替换为默认提示词内容
  static String buildUserContent(AiConfig config, String defaultPrompt) {
    final custom = config.customPrompt.trim();
    if (custom.isEmpty) return defaultPrompt;
    return custom.contains('{卦象}')
        ? custom.replaceAll('{卦象}', defaultPrompt)
        : custom;
  }

  /// 调用AI接口（多轮对话，messages 为 {role, content} 历史消息），返回模型回复；
  /// 失败抛出带中文说明的异常
  static Future<AiReply> chat(
      AiConfig config, List<Map<String, String>> messages) async {
    final endpoint = config.endpoint.trim();
    final apiKey = config.apiKey.trim();
    final model = config.model.trim();
    if (endpoint.isEmpty) {
      throw Exception('未配置AI接口地址，请到右上角「AI设置」中配置');
    }
    if (apiKey.isEmpty) {
      throw Exception('未配置API密钥，请到右上角「AI设置」中配置');
    }
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 120),
    ));
    'AI请求: endpoint=$endpoint, model=$model'.log();
    'AI请求体: ${_snip(jsonEncode(messages))}'.log();
    try {
      final response = await dio.post(
        endpoint,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        }),
        data: {
          'model': model,
          'messages': messages,
        },
      );
      return _parseResponse(response.data);
    } on DioException catch (e) {
      e.log('AI请求失败: ');
      final status = e.response?.statusCode;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('请求超时，请检查网络与接口地址');
      }
      if (status == 401 || status == 403) {
        throw Exception('认证失败（HTTP $status），请检查API密钥');
      }
      final data = e.response?.data;
      if (data is Map) {
        final errMsg = data['error'];
        final msg = errMsg is Map ? errMsg['message'] : null;
        if (msg is String && msg.isNotEmpty) {
          throw Exception('请求失败（HTTP $status）：$msg');
        }
      } else if (data is String && data.isNotEmpty) {
        throw Exception('请求失败（HTTP $status），接口返回非JSON：${_snip(data)}');
      }
      throw Exception(status == null
          ? '网络请求失败：${e.message}'
          : '请求失败（HTTP $status）');
    }
  }

  /// 解析 chat/completions 响应；格式不对时抛出含原始返回片段的异常
  static AiReply _parseResponse(dynamic data) {
    'AI响应: ${_snip('$data')}'.log();
    if (data is! Map) {
      throw Exception('接口返回非JSON格式：${_snip('$data')}');
    }
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw Exception('接口返回缺少choices字段：${_snip('$data')}');
    }
    final choice = choices[0];
    final message = choice is Map ? choice['message'] : null;
    final content = message is Map ? message['content'] : null;
    if (content is String && content.trim().isNotEmpty) {
      return AiReply(
        content: content,
        reasoning: _extractReasoning(message),
      );
    }
    throw Exception('AI返回内容为空：${_snip('$data')}');
  }

  /// 提取思考过程:兼容 deepseek 的 reasoning_content 与 openai 的 reasoning
  static String? _extractReasoning(dynamic message) {
    if (message is! Map) return null;
    final reasoningContent = message['reasoning_content'];
    if (reasoningContent is String && reasoningContent.trim().isNotEmpty) {
      return reasoningContent;
    }
    final reasoning = message['reasoning'];
    if (reasoning is String && reasoning.trim().isNotEmpty) {
      return reasoning;
    }
    if (reasoning is Map) {
      final content = reasoning['content'];
      if (content is String && content.trim().isNotEmpty) {
        return content;
      }
    }
    return null;
  }

  /// 截断长文本,便于在错误弹窗中展示
  static String _snip(String s) {
    final str = s.trim();
    if (str.isEmpty) return '空';
    return str.length > 300 ? '${str.substring(0, 300)}…' : str;
  }
}
