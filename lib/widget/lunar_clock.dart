import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meihua/util/exts.dart';

/// 农历时间显示
class LunarClock extends StatefulWidget {
  const LunarClock({super.key});

  @override
  State<StatefulWidget> createState() => _LunarClockState();
}

class _LunarClockState extends State<LunarClock> {
  var _current = DateTime.now();
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    // 创建一个每秒执行一次的定时器
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTime);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime(Timer timer) {
    // 获取当前时间，并更新状态
    setState(() {
      _current = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lunar = _current.toLunar();
    return SelectableText(
      '当前农历时间: ${lunar.niceStr()}',
      // style: const TextStyle(fontSize: 20.0),
    );
  }
}
