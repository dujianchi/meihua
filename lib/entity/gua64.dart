import 'package:json/json.dart';
import 'package:meihua/enum/ba_gua.dart';
import 'package:meihua/enum/sheng_ke_bihe.dart';

/// 64重卦：上卦、下卦
@JsonCodable()
class Gua64 {
  final BaGua shang, xia;
  Gua64({
    required this.shang,
    required this.xia,
  });

  String name() {
    switch (shang) {
      case BaGua.qian:
        switch (xia) {
          case BaGua.qian:
            return '乾为天';
          case BaGua.dui:
            return '天泽履';
          case BaGua.li:
            return '天火同人';
          case BaGua.zhen:
            return '天雷无妄';
          case BaGua.xun:
            return '天风姤';
          case BaGua.kan:
            return '天水讼';
          case BaGua.gen:
            return '天山遁';
          case BaGua.kun:
            return '天地否';
        }
      case BaGua.dui:
        switch (xia) {
          case BaGua.qian:
            return '泽天夬';
          case BaGua.dui:
            return '兑为泽';
          case BaGua.li:
            return '泽火革';
          case BaGua.zhen:
            return '泽雷随';
          case BaGua.xun:
            return '泽风大过';
          case BaGua.kan:
            return '泽水困';
          case BaGua.gen:
            return '泽山咸';
          case BaGua.kun:
            return '泽地萃';
        }
      case BaGua.li:
        switch (xia) {
          case BaGua.qian:
            return '火天大有';
          case BaGua.dui:
            return '火泽睽';
          case BaGua.li:
            return '离为火';
          case BaGua.zhen:
            return '火雷噬嗑';
          case BaGua.xun:
            return '火风鼎';
          case BaGua.kan:
            return '火水未济';
          case BaGua.gen:
            return '火山旅';
          case BaGua.kun:
            return '火地晋';
        }
      case BaGua.zhen:
        switch (xia) {
          case BaGua.qian:
            return '雷天大壮';
          case BaGua.dui:
            return '雷泽归妹';
          case BaGua.li:
            return '雷火丰';
          case BaGua.zhen:
            return '震为雷';
          case BaGua.xun:
            return '雷风恒';
          case BaGua.kan:
            return '雷水解';
          case BaGua.gen:
            return '雷山小过';
          case BaGua.kun:
            return '雷地豫';
        }
      case BaGua.xun:
        switch (xia) {
          case BaGua.qian:
            return '风天小畜';
          case BaGua.dui:
            return '风泽中孚';
          case BaGua.li:
            return '风火家人';
          case BaGua.zhen:
            return '风雷益';
          case BaGua.xun:
            return '巽为风';
          case BaGua.kan:
            return '风水涣';
          case BaGua.gen:
            return '风山渐';
          case BaGua.kun:
            return '风地观';
        }
      case BaGua.kan:
        switch (xia) {
          case BaGua.qian:
            return '水天需';
          case BaGua.dui:
            return '水泽节';
          case BaGua.li:
            return '水火既济';
          case BaGua.zhen:
            return '水雷屯';
          case BaGua.xun:
            return '水风井';
          case BaGua.kan:
            return '坎为水';
          case BaGua.gen:
            return '水山蹇';
          case BaGua.kun:
            return '水地比';
        }
      case BaGua.gen:
        switch (xia) {
          case BaGua.qian:
            return '山天大畜';
          case BaGua.dui:
            return '山泽损';
          case BaGua.li:
            return '山火贲';
          case BaGua.zhen:
            return '山雷颐';
          case BaGua.xun:
            return '山风蛊';
          case BaGua.kan:
            return '山水蒙';
          case BaGua.gen:
            return '艮为山';
          case BaGua.kun:
            return '山地剥';
        }
      case BaGua.kun:
        switch (xia) {
          case BaGua.qian:
            return '地天泰';
          case BaGua.dui:
            return '地泽临';
          case BaGua.li:
            return '地火明夷';
          case BaGua.zhen:
            return '地雷复';
          case BaGua.xun:
            return '地风升';
          case BaGua.kan:
            return '地水师';
          case BaGua.gen:
            return '地山谦';
          case BaGua.kun:
            return '坤为地';
        }
    }
  }

  String tiyong(int dong) {
    final BaGua? ti, yong;
    if (dong > 3) {
      ti = xia;
      yong = shang;
    } else {
      ti = shang;
      yong = xia;
    }
    final tk = ti.wuXing.shengKeBihe(yong.wuXing);
    final String tks;
    switch (tk) {
      case ShengKeBihe.shengWo:
        tks = '用生体，有补益，吉';
        break;
      case ShengKeBihe.keWo:
        tks = '用克体，不利';
        break;
      case ShengKeBihe.woSheng:
        tks = '体生用，有损耗';
        break;
      case ShengKeBihe.woKe:
        tks = '体克用，利，吉';
        break;
      case ShengKeBihe.bihe:
        tks = '体用比和，吉';
        break;
    }
    return '体${ti.name}(${ti.wuXing.name})，用${yong.name}(${yong.wuXing.name})，$tks';
  }
}
