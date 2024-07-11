import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/route_manager.dart';
import 'package:lunar/lunar.dart';
import 'package:meihua/entity/database/db_64gua.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';
import 'package:meihua/widget/chong_gua.dart';
import 'package:meihua/widget/edit_text.dart';

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
  ChongGua? _chongGua;
  String? _titleStr, _descStr;
  TextSpan? _bottomString;

  String _getSkText() {
    final dong = widget.yi!.dong;
    final str = dong > 3 ? '上卦为用，下卦为体；' : '下卦为用，上卦为体；';
    return str + (_chongGua?.tiyong(dong) ?? '');
  }

  void _changeChongGua(ChongGua chongGua) async {
    _chongGua = chongGua;
    final db64gua = await Db64gua.fromFullname(chongGua.gua()!.name());
    if (db64gua != null) {
      setState(() {
        _bottomString = db64gua.toText(chongGua.hu ? null : chongGua.bian);
      });
    }
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
          child: SelectableText(_getSkText()),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
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
    final actions = widget.yi?.historyDate?.isNotEmpty == true
        ? <Widget>[]
        : [
            // PopupMenuButton(
            //   itemBuilder: (context) => [
            //     const PopupMenuItem(value: 0, child: Text('保存')),
            //   ],
            //   onSelected: (value) => _actionSelected(value),
            // )
            TextButton(
                onPressed: () => _actionSelected(0), child: const Text('保存'))
          ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('梅花易数盘'),
        actions: actions,
      ),
      body: body,
    );
  }

  void _actionSelected(int value) {
    debugPrint('value = $value');
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
                maxLines: 3,
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
                      if (_titleStr!.isEmpty) {
                        '标题不能为空'.toast();
                      } else {
                        final dhitory = DbHistory();
                        dhitory.shang = yi.shang;
                        dhitory.xia = yi.xia;
                        dhitory.bian = yi.dong;
                        dhitory.title = _titleStr!;
                        dhitory.saveDate = widget.now.millisecondsSinceEpoch;
                        dhitory.lunarDate =
                            Lunar.fromDate(widget.now).niceStr();
                        dhitory.describe = _descStr;
                        DbHelper.save(dhitory);
                        Get.until((route) => Get.isDialogOpen != true);
                        '保存成功'.toast();
                      }
                    },
                    child: const Text('保存')),
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
}
