import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/route_manager.dart';
import 'package:meihua/entity/database/db_ai_chat.dart';
import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';
import 'package:meihua/util/sync_helper.dart';
import 'package:meihua/widget/edit_text.dart';

/// 排盘历史列表项:历史页与搜索页共用(含长按菜单:编辑/显示隐藏/删除)
class HistoryItem extends StatelessWidget {
  final DbHistory item;
  final bool visible;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleVisible;
  final VoidCallback? onDelete;

  const HistoryItem({
    super.key,
    required this.item,
    required this.visible,
    this.onTap,
    this.onEdit,
    this.onToggleVisible,
    this.onDelete,
  });

  void _showMenu() {
    final hideText = visible ? '隐藏' : '显示';
    Get.bottomSheet(BottomSheet(
        clipBehavior: Clip.antiAlias,
        onClosing: () {},
        builder: (context) {
          return Wrap(
            children: [
              ListTile(
                  title: const Text('编辑'),
                  onTap: () {
                    Get.until((route) => Get.isBottomSheetOpen != true);
                    onEdit?.call();
                  }),
              ListTile(
                  title: Text(hideText,
                      style: const TextStyle(color: Colors.blueAccent)),
                  onTap: () {
                    Get.until((route) => Get.isBottomSheetOpen != true);
                    onToggleVisible?.call();
                  }),
              ListTile(
                  title: const Text('删除',
                      style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Get.until((route) => Get.isBottomSheetOpen != true);
                    onDelete?.call();
                  }),
            ],
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final contentChildren = [
      Visibility(
          visible: visible,
          child: Text(item.title!,
              style: const TextStyle(color: Colors.redAccent))),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('上卦: ${item.shang!.baGua().name}'),
          Text('下卦: ${item.xia!.baGua().name}'),
          Text('变爻: ${item.bian!.yao()}'),
        ],
      ),
      Text('时间: ${item.saveDate.dateStr()}',
          style: TextStyle(color: scheme.onSurfaceVariant)),
      Text('农历时间: ${item.lunarDate.or()}',
          style: TextStyle(color: scheme.onSurfaceVariant)),
    ];
    if (item.describe?.isNotEmpty == true) {
      contentChildren.add(Visibility(
        visible: visible,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('详细说明:',
                style: TextStyle(color: Colors.blueAccent)),
            MarkdownBody(
              data: item.describe!,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  fontSize: 13,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ));
    }
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contentChildren,
      ),
      onTap: onTap,
      onLongPress: (onEdit != null ||
              onToggleVisible != null ||
              onDelete != null)
          ? _showMenu
          : null,
    );
  }
}

/// 编辑历史记录弹窗(历史页与搜索页共用)
Future<void> showHistoryEditDialog(
  BuildContext context,
  DbHistory item, {
  VoidCallback? onSaved,
}) async {
  final title = EditText(label: '标题', defaultStr: item.title),
      desc = EditText(label: '详细说明', maxLines: 3, defaultStr: item.describe);
  Get.generalDialog(
    pageBuilder: (context, animation1, animation2) => AlertDialog(
      title: const Text('保存'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          title,
          desc,
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Get.until((route) => Get.isDialogOpen != true);
            },
            child: const Text('取消')),
        TextButton(
            onPressed: () async {
              final titleStr = title.text();
              if (titleStr.isEmpty) {
                '标题不能为空'.toast();
              } else {
                final descStr = desc.text();
                item.title = titleStr;
                item.describe = descStr;
                item.ensureSyncHash();
                item.touch();
                await DbHelper.update(item);
                Get.until((route) => Get.isDialogOpen != true);
                '保存成功'.toast();
                onSaved?.call();
                SyncHelper.scheduleAutoSync();
              }
            },
            child: const Text('保存')),
      ],
      scrollable: true,
    ),
  );
}

/// 软删历史记录(含级联删除对话),由调用方负责刷新列表
Future<void> deleteHistory(DbHistory item) async {
  item.tombstone();
  await DbHelper.update(item);
  if (item.id != null) {
    await DbAiChat.tombstoneByHistory(item.id!);
  }
  SyncHelper.scheduleAutoSync();
}
