import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:meihua/ai_settings.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';
import 'package:meihua/util/sync_helper.dart';
import 'package:meihua/widget/edit_text.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final _historyList = <DbHistory>[];
  final _visibles = <int, bool>{};
  var _showAll = false;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final listview = ListView.separated(
      itemBuilder: (context, index) {
        final item = _historyList[index];
        final visible = _visibles[index] == true;
        final contentChildren = [
          Visibility(
            visible: visible,
            child: Text(item.title!,
                style: const TextStyle(color: Colors.redAccent)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Text('id: $id'),
              Text('上卦: ${item.shang!.baGua().name}'),
              Text('下卦: ${item.xia!.baGua().name}'),
              Text('变爻: ${item.bian!.yao()}'),
            ],
          ),
          Text('时间: ${item.saveDate.dateStr()}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text('农历时间: ${item.lunarDate.or()}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
          onTap: () async {
            await Get.toNamed(
              'pan',
              arguments: Yi(
                shang: item.shang! == 0 ? 8 : item.shang!,
                xia: item.xia! == 0 ? 8 : item.xia!,
                dong: item.bian! == 0 ? 6 : item.bian!,
                historyDate: '${item.saveDate.dateStr()}\n(${item.lunarDate})',
                historyId: item.id,
              ),
            );
            // 从排盘页返回后刷新列表,反映在详细页做的编辑/保存
            _loadData();
          },
          onLongPress: () {
            final hideText = (_visibles[index] ?? false) ? '隐藏' : '显示';
            Get.bottomSheet(BottomSheet(
                clipBehavior: Clip.antiAlias,
                onClosing: () {},
                builder: (context) {
                  // _delete(id, title, index);
                  final children = <Widget>[
                    ListTile(
                      title: const Text('编辑'),
                      onTap: () => _edit(item),
                    ),
                    ListTile(
                      title: Text(
                        hideText,
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                      onTap: () => _hide(index),
                    ),
                    ListTile(
                      title: const Text(
                        '删除',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () => _delete(item, index),
                    ),
                  ];
                  return Wrap(
                    children: children,
                  );
                }));
          },
        );
      },
      itemCount: _historyList.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(
        thickness: 0,
        height: 0.1,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('排盘历史'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              //PopupMenuItem(value: 0, child: Text(_showAll ? '隐藏全部' : '显示全部')),
              const PopupMenuItem(value: 1, child: Text('同步')),
              const PopupMenuItem(value: 2, child: Text('同步设置')),
              const PopupMenuItem(value: 3, child: Text('AI设置')),
            ],
            onSelected: (value) => _actionSelected(value),
          ),
          TextButton(
              onPressed: () => _actionSelected(0),
              child: Text(_showAll ? '隐藏全部' : '显示全部')),
        ],
      ),
      body: SafeArea(
        child: listview,
      ),
    );
  }

  void _actionSelected(index) async {
    if (index == 0) {
      _showAll = !_showAll;
      for (var i = 0; i < _historyList.length; i++) {
        _visibles[i] = _showAll;
      }
      setState(() {});
    } else if (index == 1) {
      final configured = await SyncHelper.isConfigured();
      if (configured) {
        '确认同步(排盘历史+AI对话)吗？'.confirmDialog(() async {
          await SyncHelper.sync(false);
          await SyncHelper.syncAiChat(false);
          await _loadData();
          '同步完成'.toast();
        });
      } else {
        _actionSelected(2);
      }
    } else if (index == 2) {
      final (oldServerUrl, oldAccount, oldPassword) =          await SyncHelper.getWebDavConf();
      final etServer = EditText(
            label: '服务器地址',
            defaultStr: oldServerUrl ?? 'https://dav.jianguoyun.com/dav/',
            maxLines: 1,
          ),
          etAccount = EditText(
            label: '账号',
            defaultStr: oldAccount,
            maxLines: 1,
          ),
          etPassword = EditText(
            label: '密码',
            defaultStr: oldPassword,
            obscureText: true,
            maxLines: 1,
          );
      Get.generalDialog(
        pageBuilder: (context, animation1, animation2) => AlertDialog(
          title: const Text('WebDav同步设置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [etServer, etAccount, etPassword],
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  '覆盖同步'.confirmDialog(() async {
                    await SyncHelper.forceSync();
                    await SyncHelper.forceSyncAiChat();
                    await _loadData();
                    Get.until((route) => Get.isDialogOpen != true);
                  }, title: '确定以本地数据覆盖云端数据吗？');
                },
                child: const Text('覆盖云端数据',
                    style: TextStyle(color: Colors.redAccent))),
            TextButton(
                onPressed: () {
                  Get.until((route) => Get.isDialogOpen != true);
                },
                child: const Text('取消')),
            TextButton(
                onPressed: () async {
                  final serverUrl = etServer.text(),
                      account = etAccount.text(),
                      password = etPassword.text();
                  await SyncHelper.saveWebDavConf(serverUrl, account, password);
                  Get.until((route) => Get.isDialogOpen != true);
                },
                child: const Text('保存')),
          ],
          scrollable: true,
        ),
      );
    } else if (index == 3) {
      Get.to(() => const AiSettingsPage());
    }
  }

  void _delete(DbHistory item, int index) {
    Get.until((route) => Get.isBottomSheetOpen != true);
    '删除'.confirmDialog(() async {
      // 软删:保留记录但标记 deleted=1 并刷新 updateTime,
      // 同步时这条"已删除"快照会比远端旧版本新,从而把删除传播到其它设备
      item.deleted = 1;
      item.touch();
      await DbHelper.update(item);

      setState(() {
        _historyList.removeAt(index);
      });
      Get.until((route) => Get.isDialogOpen != true);
      '删除成功'.toast();
      SyncHelper.scheduleAutoSync();
    }, title: '确定删除${item.title}吗');
  }

  void _edit(DbHistory item) {
    Get.until((route) => Get.isBottomSheetOpen != true);
    final title = EditText(
          label: '标题',
          defaultStr: item.title,
        ),
        desc = EditText(
          label: '详细说明',
          maxLines: 3,
          defaultStr: item.describe,
        );
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
                  await _loadData();
                  SyncHelper.scheduleAutoSync();
                }
              },
              child: const Text('保存')),
        ],
        scrollable: true,
      ),
    );
  }

  void _hide(int index) {
    Get.until((route) => Get.isBottomSheetOpen != true);
    final visible = _visibles[index] ?? false;
    setState(() {
      _visibles[index] = !visible;
    });
  }

  Future<void> _loadData() async {
    _historyList.clear();
    final raw = (await DbHelper.query<DbHistory>(DbHistory.nameDb))?.toList() ??
        <DbHistory>[];
    // 软删的记录不进列表(但仍留在 box 里以传播删除)
    raw.removeWhere((h) => h.deleted == 1);
    raw.sort((a, b) => b.saveDate?.compareTo(a.saveDate ?? 0) ?? 0);
    if (raw.isNoneEmpty) {
      setState(() {
        _historyList.addAll(raw);
      });
    } else {
      setState(() {});
    }
  }
}
