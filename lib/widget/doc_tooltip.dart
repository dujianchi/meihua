import 'package:flutter/material.dart';
import 'package:meihua/util/document.dart';

class DocTooltip extends StatelessWidget {
  static final _cache = {};

  final String document;
  final Widget widget;

  const DocTooltip({super.key, required this.document, required this.widget});

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
        future: _getCacheStr(document),
        builder: (ctx, str) {
          if (str.connectionState == ConnectionState.done &&
              str.data?.isNotEmpty == true) {
            return Tooltip(
              message: str.data,
              child: widget,
            );
          } else {
            return widget;
          }
        },
      );

  Future<String?> _getCacheStr(String doc) async {
    var str = _cache[doc];
    if (str == null) {
      str = await Document.read(doc);
      _cache[doc] = str;
    }
    return str;
  }
}
