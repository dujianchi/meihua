import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef StringCallback = void Function(String? string);

class Document {
  static Future<String?> read(String filename, [bool trim = true]) async {
    String? txt;
    try {
      txt = await rootBundle.loadString('assets/$filename');
      if (trim) txt = txt.trim();
    } catch (ex) {
      debugPrint('read $filename error : $ex');
    }
    debugPrint('read $filename -->  $txt');
    return txt;
  }

  // static void readSync(String filename, StringCallback callback) {
  //   read(filename).then((value) => callback(value));
  // }
}
