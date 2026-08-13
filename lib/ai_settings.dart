import 'package:flutter/material.dart';
import 'package:meihua/util/ai_helper.dart';
import 'package:meihua/util/exts.dart';
import 'package:meihua/widget/edit_text.dart';

/// AI 设置页：配置接口地址、API密钥、模型与自定义提示词
class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage> {
  AiConfig? _config;

  @override
  void initState() {
    _load();
    super.initState();
  }

  Future<void> _load() async {
    final config = await AiHelper.loadConfig();
    if (mounted) {
      setState(() => _config = config);
    }
  }

  Future<void> _save(String? endpoint, String? apiKey, String? model,
      String? customPrompt, String? systemPrompt) async {
    await AiHelper.saveConfig(
      endpoint: endpoint,
      apiKey: apiKey,
      model: model,
      customPrompt: customPrompt,
      systemPrompt: systemPrompt,
    );
    '保存成功'.toast();
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    if (config == null) {
      return Scaffold(appBar: AppBar(title: const Text('AI设置')));
    }
    final endpoint = EditText(
      label: '接口地址（chat/completions）',
      defaultStr: config.endpoint,
      keyboardType: TextInputType.url,
    );
    final apiKey = EditText(
      label: 'API密钥',
      defaultStr: config.apiKey,
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
    );
    final model = EditText(
      label: '模型名',
      defaultStr: config.model,
    );
    final prompt = EditText(
      label: '自定义提示词（可选）',
      defaultStr: config.customPrompt,
      maxLines: 6,
    );
    final systemPrompt = EditText(
      label: '系统提示词',
      defaultStr: config.systemPrompt,
      maxLines: 12,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI设置'),
        actions: [
          TextButton(
            onPressed: () => _save(
              endpoint.trim(),
              apiKey.trim(),
              model.trim(),
              prompt.text(),
              systemPrompt.text(),
            ),
            child: const Text('保存'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            endpoint,
            const SizedBox(height: 12),
            apiKey,
            const SizedBox(height: 12),
            model,
            const SizedBox(height: 12),
            prompt,
            const SizedBox(height: 12),
            systemPrompt,
            const SizedBox(height: 8),
            const Text(
              '系统提示词：设定AI角色、解卦要求与输出格式，留空则使用默认值；修改后无需重新打包，下次对话生效。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              '自定义提示词：留空则使用默认解卦提示词；填写则替换默认提示词作为发送给AI的用户消息。'
              '可用 {卦象} 占位符，发送时会替换为本卦/互卦/变卦/动爻/时间/问事背景等信息，'
              '建议必带，否则AI将看不到卦象信息。\n示例：请用{卦象}解卦，重点分析事业，最后给三条建议。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
