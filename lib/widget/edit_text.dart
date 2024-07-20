import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditText extends StatelessWidget {
  final String _label;
  final String? _defaultStr;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final bool selectAllAfterRequestedFocus; // 当获取焦点时，选中所有文本

  final TextEditingController _textChanged = TextEditingController();
  EditText({
    super.key,
    required String label,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines,
    String? defaultStr,
    this.obscureText = false,
    this.focusNode,
    this.onSubmitted,
    this.selectAllAfterRequestedFocus = false,
  })  : _label = label,
        _defaultStr = defaultStr,
        assert(!selectAllAfterRequestedFocus || focusNode != null);

  String text() => _textChanged.text;
  String trim() => text().trim();

  void dispose() {
    focusNode?.dispose();
    _textChanged.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_defaultStr?.isNotEmpty == true) {
      _textChanged.text = _defaultStr!;
    }
    focusNode?.removeListener(_selectionAll);
    focusNode?.addListener(_selectionAll);
    final textField = TextField(
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      controller: _textChanged,
      decoration: InputDecoration(
          labelText: _label, labelStyle: const TextStyle(color: Colors.purple)),
      focusNode: focusNode,
      onSubmitted: onSubmitted,
    );
    return textField;
  }

  void _selectionAll() {
    if (focusNode?.hasFocus == true) {
      _textChanged.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textChanged.text.length,
      );
    }
  }
}

class EditTextNum extends EditText {
  EditTextNum({
    super.key,
    required super.label,
    super.focusNode,
    super.onSubmitted,
    super.selectAllAfterRequestedFocus,
  }) : super(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly]);
}
