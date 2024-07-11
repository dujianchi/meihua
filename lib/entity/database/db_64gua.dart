import 'package:meihua/entity/database/base.dart';

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
}
