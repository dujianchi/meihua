import 'package:flutter/material.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/util/consts.dart';
import 'package:meihua/widget/chong_gua.dart';

import 'widget/lunar_clock.dart';

class Pan extends StatelessWidget {
  static const double spacing = 3;
  static const double aspectRatio = 2.1;
  const Pan({super.key});

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

  String _getText() {
    return Consts.chongGuaStr2[_chongGua?.gua()?.name() ?? ''] ?? '';
  }

  String _getSkText() {
    final dong = widget.yi!.dong;
    final str = dong > 3 ? '上卦为用，下卦为体；' : '下卦为用，上卦为体；';
    return str + (_chongGua?.tiyong(dong) ?? '');
  }

  void _changeChongGua(ChongGua chongGua) {
    setState(() {
      _chongGua = chongGua;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (widget.yi == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.of(context).pushReplacementNamed('/');
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

      _chongGua ??= zhuGua;

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
          child: SelectableText(_getText()),
        ),
      ];
      body = SingleChildScrollView(
        child: Column(
          children: children,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('梅花易数盘')),
      body: body,
    );
  }
}
