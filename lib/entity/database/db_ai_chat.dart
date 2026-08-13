import 'package:meihua/entity/database/base.dart';
import 'package:meihua/util/exts.dart';

/// AI对话记录:每个卦(或已保存的排盘历史)一条,实时保存。
/// 通过 historyId 关联已保存的排盘历史;未保存时 historyId 为空,
/// 按 (shang, xia, bian) 匹配同一卦的对话。
/// 同步:独立于排盘历史,单独同步文件,采用同样的快照+LWW模型
class DbAiChat extends Base {
  static const nameDb = 'ai_chat';
  @override
  String get dbName => nameDb;

  @override
  int? id;
  /// 关联的排盘历史id,未保存排盘历史时为空
  int? historyId;
  int? shang, xia, bian;
  /// 对话内容(JSON字符串, [{role, content}...]),不裁剪
  String? messages;
  /// 最近更新时间(毫秒),用于多行时取最新
  int? updateTime;
  /// 同步身份键:内容md5,计算一次后固定(同排盘历史的 ensureSyncHash)
  String? syncHash;
  /// 软删标记:0/空=正常,1=已删除(列表不展示,但快照里保留以传播删除)
  int? deleted;

  @override
  void fromMap(Map<String, dynamic> map) {
    id = map['id'];
    historyId = map['history_id'];
    shang = map['shang'];
    xia = map['xia'];
    bian = map['bian'];
    messages = map['messages'];
    updateTime = map['update_time'];
    syncHash = map['sync_hash'];
    deleted = map['deleted'];
  }

  @override
  Map<String, dynamic> toMap() {
    ensureSyncHash();
    final map = <String, dynamic>{};
    map['id'] = id;
    map['history_id'] = historyId;
    map['shang'] = shang;
    map['xia'] = xia;
    map['bian'] = bian;
    map['messages'] = messages;
    map['update_time'] = updateTime;
    map['sync_hash'] = syncHash;
    map['deleted'] = deleted;
    return map;
  }

  /// 计算并固化 syncHash(仅首次为空时计算,之后不再随内容变化),用作同步身份键
  void ensureSyncHash() {
    if (syncHash?.isNotEmpty != true) {
      final map = <String, dynamic>{};
      map['history_id'] = historyId;
      map['shang'] = shang;
      map['xia'] = xia;
      map['bian'] = bian;
      map['messages'] = messages;
      syncHash = map.toString().md5();
    }
  }

  /// 刷新修改时间
  void touch() {
    updateTime = DateTime.now().millisecondsSinceEpoch;
  }

  /// 软删并瘦身:仅保留同步所需字段(sync_hash/update_time/deleted),其余置空,
  /// 避免已删对话的完整内容撑大同步文件
  void tombstone() {
    deleted = 1;
    touch();
    historyId = null;
    shang = null;
    xia = null;
    bian = null;
    messages = null;
  }
}
