import 'package:flutter/material.dart';
import 'package:meihua/util/document.dart';

class DocTextSelectable extends StatefulWidget {
  static final _cache = {};

  final String document;

  const DocTextSelectable(this.document, {super.key});

  Future<String?> _getCacheStr(String doc) async {
    var str = _cache[doc];
    if (str == null) {
      str = await Document.read(doc);
      _cache[doc] = str;
    }
    return str;
  }

  @override
  State<StatefulWidget> createState() => _DocTextSelectableState();
}

class _DocTextSelectableState extends State<DocTextSelectable> {
  String? _text;
  @override
  void initState() {
    widget._getCacheStr(widget.document).then((value) {
      setState(() {
        _text = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_text?.isNotEmpty == true) {
      return SelectableText(_text!);
    } else {
      return Container();
    }
  }
}
