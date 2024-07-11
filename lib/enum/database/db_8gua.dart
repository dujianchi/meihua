import 'package:meihua/enum/database/base.dart';

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
}
