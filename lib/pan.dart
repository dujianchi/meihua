import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:meihua/entity/database/db_64gua.dart';
import 'package:meihua/entity/database/db_8gua.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';
import 'package:meihua/util/sync_helper.dart';
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
  TextSpan? _middleString, _bottomString;

  Future<TextSpan> _getSkText() async {
    final dong = widget.yi!.dong;
    final gua64 = _chongGua?.gua();
    if (gua64?.shang != gua64?.xia) {
      final shang8 = await Db8gua.fromName(gua64?.shang.name),
          xia8 = await Db8gua.fromName(gua64?.xia.name);
      return TextSpan(
          text: gua64?.tiyong(dong),
          children: [shang8!.toText(), xia8!.toText()]);
    } else {
      final shang8 = await Db8gua.fromName(gua64?.shang.name);
      return TextSpan(text: gua64?.tiyong(dong), children: [shang8!.toText()]);
    }
  }

  void _changeChongGua(ChongGua chongGua) async {
    final db64gua = await Db64gua.fromFullname(chongGua.gua()!.name());
    if (db64gua != null) {
      _middleString = db64gua.toText(dong: chongGua.hu ? null : chongGua.bian);
      if (db64gua.shang != db64gua.xia) {
        final shangTxt = await Db8gua.fromName(db64gua.shang),
            xiaTxt = await Db8gua.fromName(db64gua.xia);
        _bottomString = TextSpan(
            children: [shangTxt!.leiXiangStr(), xiaTxt!.leiXiangStr()]);
      } else {
        final shangTxt = await Db8gua.fromName(db64gua.shang);
        _bottomString = shangTxt!.leiXiangStr();
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
          PopupMenuItem(value: 0, child: Text('保存')),
          PopupMenuItem(value: 1, child: Text('删除')),
          PopupMenuItem(value: 2, child: Text('ai提示词')),
        ],
        onSelected: (value) => _actionSelected(value),
      )
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
        final historyId = yi?.historyId;
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
        // ai提示词：弹出输入框问"问的是什么"，跳转到提示词展示页
        final yi = widget.yi;
        if (yi == null) {
          '数据为空'.toast();
        } else {
          final question = EditText(
            label: '问的是什么',
            maxLines: 3,
            defaultStr: _titleStr,
          );
          Get.generalDialog(
            pageBuilder: (context, animation1, animation2) => AlertDialog(
              title: const Text('ai提示词'),
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
                      final prompt = buildAiPrompt(
                        shang: yi.shang,
                        xia: yi.xia,
                        dong: yi.dong,
                        question: q,
                      );
                      Get.to(() => AiPromptPage(prompt: prompt));
                    },
                    child: const Text('生成')),
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
    await DbHelper.save(dhitory);

    if (dhitory.id == null) {
      final saved = await DbHelper.query<DbHistory>(dhitory.dbName,
          (ls) => ls?.where((t) => t.syncHash == dhitory.syncHash));
      final id = saved?.firstOrNull?.id?.toString().toInt(-1);
      if (id != null && id > 0) {
        dhitory.id = id;
      }
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
