import 'package:meihua/entity/database/base.dart';
import 'package:meihua/util/db_helper.dart';

class Db8gua extends Base {
  static const nameDb = '`8gua`';
  @override
  String get dbName => nameDb;

  int? id, xianTianShu, houTianShu;
  String? name,
      shuLei,
      leiXiang,
      guaQiWang,
      guaQiShuai,
      xianTianFangWei,
      houTianFangWei;

  @override
  void fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    shuLei = map['shu_lei'];
    leiXiang = map['lei_xiang'];
    guaQiWang = map['gua_qi_wang'];
    guaQiShuai = map['gua_qi_shuai'];
    xianTianFangWei = map['xian_tian_fang_wei'];
    houTianFangWei = map['hou_tian_fang_wei'];
    xianTianShu = map['xian_tian_shu'];
    houTianShu = map['hou_tian_shu'];
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['shu_lei'] = shuLei;
    map['lei_xiang'] = leiXiang;
    map['gua_qi_wang'] = guaQiWang;
    map['gua_qi_shuai'] = guaQiShuai;
    map['xian_tian_fang_wei'] = xianTianFangWei;
    map['hou_tian_fang_wei'] = houTianFangWei;
    map['xian_tian_shu'] = xianTianShu;
    map['hou_tian_shu'] = houTianShu;
    return map;
  }

  String toText() {
    return '''旺于$guaQiWang
衰于$guaQiShuai
$shuLei
以占卦的人为中心，$houTianFangWei为$name''';
  }

  static Future<Db8gua?> fromName(String? name) async {
    if (name?.isNotEmpty == true) {
      final db8guas = await DbHelper.query(Db8gua.nameDb,
          where: 'name = ?', whereArgs: [name], limit: 1);
      if (db8guas.isEmpty) return null;
      return Db8gua()..fromMap(db8guas[0]);
    }
    return null;
  }
}
