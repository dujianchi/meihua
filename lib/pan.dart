import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/document.dart';
import 'package:meihua/util/exts.dart';
import 'package:meihua/widget/chong_gua.dart';
import 'package:meihua/widget/edit_text.dart';

import 'widget/lunar_clock.dart';

class Pan extends StatelessWidget {
  static const double spacing = 3;
  static const double aspectRatio = 2.1;
  static final _cache = {};
  const Pan({super.key});

  static Future<String?> _getCacheStr(String doc) async {
    var str = _cache[doc];
    if (str == null) {
      str = await Document.read(doc);
      _cache[doc] = str;
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    final yi = ModalRoute.of(context)?.settings.arguments as Yi?;
    return _Pan(yi);
  }
}

class _Pan extends StatefulWidget {
  final Yi? yi;
  const _Pan(this.yi);

  @override
  State<StatefulWidget> createState() => _PanState();
}

class _PanState extends State<_Pan> {
  ChongGua? _chongGua;
  String? _bottomString;

  String _getSkText() {
    final dong = widget.yi!.dong;
    final str = dong > 3 ? '上卦为用，下卦为体；' : '下卦为用，上卦为体；';
    return str + (_chongGua?.tiyong(dong) ?? '');
  }

  void _changeChongGua(ChongGua chongGua) {
    _chongGua = chongGua;
    Pan._getCacheStr('src/重卦/${chongGua.gua()?.name()}.txt').then((value) {
      setState(() {
        _bottomString = value;
      });
    });
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
        Padding(
          padding: const EdgeInsets.all(10),
          child: SelectableText(_getSkText()),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: SelectableText(_bottomString ?? ''),
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
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 0, child: Text('保存')),
              ],
              onSelected: (value) => _actionSelected(value),
            )
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
          final title = EditText(label: '标题'),
              desc = EditText(
                label: '详细说明',
                maxLines: 3,
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
                    onPressed: () =>
                        Get.until((route) => Get.isDialogOpen != true),
                    child: const Text('取消')),
                TextButton(
                    onPressed: () {
                      final titleText = title.text();
                      if (titleText.isEmpty) {
                        '标题不能为空'.toast();
                      } else {
                        DbHelper.save(
                          shang: yi.shang,
                          xia: yi.xia,
                          bian: yi.dong,
                          title: titleText,
                          saveDate: DateTime.now().millisecondsSinceEpoch,
                          describe: desc.text(),
                        );
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
