import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:meihua/entity/database/db_64gua.dart';
import 'package:meihua/entity/database/db_8gua.dart';
import 'package:meihua/entity/database/db_ai_chat.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';
import 'package:meihua/util/sync_helper.dart';
import 'package:meihua/util/ai_helper.dart';
import 'package:meihua/ai_prompt.dart';
import 'package:meihua/widget/chong_gua.dart';
import 'package:meihua/widget/edit_text.dart';
import 'package:meihua/widget/ti_yong.dart';

import 'widget/lunar_clock.dart';

class Pan extends StatelessWidget {
  static const double spacing = 3;
  static const double aspectRatio = 2.1;

  const Pan({super.key});

  @override
  Widget build(BuildContext context) {
    final yi = ModalRoute.of(context)?.settings.arguments as Yi?;
    return _Pan(yi, DateTime.now());
  }
}

class _Pan extends StatefulWidget {
  final Yi? yi;
  final DateTime now;
  const _Pan(this.yi, this.now);

  @override
  State<StatefulWidget> createState() => _PanState();
}

class _PanState extends State<_Pan> {
  var dhitory = DbHistory();
  ChongGua? _chongGua;
  String? _titleStr, _descStr;
  DbAiChat? _aiChat;
  List<Map<String, String>>? _aiMessages;
  bool _aiLoaded = false;
  TextSpan? _middleString, _bottomString;

  Future<TextSpan> _getSkText() async {
    final dong = widget.yi!.dong;
    final gua64 = _chongGua?.gua();
    final textGrey = Theme.of(context).colorScheme.onSurfaceVariant;
    if (gua64?.shang != gua64?.xia) {
      final shang8 = await Db8gua.fromName(gua64?.shang.name),
          xia8 = await Db8gua.fromName(gua64?.xia.name);
      return TextSpan(
          text: gua64?.tiyong(dong),
          children: [
            shang8!.toText(textGrey: textGrey),
            xia8!.toText(textGrey: textGrey),
          ]);
    } else {
      final shang8 = await Db8gua.fromName(gua64?.shang.name);
      return TextSpan(
          text: gua64?.tiyong(dong),
          children: [shang8!.toText(textGrey: textGrey)]);
    }
  }

  void _changeChongGua(ChongGua chongGua) async {
    final scheme = Theme.of(context).colorScheme;
    final db64gua = await Db64gua.fromFullname(chongGua.gua()!.name());
    if (db64gua != null) {
      _middleString = db64gua.toText(
        dong: chongGua.hu ? null : chongGua.bian,
        textColor: scheme.onSurface,
        textGrey: scheme.onSurfaceVariant,
      );
      if (db64gua.shang != db64gua.xia) {
        final shangTxt = await Db8gua.fromName(db64gua.shang),
            xiaTxt = await Db8gua.fromName(db64gua.xia);
        _bottomString = TextSpan(
            children: [
              shangTxt!.leiXiangStr(textGrey: scheme.onSurfaceVariant),
              xiaTxt!.leiXiangStr(textGrey: scheme.onSurfaceVariant),
            ]);
      } else {
        final shangTxt = await Db8gua.fromName(db64gua.shang);
        _bottomString =
            shangTxt!.leiXiangStr(textGrey: scheme.onSurfaceVariant);
      }
    }
    setState(() {
      _chongGua = chongGua;
    });
  }

  void _updateTitleDesc() async {
    final historyId = widget.yi?.historyId;
    if (historyId != null) {
      final savedHistory = (await DbHelper.query<DbHistory>(
              dhitory.dbName, (ls) => ls?.where((t) => t.id == historyId)))
          ?.firstOrNull;
      if (savedHistory != null) {
        dhitory = savedHistory;
        _titleStr = savedHistory.title;
        _descStr = savedHistory.describe;
      }
    }
    await _loadAiChat();
  }

  Brightness? _themeBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 主题切换时用新主题色重算底部缓存的卦辞/类象文本
    final brightness = Theme.of(context).brightness;
    if (_themeBrightness != brightness) {
      _themeBrightness = brightness;
      final chongGua = _chongGua;
      if (chongGua != null) {
        _changeChongGua(chongGua);
      }
    }
  }

  /// 加载AI对话:优先按 historyId 查,未保存排盘历史则按(上卦,下卦,变爻)查;
  /// 同一卦可能有多段对话,取最新一段。兼容旧数据:历史记录里遗留的
  /// ai_messages 首次迁移进对话表
  Future<void> _loadAiChat() async {
    if (_aiLoaded) return;
    _aiLoaded = true;
    final yi = widget.yi;
    if (yi == null) return;
    final historyId = yi.historyId;
    Iterable<DbAiChat>? rows;
    if (historyId != null) {
      rows = await DbHelper.query<DbAiChat>(
          DbAiChat.nameDb, (ls) => ls?.where((t) => t.historyId == historyId));
    } else {
      rows = await DbHelper.query<DbAiChat>(
          DbAiChat.nameDb,
          (ls) => ls?.where((t) =>
              t.historyId == null &&
              t.shang == yi.shang &&
              t.xia == yi.xia &&
              t.bian == yi.dong));
    }
    final chat = rows?.isNotEmpty == true
        ? rows!.reduce(
            (a, b) => (a.updateTime ?? 0) >= (b.updateTime ?? 0) ? a : b)
        : null;
    _aiChat = chat;
    _aiMessages = chat == null ? null : _decodeAiMessages(chat.messages);
    // 兼容旧数据:老历史记录里遗留的 ai_messages 迁移成一段新对话
    if (chat == null && dhitory.aiMessages?.isNotEmpty == true) {
      final legacy = DbAiChat()
        ..historyId = historyId
        ..shang = yi.shang
        ..xia = yi.xia
        ..bian = yi.dong
        ..messages = dhitory.aiMessages
        ..touch();
      legacy.id = await DbHelper.save(legacy);
      _aiChat = legacy;
      _aiMessages = _decodeAiMessages(legacy.messages);
    }
  }

  /// 解析对话JSON;损坏或空返回null
  List<Map<String, String>>? _decodeAiMessages(String? json) {
    if (json?.isNotEmpty != true) return null;
    try {
      final list = jsonDecode(json!) as List<dynamic>;
      return list
          .map((e) => Map<String, String>.from(e as Map))
          .toList(growable: true);
    } catch (e) {
      e.log('ai_messages 解析失败: ');
      return null;
    }
  }

  /// AI对话更新回调:实时写入对话表(不参与同步)。对话始终关联一条排盘历史
  Future<void> _onAiMessagesUpdate(List<Map<String, String>> messages) async {
    _aiMessages = messages;
    final yi = widget.yi;
    var chat = _aiChat ??= DbAiChat()
      ..historyId = yi?.historyId ?? dhitory.id
      ..shang = yi?.shang
      ..xia = yi?.xia
      ..bian = yi?.dong;
    chat.messages = jsonEncode(messages);
    chat.touch();
    await DbHelper.save(chat);
  }

  @override
  void initState() {
    _updateTitleDesc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (widget.yi == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Get.offAllNamed('/');
      });
      body = const SizedBox.shrink();
    } else {
      final zhuGua = ChongGua(
            widget.yi!.shang,
            widget.yi!.xia,
            spacing: Pan.spacing,
          ),
          huGua = ChongGua(
            widget.yi!.shang,
            widget.yi!.xia,
            spacing: Pan.spacing,
            hu: true,
            bian: widget.yi?.dong,
          ),
          bianGua = ChongGua(
            widget.yi!.shang,
            widget.yi!.xia,
            spacing: Pan.spacing,
            bian: widget.yi!.dong,
          );

      if (_chongGua == null) {
        _changeChongGua(zhuGua);
      }

      final zhu = Expanded(
            child: InkWell(
              onTap: () => _changeChongGua(zhuGua),
              child: zhuGua,
            ),
          ),
          hu = Expanded(
            child: InkWell(
              onTap: () => _changeChongGua(huGua),
              child: huGua,
            ),
          ),
          bian = Expanded(
            child: InkWell(
              onTap: () => _changeChongGua(bianGua),
              child: bianGua,
            ),
          );
      final children = [
        const LunarClock(),
        AspectRatio(
          aspectRatio: Pan.aspectRatio,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TiYong(dong: widget.yi!.dong),
              ),
              zhu,
              hu,
              bian,
            ],
          ),
        ),
        Visibility(
          visible: _chongGua?.huBian == true,
          child: const SelectableText(
            '乾坤无互，互其变卦',
            style: TextStyle(color: Colors.red),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder(
              future: _getSkText(),
              builder: (ctx, text) => text.data != null
                  ? SelectableText.rich(text.data!)
                  : const Text('')),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _middleString != null
              ? SelectableText.rich(_middleString!)
              : const Text(''),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _bottomString != null
              ? SelectableText.rich(_bottomString!)
              : const Text(''),
        ),
      ];
      final sealDate = widget.yi?.historyDate;
      if (sealDate?.isNotEmpty == true) {
        children.insert(
            0,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SelectableText('卜卦日期: $sealDate'),
            ));
      }
      body = SingleChildScrollView(
        child: Column(
          children: children,
        ),
      );
    }
    final actions = [
      PopupMenuButton(
        itemBuilder: (context) => const [
          PopupMenuItem(value: 1, child: Text('删除')),
          PopupMenuItem(value: 2, child: Text('AI解析')),
        ],
        onSelected: (value) => _actionSelected(value),
      ),
      TextButton(onPressed: () => _actionSelected(0), child: const Text('保存')),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('梅花易数盘'),
        actions: actions,
      ),
      body: SafeArea(child: body),
    );
  }

  void _actionSelected(int value) {
    'value = $value'.log();
    switch (value) {
      case 0:
        // todo 保存数据，要有弹窗
        final yi = widget.yi;
        if (yi == null) {
          '数据为空'.toast();
        } else {
          final title = EditText(
                label: '标题',
                defaultStr: _titleStr,
              ),
              desc = EditText(
                label: '详细说明',
                maxLines: 7,
                defaultStr: _descStr,
              );
          Get.generalDialog(
            pageBuilder: (context, animation1, animation2) => AlertDialog(
              title: const Text('保存'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  title,
                  desc,
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      _titleStr = title.text();
                      _descStr = desc.text();
                      Get.until((route) => Get.isDialogOpen != true);
                    },
                    child: const Text('取消')),
                TextButton(
                    onPressed: () {
                      _titleStr = title.text();
                      _descStr = desc.text();
                      _saveOrUpdate();
                    },
                    child: const Text('保存')),
              ],
              scrollable: true,
            ),
          );
        }
        break;
      case 1:
        // 删除：参考 history.dart 的软删逻辑
        final yi = widget.yi;
        final historyId = yi?.historyId ?? dhitory.id;
        if (historyId == null) {
          '当前无历史记录可删除'.toast();
        } else {
          final title = _titleStr?.isNotEmpty == true ? _titleStr! : '此记录';
          Get.generalDialog(
            pageBuilder: (context, animation1, animation2) => AlertDialog(
              title: Text('确定删除$title吗'),
              actions: [
                TextButton(
                    onPressed: () {
                      Get.until((route) => Get.isDialogOpen != true);
                    },
                    child: const Text('取消')),
                TextButton(
                    onPressed: () async {
                      dhitory.deleted = 1;
                      dhitory.touch();
                      await DbHelper.update(dhitory);
                      // 先关掉确认弹窗,再弹出 pan 页(直到当前路由不是 pan)
                      Get.until((route) => Get.isDialogOpen != true);
                      Get.until((route) => route.settings.name != 'pan');
                      '删除成功'.toast();
                      SyncHelper.scheduleAutoSync();
                    },
                    child: const Text('确定')),
              ],
            ),
          );
        }
        break;
      case 2:
        // ai提示词：弹出输入框问"问的是什么"，可生成提示词复制，也可直接提问
        final yi = widget.yi;
        if (yi == null) {
          '数据为空'.toast();
        } else {
          final question = EditText(
            label: '问事背景',
            maxLines: 3,
            defaultStr: _titleStr,
          );
          Get.generalDialog(
            pageBuilder: (context, animation1, animation2) => AlertDialog(
              title: const Text('AI解析'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [question],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Get.until((route) => Get.isDialogOpen != true);
                    },
                    child: const Text('取消')),
                TextButton(
                    onPressed: () {
                      final q = question.text();
                      Get.until((route) => Get.isDialogOpen != true);
                      _aiAsk(yi, q);
                    },
                    child: const Text('直接提问')),
                TextButton(
                    onPressed: () {
                      final q = question.text();
                      Get.until((route) => Get.isDialogOpen != true);
                      final prompt = buildAiPrompt(
                        yi: yi,
                        date: dhitory.saveDate?.dateStr() ??
                            widget.now.millisecondsSinceEpoch.dateStr(),
                        question: q,
                      );
                      Get.to(() => AiPromptPage(prompt: prompt));
                    },
                    child: const Text('生成AI提示词')),
              ],
              scrollable: true,
            ),
          );
        }
        break;
      default:
        break;
    }
  }

  /// 直接提问:对话开始前若还没有排盘历史则先自动保存一条(标题用"本卦之变卦"),
  /// 确保对话始终挂在排盘历史上;已有对话历史则直接打开聊天页查看/追问,
  /// 否则按设定提示词发起首次AI解析(对话框填的"问事背景"作为背景)
  Future<void> _aiAsk(Yi yi, String question) async {
    await _loadAiChat();
    if (dhitory.id == null) await _autoSaveHistory(question);
    final systemPrompt = buildAiSystemPrompt();
    final messages = _aiMessages;
    if (messages.isNoneEmpty) {
      // 旧数据遗留的未关联对话,顺手挂到新保存的排盘历史下
      final chat = _aiChat;
      if (chat != null && chat.historyId == null) {
        chat.historyId = dhitory.id;
        await DbHelper.update(chat);
      }
      Get.to(() => AiResultPage(
            systemPrompt: systemPrompt,
            initialMessages: messages,
            onUpdate: _onAiMessagesUpdate,
          ));
      return;
    }
    final config = await AiHelper.loadConfig();
    final content = AiHelper.buildUserContent(
        config,
        buildAiUserContent(
          yi: yi,
          date: dhitory.saveDate?.dateStr() ??
              widget.now.millisecondsSinceEpoch.dateStr(),
          question: question.isBlank ? _titleStr : question,
        ));
    Get.to(() => AiResultPage(
          systemPrompt: systemPrompt,
          pendingUserContent: content,
          onUpdate: _onAiMessagesUpdate,
        ));
  }

  /// 自动保存一条排盘历史,标题默认"本卦之变卦"
  Future<void> _autoSaveHistory([String? title]) async {
    final yi = widget.yi;
    if (yi == null) return;
    final gua = yi.gua();
    _titleStr ??= (title ?? '${gua[0].name()}之${gua[2].name()}');
    dhitory.shang ??= yi.shang;
    dhitory.xia ??= yi.xia;
    dhitory.bian ??= yi.dong;
    dhitory.title = _titleStr!;
    dhitory.saveDate ??= widget.now.millisecondsSinceEpoch;
    dhitory.lunarDate ??= widget.now.toLunar().niceStr();
    dhitory.ensureSyncHash();
    dhitory.touch();
    dhitory.id = await DbHelper.save(dhitory);
    SyncHelper.scheduleAutoSync();
    '已自动保存排盘历史'.toast();
  }

  void _saveOrUpdate() async {
    if (_titleStr!.isEmpty) {
      '标题不能为空'.toast();
    } else {
      if (dhitory.id == null) {
        await _saveHistory();
      } else {
        await _updateHistory();
      }

      Get.until((route) => Get.isDialogOpen != true);
      '保存成功'.toast();
    }
  }

  Future<void> _saveHistory() async {
    dhitory.shang ??= widget.yi?.shang;
    dhitory.xia ??= widget.yi?.xia;
    dhitory.bian ??= widget.yi?.dong;
    dhitory.title = _titleStr!;
    dhitory.saveDate ??= widget.now.millisecondsSinceEpoch;
    dhitory.lunarDate ??= widget.now.toLunar().niceStr();
    dhitory.describe = _descStr;
    dhitory.ensureSyncHash();
    dhitory.touch();
    dhitory.id = await DbHelper.save(dhitory);

    // 保存排盘历史后,把对话表里未关联的记录挂到新历史id下
    final chat = _aiChat;
    if (chat != null && chat.historyId == null) {
      chat.historyId = dhitory.id;
      await DbHelper.update(chat);
    }

    SyncHelper.scheduleAutoSync();
  }

  Future<void> _updateHistory() async {
    dhitory.title = _titleStr!;
    dhitory.describe = _descStr;
    dhitory.ensureSyncHash();
    dhitory.touch();
    await DbHelper.update(dhitory);
    SyncHelper.scheduleAutoSync();
  }
}
