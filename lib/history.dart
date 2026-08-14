import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:meihua/ai_settings.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';
import 'package:meihua/util/sync_helper.dart';
import 'package:meihua/widget/edit_text.dart';
import 'package:meihua/widget/history_item.dart';

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
        return HistoryItem(
          item: item,
          visible: visible,
          onTap: () async {
            await Get.toNamed(
              'pan',
              arguments: Yi(
                shang: item.shang! == 0 ? 8 : item.shang!,
                xia: item.xia! == 0 ? 8 : item.xia!,
                dong: item.bian! == 0 ? 6 : item.bian!,
                historyDate:
                    '${item.saveDate.dateStr()}\n(${item.lunarDate})',
                historyId: item.id,
              ),
            );
            // 从排盘页返回后刷新列表,反映在详细页做的编辑/保存
            _loadData();
          },
          onEdit: () => _edit(item),
          onToggleVisible: () => _hide(index),
          onDelete: () => _delete(item, index),
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
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '搜索排盘历史',
            onPressed: () => Get.to(() => const HistorySearchPage()),
          ),
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
        '确认同步吗？'.confirmDialog(() async {
          await SyncHelper.sync(false);
          await SyncHelper.syncAiChat(false);
          await SyncHelper.syncAiConfig(false);
          await _loadData();
          '同步完成'.toast();
        }, content: '同步将同时排盘历史、AI对话和AI设置');
      } else {
        _actionSelected(2);
      }
    } else if (index == 2) {
      final (oldServerUrl, oldAccount, oldPassword) =
          await SyncHelper.getWebDavConf();
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
                    await SyncHelper.forceSyncAiConfig();
                    await _loadData();
                    Get.until((route) => Get.isDialogOpen != true);
                  }, content: '确定以本地数据覆盖云端数据吗？');
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
      await deleteHistory(item);
      setState(() {
        _historyList.removeAt(index);
      });
      Get.until((route) => Get.isDialogOpen != true);
      '删除成功'.toast();
    }, content: '确定删除${item.title}吗');
  }

  void _edit(DbHistory item) {
    Get.until((route) => Get.isBottomSheetOpen != true);
    showHistoryEditDialog(context, item, onSaved: () => _loadData());
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

/// 排盘历史搜索页:按标题/详细说明关键字搜索,点击跳转到对应排盘
class HistorySearchPage extends StatefulWidget {
  const HistorySearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _HistorySearchPageState();
}

class _HistorySearchPageState extends State<HistorySearchPage> {
  final _ctrl = TextEditingController();
  var _results = <DbHistory>[];
  final _hiddenIds = <int>{};

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String keyword) async {
    final kw = keyword.trim();
    final raw = (await DbHelper.query<DbHistory>(DbHistory.nameDb))?.toList() ??
        <DbHistory>[];
    raw.removeWhere((h) => h.deleted == 1);
    if (kw.isNotEmpty) {
      raw.removeWhere((h) =>
          h.title?.contains(kw) != true && h.describe?.contains(kw) != true);
    }
    raw.sort((a, b) => b.saveDate?.compareTo(a.saveDate ?? 0) ?? 0);
    if (mounted) {
      setState(() => _results = raw);
    }
  }

  void _deleteResult(DbHistory item) {
    '删除'.confirmDialog(() async {
      await deleteHistory(item);
      await _search(_ctrl.text);
      Get.until((route) => Get.isDialogOpen != true);
      '删除成功'.toast();
    }, content: '确定删除${item.title}吗');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '搜索标题或详细说明…',
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
      ),
      body: SafeArea(
        child: _results.isEmpty
            ? const Center(
                child: Text('未找到相关记录',
                    style: TextStyle(color: Colors.grey)))
            : ListView.separated(
                itemBuilder: (context, index) {
                  final item = _results[index];
                  return HistoryItem(
                    item: item,
                    visible: !_hiddenIds.contains(item.id),
                    onTap: () {
                      Get.toNamed(
                        'pan',
                        arguments: Yi(
                          shang: item.shang! == 0 ? 8 : item.shang!,
                          xia: item.xia! == 0 ? 8 : item.xia!,
                          dong: item.bian! == 0 ? 6 : item.bian!,
                          historyDate:
                              '${item.saveDate.dateStr()}\n(${item.lunarDate})',
                          historyId: item.id,
                        ),
                      );
                    },
                    onEdit: () => showHistoryEditDialog(context, item,
                        onSaved: () => _search(_ctrl.text)),
                    onToggleVisible: () {
                      setState(() {
                        if (!_hiddenIds.remove(item.id!)) {
                          _hiddenIds.add(item.id!);
                        }
                      });
                    },
                    onDelete: () => _deleteResult(item),
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                  thickness: 0,
                  height: 0.1,
                ),
                itemCount: _results.length,
              ),
      ),
    );
  }
}
