import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/models/common/tab_type.dart';
import 'package:PiliPalaX/utils/storage.dart';

class TabbarSetPage extends StatefulWidget {
  const TabbarSetPage({super.key});

  @override
  State<TabbarSetPage> createState() => _TabbarSetPageState();
}

class _TabbarSetPageState extends State<TabbarSetPage> {
  Box settingStorage = GStorage.setting;
  late List defaultTabs;
  late List<String> tabbarSort;

  @override
  void initState() {
    super.initState();
    defaultTabs = tabsConfig;
    tabbarSort = settingStorage
        .get(SettingBoxKey.tabbarSort,
            defaultValue: ['live', 'rcmd', 'hot', 'rank', 'bangumi'])
        .map<String>((i) => i.toString())
        .toList();
    // 对 tabData 进行排序
    defaultTabs.sort((a, b) {
      int indexA = tabbarSort.indexOf((a['type'] as TabType).id);
      int indexB = tabbarSort.indexOf((b['type'] as TabType).id);

      // 如果类型在 sortOrder 中不存在，则放在末尾
      if (indexA == -1) indexA = tabbarSort.length;
      if (indexB == -1) indexB = tabbarSort.length;

      return indexA.compareTo(indexB);
    });
  }

  void saveEdit() {
    List<String> sortedTabbar = defaultTabs
        .where((i) => tabbarSort.contains((i['type'] as TabType).id))
        .map<String>((i) => (i['type'] as TabType).id)
        .toList();
    settingStorage.put(SettingBoxKey.tabbarSort, sortedTabbar);
    SmartDialog.showToast('Saved Successfully, will take effect on restart');
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final tabsItem = defaultTabs.removeAt(oldIndex);
      defaultTabs.insert(newIndex, tabsItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listTiles = [
      for (int i = 0; i < defaultTabs.length; i++) ...[
        CheckboxListTile(
          key: Key(defaultTabs[i]['label']),
          value: tabbarSort.contains((defaultTabs[i]['type'] as TabType).id),
          onChanged: (bool? newValue) {
            String tabTypeId = (defaultTabs[i]['type'] as TabType).id;
            if (!newValue!) {
              tabbarSort.remove(tabTypeId);
            } else {
              tabbarSort.add(tabTypeId);
            }
            setState(() {});
          },
          title: Text(defaultTabs[i]['label']),
          secondary: const Icon(Icons.drag_indicator_rounded),
        )
      ]
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabbar Edit'),
        actions: [
          TextButton(onPressed: () => saveEdit(), child: const Text('Save')),
          const SizedBox(width: 12)
        ],
      ),
      body: ReorderableListView(
        onReorder: onReorder,
        physics: const NeverScrollableScrollPhysics(),
        footer: SizedBox(
          height: MediaQuery.of(context).padding.bottom + 30,
          child: const Align(
              alignment: Alignment.centerRight, child: Text('*Long press and drag to sort        ')),
        ),
        children: listTiles,
      ),
    );
  }
}
