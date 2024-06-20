import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditText extends StatelessWidget {
  final String _label;
  final String? _defaultStr;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  final TextEditingController _textChanged = TextEditingController();
  EditText({
    super.key,
    required String label,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines,
    String? defaultStr,
  })  : _label = label,
        _defaultStr = defaultStr;

  String text() => _textChanged.text;
  String trim() => text().trim();

  @override
  Widget build(BuildContext context) {
    if (_defaultStr?.isNotEmpty == true) {
      _textChanged.text = _defaultStr!;
    }
    final textField = TextField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      controller: _textChanged,
      decoration: InputDecoration(
          labelText: _label, labelStyle: const TextStyle(color: Colors.purple)),
    );
    return textField;
  }
}

class EditTextNum extends EditText {
  EditTextNum({super.key, required super.label})
      : super(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly]);
}
