import 'package:meihua/entity/database/base.dart';

/// AI对话记录:每个卦(或已保存的排盘历史)一条,实时保存、不同步。
/// 通过 historyId 关联已保存的排盘历史;未保存时 historyId 为空,
/// 按 (shang, xia, bian) 匹配同一卦的对话。
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

  @override
  void fromMap(Map<String, dynamic> map) {
    id = map['id'];
    historyId = map['history_id'];
    shang = map['shang'];
    xia = map['xia'];
    bian = map['bian'];
    messages = map['messages'];
    updateTime = map['update_time'];
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['history_id'] = historyId;
    map['shang'] = shang;
    map['xia'] = xia;
    map['bian'] = bian;
    map['messages'] = messages;
    map['update_time'] = updateTime;
    return map;
  }

  /// 刷新修改时间
  void touch() {
    updateTime = DateTime.now().millisecondsSinceEpoch;
  }
}
