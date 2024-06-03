import 'package:flutter/material.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('排盘历史'),
      ),
      body: const Center(
        child: Text('排盘历史<开发中>'),
      ),
    );
  }
}
