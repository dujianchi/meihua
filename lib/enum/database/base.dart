/// 基础数据库类
abstract class Base {
  abstract final String dbName;
  void fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap();
}
