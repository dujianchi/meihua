import 'dart:ffi';

import 'package:meihua/enum/database/base.dart';

class DbConfig extends Base {
  static const nameDb = 'config';
  @override
  String get dbName => nameDb;

  Int? id;
  String? key, val;

  @override
  void fromMap(Map<String, dynamic> map) {
    id = map['id'];
    key = map['key'];
    val = map['val'];
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['key'] = key;
    map['val'] = val;
    return map;
  }
}
