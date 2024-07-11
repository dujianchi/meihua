import 'package:lunar/calendar/Lunar.dart';
import 'package:meihua/entity/database/base.dart';
import 'package:meihua/util/exts.dart';

class DbHistory extends Base {
  static const nameDb = 'history';
  @override
  String get dbName => nameDb;

  int? id, saveDate, shang, xia, bian;
  String? lunarDate, title, describe, syncHash;

  @override
  void fromMap(Map<String, dynamic> map) {
    id = map['id'];
    saveDate = map['save_date'];
    lunarDate = map['lunar_date'];
    shang = map['shang'];
    xia = map['xia'];
    bian = map['bian'];
    title = map['title'];
    describe = map['describe'];
    syncHash = map['sync_hash'];
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['save_date'] = saveDate;
    map['lunar_date'] = lunarDate;
    map['shang'] = shang;
    map['xia'] = xia;
    map['bian'] = bian;
    map['title'] = title;
    map['describe'] = describe;
    if (syncHash?.isNotEmpty != true) {
      syncHash = map.toString().md5();
    }
    map['sync_hash'] = syncHash;
    return map;
  }

  DbHistory fill() {
    final now = DateTime.now();
    saveDate ??= now.millisecondsSinceEpoch;
    if (lunarDate == null) {
      final lunar = Lunar.fromDate(now);
      lunarDate = lunar.niceStr();
    }
    return this;
  }
}
