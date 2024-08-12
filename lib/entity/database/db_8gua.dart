import 'package:flutter/material.dart';
import 'package:meihua/entity/database/base.dart';
import 'package:meihua/util/db_helper.dart';

// @JsonCodable()
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

  TextSpan toText({double fontSize = 14.0}) {
    final children = <InlineSpan>[];
    final grey = TextStyle(color: Colors.grey, fontSize: fontSize),
        red = TextStyle(color: Colors.red, fontSize: fontSize + 2);
    children.add(TextSpan(text: '\n$name ', style: red));
    children.add(TextSpan(text: '''旺于$guaQiWang，衰于$guaQiShuai
$shuLei
以占卦的人为中心，$houTianFangWei为$name\n''', style: grey));
    return TextSpan(children: children);
  }

  TextSpan leiXiangStr({double fontSize = 14.0}) {
    final children = <InlineSpan>[];
    final grey = TextStyle(color: Colors.grey, fontSize: fontSize),
        red = TextStyle(color: Colors.red, fontSize: fontSize + 2);
    children.add(TextSpan(text: '$name\n', style: red));
    children.add(TextSpan(text: '$leiXiang\n', style: grey));
    return TextSpan(children: children);
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
