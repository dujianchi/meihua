import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditText extends StatelessWidget {
  final String _label;
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
  }) : _label = label;

  String text() => _textChanged.text;
  String trim() => text().trim();

  @override
  Widget build(BuildContext context) => TextField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        controller: _textChanged,
        decoration: InputDecoration(
            labelText: _label,
            labelStyle: const TextStyle(color: Colors.purple)),
      );
}

class EditTextNum extends EditText {
  EditTextNum({super.key, required super.label})
      : super(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly]);
}
