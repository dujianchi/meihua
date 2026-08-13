import 'package:meihua/entity/database/base.dart';
import 'package:meihua/util/exts.dart';

// @JsonCodable()
class DbHistory extends Base {
  static const nameDb = 'history';
  @override
  String get dbName => nameDb;

  @override
  int? id;
  int? saveDate, shang, xia, bian;
  /// 最近一次修改时间(毫秒),用作同步 last-write-wins 的版本号
  int? updateTime;
  /// 软删标记:0/空=正常,1=已删除(列表不展示,但快照里保留以传播删除)
  int? deleted;
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
    updateTime = map['update_time'];
    deleted = map['deleted'];
  }

  @override
  Map<String, dynamic> toMap() {
    ensureSyncHash();
    final map = <String, dynamic>{};
    map['id'] = id;
    map['save_date'] = saveDate;
    map['lunar_date'] = lunarDate;
    map['shang'] = shang;
    map['xia'] = xia;
    map['bian'] = bian;
    map['title'] = title;
    map['describe'] = describe;
    map['sync_hash'] = syncHash;
    map['update_time'] = updateTime;
    map['deleted'] = deleted;
    return map;
  }

  /// 计算并固化 syncHash(仅首次为空时计算,之后不再随内容变化),
  /// 用作跨设备同步的身份键。必须在落盘前调用,否则磁盘上会存 null,
  /// 重启后被 toMap 用已编辑的内容重算 → 与云端 op1 里的 hash 对不上,
  /// 导致同步时按 syncHash 找不到记录、编辑回放失效。
  void ensureSyncHash() {
    if (syncHash?.isNotEmpty != true) {
      final map = <String, dynamic>{};
      map['id'] = id;
      map['save_date'] = saveDate;
      map['lunar_date'] = lunarDate;
      map['shang'] = shang;
      map['xia'] = xia;
      map['bian'] = bian;
      map['title'] = title;
      map['describe'] = describe;
      syncHash = map.toString().md5();
    }
  }

  DbHistory fill() {
    final now = DateTime.now();
    saveDate ??= now.millisecondsSinceEpoch;
    if (lunarDate == null) {
      final lunar = now.toLunar();
      lunarDate = lunar.niceStr();
    }
    updateTime ??= now.millisecondsSinceEpoch;
    return this;
  }

  /// 刷新修改时间,标记本条为最新版本(同步时用于 last-write-wins)
  void touch() {
    updateTime = DateTime.now().millisecondsSinceEpoch;
  }

  /// 软删并瘦身:仅保留同步所需字段(sync_hash/update_time/deleted/save_date),
  /// 其余置空,避免已删数据撑大同步文件。touch=false 用于存量墓碑迁移,
  /// 不刷新版本号,避免破坏 last-write-wins 语义
  void tombstone({bool touch = true}) {
    deleted = 1;
    if (touch) this.touch();
    lunarDate = null;
    title = null;
    describe = null;
    shang = null;
    xia = null;
    bian = null;
  }

  /// 是否已是精简墓碑(用于迁移时跳过已瘦身的记录)
  bool get isStrippedTombstone =>
      deleted == 1 &&
      title == null &&
      describe == null &&
      shang == null &&
      xia == null &&
      bian == null;
}
