import 'package:meihua/entity/database/base.dart';
import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/util/config_helper.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';
import 'package:meihua/util/sync_helper.dart';

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
  /// 避免已删对话的完整内容撑大同步文件。touch=false 用于存量墓碑迁移,
  /// 不刷新版本号,避免破坏 last-write-wins 语义
  void tombstone({bool touch = true}) {
    deleted = 1;
    if (touch) this.touch();
    historyId = null;
    shang = null;
    xia = null;
    bian = null;
    messages = null;
  }

  /// 是否已是精简墓碑(用于迁移时跳过已瘦身的记录)
  bool get isStrippedTombstone => deleted == 1 && messages == null;

  /// 级联软删:该排盘历史下的所有对话一并转墓碑(删除历史时调用)
  static Future<void> tombstoneByHistory(int historyId) async {
    final chats = (await DbHelper.query<DbAiChat>(DbAiChat.nameDb,
            (ls) =>
                ls?.where((t) => t.historyId == historyId && t.deleted != 1)))
        ?.toList() ??
        <DbAiChat>[];
    for (final c in chats) {
      final tomb = DbAiChat()..fromMap(c.toMap());
      tomb.tombstone();
      await DbHelper.update(tomb);
    }
  }

  /// 孤儿数据清理:孤儿数据仅在旧版本(未自动保存历史/未级联删除)产生,
  /// 新版本不会再产生,因此用版本标记保证只执行一次。
  /// 废弃:仅用于一次性迁移,随下个版本删除
  @Deprecated('仅用于清理旧版本遗留的孤儿数据,可随下个版本一并删除')
  static const orphanCleanupVersion = 'v1';
  static const _keyCleanupDone = 'ai_chat_cleanup_done';

  /// 清理孤儿对话:historyId 为空、或指向已删除排盘历史的对话转墓碑。
  /// 版本等于 [orphanCleanupVersion] 才执行,执行后记录版本标记,不再重复扫描。
  /// 废弃:仅用于清理旧版本遗留的孤儿数据,随下个版本删除
  @Deprecated('仅用于清理旧版本遗留的孤儿数据,可随下个版本一并删除')
  static Future<void> cleanupOrphans() async {
    if (await ConfigHelper.getConfig(_keyCleanupDone) == orphanCleanupVersion) {
      return;
    }
    final chats = (await DbHelper.query<DbAiChat>(DbAiChat.nameDb))?.toList() ??
        <DbAiChat>[];
    if (chats.isEmpty) {
      await ConfigHelper.saveConfig(_keyCleanupDone, orphanCleanupVersion);
      return;
    }
    final histories = (await DbHelper.query<DbHistory>(DbHistory.nameDb))
            ?.toList() ??
        <DbHistory>[];
    final historyById = {for (final h in histories) h.id: h};
    var cleaned = false;
    for (final c in chats) {
      if (c.deleted == 1) continue;
      final history = c.historyId == null ? null : historyById[c.historyId];
      final orphan =
          c.historyId == null || (history != null && history.deleted == 1);
      if (orphan) {
        final tomb = DbAiChat()..fromMap(c.toMap());
        tomb.tombstone();
        await DbHelper.update(tomb);
        cleaned = true;
      }
    }
    if (cleaned) {
      SyncHelper.scheduleAutoSync();
    }
    await ConfigHelper.saveConfig(_keyCleanupDone, orphanCleanupVersion);
  }
}
