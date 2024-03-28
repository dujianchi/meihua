import 'package:flutter/material.dart';

class TuWen extends StatelessWidget {
  const TuWen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('64卦图文'),
      ),
      body: const Center(
        child: Text('64卦图文<开发中>'),
      ),
    );
  }
}
