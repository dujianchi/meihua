import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meihua/util/config_helper.dart';
import 'package:meihua/util/exts.dart';

/// AI 接口配置
class AiConfig {
  final String endpoint, apiKey, model, customPrompt;
  const AiConfig({
    required this.endpoint,
    required this.apiKey,
    required this.model,
    required this.customPrompt,
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

  /// 加载配置，未设置的项使用默认值
  static Future<AiConfig> loadConfig() async {
    return AiConfig(
      endpoint: (await ConfigHelper.getConfig(keyEndpoint)).or('https://api.agnes-ai.cn/v1/chat/completions'),
      apiKey: (await ConfigHelper.getConfig(keyKey)).or('sk-gVla6Pca3kbNCcybrTPbFTSnz7FmtUwEHIpBSTM97UgyTHJf'),
      model: (await ConfigHelper.getConfig(keyModel)).or('agnes-2.5-flash'),
      customPrompt: (await ConfigHelper.getConfig(keyPrompt)).or('{卦象}'),
    );
  }

  static Future<void> saveConfig({
    String? endpoint,
    String? apiKey,
    String? model,
    String? customPrompt,
  }) async {
    await ConfigHelper.saveConfig(keyEndpoint, endpoint);
    await ConfigHelper.saveConfig(keyKey, apiKey);
    await ConfigHelper.saveConfig(keyModel, model);
    await ConfigHelper.saveConfig(keyPrompt, customPrompt);
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
