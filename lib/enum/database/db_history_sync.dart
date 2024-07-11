import 'package:meihua/enum/database/base.dart';

class DbHistorySync extends Base {
  static const nameDb = 'history_sync';
  @override
  String get dbName => nameDb;

  int? id, createTime, operate, uploaded;
  String? whereParam, whereArgs, data;

  @override
  void fromMap(Map<String, dynamic> map) {
    id = map['id'];
    createTime = map['create_time'];
    operate = map['operate'];
    uploaded = map['uploaded'];
    whereParam = map['where_param'];
    whereArgs = map['where_args'];
    data = map['data'];
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['create_time'] = createTime;
    map['operate'] = operate;
    map['uploaded'] = uploaded;
    map['where_param'] = whereParam;
    map['where_args'] = whereArgs;
    map['data'] = data;
    return map;
  }
}
