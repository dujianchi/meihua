import 'package:flutter/material.dart';
import 'package:meihua/entity/database/base.dart';
import 'package:meihua/util/db_helper.dart';

class Db64gua extends Base {
  static const nameDb = '`64gua`';
  @override
  String get dbName => nameDb;
  int? id;
  String? name,
      fullName,
      shang,
      xia,
      guaCi,
      guaCiJs,
      chuYao,
      chuYaoJs,
      erYao,
      erYaoJs,
      sanYao,
      sanYaoJs,
      siYao,
      siYaoJs,
      wuYao,
      wuYaoJs,
      shangYao,
      shangYaoJs;

  @override
  void fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    fullName = map['full_name'];
    shang = map['shang'];
    xia = map['xia'];
    guaCi = map['gua_ci'];
    guaCiJs = map['gua_ci_js'];
    chuYao = map['chu_yao'];
    chuYaoJs = map['chu_yao_js'];
    erYao = map['er_yao'];
    erYaoJs = map['er_yao_js'];
    sanYao = map['san_yao'];
    sanYaoJs = map['san_yao_js'];
    siYao = map['si_yao'];
    siYaoJs = map['si_yao_js'];
    wuYao = map['wu_yao'];
    wuYaoJs = map['wu_yao_js'];
    shangYao = map['shang_yao'];
    shangYaoJs = map['shang_yao_js'];
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['full_name'] = fullName;
    map['shang'] = shang;
    map['xia'] = xia;
    map['gua_ci'] = guaCi;
    map['gua_ci_js'] = guaCiJs;
    map['chu_yao'] = chuYao;
    map['chu_yao_js'] = chuYaoJs;
    map['er_yao'] = erYao;
    map['er_yao_js'] = erYaoJs;
    map['san_yao'] = sanYao;
    map['san_yao_js'] = sanYaoJs;
    map['si_yao'] = siYao;
    map['si_yao_js'] = siYaoJs;
    map['wu_yao'] = wuYao;
    map['wu_yao_js'] = wuYaoJs;
    map['shang_yao'] = shangYao;
    map['shang_yao_js'] = shangYaoJs;
    return map;
  }

  TextSpan toText([int? dong]) {
    final children = <InlineSpan>[];
    final black = const TextStyle(color: Colors.black),
        grey = const TextStyle(color: Colors.grey),
        redLighter = TextStyle(color: Colors.redAccent[100]),
        red = const TextStyle(color: Colors.red);
    final yao = [guaCi, chuYao, erYao, sanYao, siYao, wuYao, shangYao];
    final yaoJs = [
      guaCiJs,
      chuYaoJs,
      erYaoJs,
      sanYaoJs,
      siYaoJs,
      wuYaoJs,
      shangYaoJs
    ];
    for (var i = 0; i < yao.length; i++) {
      if (dong == i) {
        children.add(TextSpan(text: '${yao[i]}\n', style: red));
        children.add(TextSpan(text: '${yaoJs[i]}\n', style: redLighter));
      } else {
        children.add(TextSpan(text: '${yao[i]}\n', style: black));
        children.add(TextSpan(text: '${yaoJs[i]}\n', style: grey));
      }
    }
    return TextSpan(children: children);
  }

  static Future<Db64gua?> fromFullname(String? fullName) async {
    if (fullName?.isNotEmpty == true) {
      final db64guas = await DbHelper.query(Db64gua.nameDb,
          where: 'full_name = ?', whereArgs: [fullName], limit: 1);
      if (db64guas.isNotEmpty) {
        return Db64gua()..fromMap(db64guas[0]);
      }
    }
    return null;
  }
}
