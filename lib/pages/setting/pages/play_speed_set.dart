import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/pages/setting/widgets/switch_item.dart';
import 'package:PiliPalaX/plugin/pl_player/index.dart';
import 'package:PiliPalaX/plugin/pl_player/models/play_speed.dart';
import 'package:PiliPalaX/utils/storage.dart';

class PlaySpeedPage extends StatefulWidget {
  const PlaySpeedPage({super.key});

  @override
  State<PlaySpeedPage> createState() => _PlaySpeedPageState();
}

class _PlaySpeedPageState extends State<PlaySpeedPage> {
  Box videoStorage = GStorage.video;
  Box settingStorage = GStorage.setting;
  late double playSpeedDefault;
  late double longPressSpeedDefault;
  late List<double> customSpeedsList;
  late bool enableAutoLongPressSpeed;
  late bool enableLongPressSpeedIncrease;
  List<Map<dynamic, dynamic>> sheetMenu = [
    {
      'id': 1,
      'title': 'Set to default speed',
      'leading': const Icon(
        Icons.speed,
        size: 21,
      ),
      'show': true,
    },
    {
      'id': 2,
      'title': 'Set as default long press speed',
      'leading': const Icon(
        Icons.speed_sharp,
        size: 21,
      ),
      'show': true,
    },
    {
      'id': -1,
      'title': 'Delete this item',
      'leading': const Icon(
        Icons.delete_outline,
        size: 21,
      ),
      'show': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // 默认倍速
    playSpeedDefault = videoStorage
        .get(VideoBoxKey.playSpeedDefault, defaultValue: 1.0)
        .toDouble();
    // 默认长按倍速
    longPressSpeedDefault = videoStorage
        .get(VideoBoxKey.longPressSpeedDefault, defaultValue: 3.0)
        .toDouble();
    List<double> defaultList = <double>[0.5, 0.75, 1.25, 1.5, 1.75, 3.0];
    customSpeedsList = List<double>.from(videoStorage
        .get(VideoBoxKey.customSpeedsList, defaultValue: defaultList)
        .map((e) => e.toDouble()));
    enableAutoLongPressSpeed = settingStorage
        .get(SettingBoxKey.enableAutoLongPressSpeed, defaultValue: false);
    if (enableAutoLongPressSpeed) {
      Map newItem = sheetMenu[1];
      newItem['show'] = false;
      setState(() {
        sheetMenu[1] = newItem;
      });
    }
    enableLongPressSpeedIncrease = settingStorage
        .get(SettingBoxKey.enableLongPressSpeedIncrease, defaultValue: false);
  }

  // 添加自定义倍速
  void onAddSpeed() {
    double customSpeed = 1.0;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Speed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const Text('输入你想要的视频倍速，例如：1.0'),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Custom Speed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                onChanged: (e) {
                  customSpeed = double.parse(e);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                customSpeedsList.add(customSpeed);
                await videoStorage.put(
                    VideoBoxKey.customSpeedsList, customSpeedsList);
                PlPlayerController.updateSettingsIfExist();
                setState(() {});
                Get.back();
              },
              child: const Text('Confirm Add'),
            )
          ],
        );
      },
    );
  }

  // 设定倍速弹窗
  void showBottomSheet(type, i) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 10),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            //重要
            itemCount: sheetMenu.length,
            itemBuilder: (BuildContext context, int index) {
              return sheetMenu[index]['show']
                  ? ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        menuAction(type, i, sheetMenu[index]['id']);
                      },
                      minLeadingWidth: 0,
                      iconColor: Theme.of(context).colorScheme.onSurface,
                      leading: sheetMenu[index]['leading'],
                      title: Text(
                        sheetMenu[index]['title'],
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    )
                  : const SizedBox();
            },
          ),
        );
      },
    );
  }

  //
  void menuAction(type, index, id) async {
    double chooseSpeed = 1.0;
    if (type == 'system' && id == -1) {
      SmartDialog.showToast('Cannot Delete Default System Speed');
      return;
    }
    // 获取当前选中的倍速值
    if (type == 'system') {
      chooseSpeed = PlaySpeed.values[index].value;
    } else {
      chooseSpeed = customSpeedsList[index];
    }
    // 设置
    if (id == 1) {
      // 设置默认倍速
      playSpeedDefault = chooseSpeed;
      videoStorage.put(VideoBoxKey.playSpeedDefault, playSpeedDefault);
    } else if (id == 2) {
      // 设置默认长按倍速
      longPressSpeedDefault = chooseSpeed;
      videoStorage.put(
          VideoBoxKey.longPressSpeedDefault, longPressSpeedDefault);
    } else if (id == -1) {
      if (customSpeedsList[index] == playSpeedDefault) {
        playSpeedDefault = 1.0;
        videoStorage.put(VideoBoxKey.playSpeedDefault, playSpeedDefault);
      }
      if (customSpeedsList[index] == longPressSpeedDefault) {
        longPressSpeedDefault = 3.0;
        videoStorage.put(
            VideoBoxKey.longPressSpeedDefault, longPressSpeedDefault);
      }
      customSpeedsList.removeAt(index);
      await videoStorage.put(VideoBoxKey.customSpeedsList, customSpeedsList);
    }
    PlPlayerController.updateSettingsIfExist();
    setState(() {});
    SmartDialog.showToast('Operation Success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        title: Text(
          'Speed Setting',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              dense: false,
              title: Text('Current Default Speed',
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(playSpeedDefault.toString()),
            ),
            SetSwitchItem(
              title: 'Dynamic Long Press Speed',
              subTitle: 'Automatically double the speed when long pressing according to the default speed',
              setKey: SettingBoxKey.enableAutoLongPressSpeed,
              defaultVal: enableAutoLongPressSpeed,
              callFn: (val) {
                Map newItem = sheetMenu[1];
                val ? newItem['show'] = false : newItem['show'] = true;
                setState(() {
                  sheetMenu[1] = newItem;
                  enableAutoLongPressSpeed = val;
                });
                PlPlayerController.updateSettingsIfExist();
              },
            ),
            !enableAutoLongPressSpeed
                ? ListTile(
                    dense: false,
                    title: Text('Default Long Press Speed',
                        style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(longPressSpeedDefault.toString()),
                  )
                : const SizedBox(),
            SetSwitchItem(
              title: 'Long Press to Increase Speed',
              subTitle: 'Every half second of long press, the speed is x1.15, the maximum speed is 8 times',
              setKey: SettingBoxKey.enableLongPressSpeedIncrease,
              defaultVal: false,
              callFn: (_) {
                PlPlayerController.updateSettingsIfExist();
              },
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 14, right: 14, top: 6, bottom: 0),
              child: Text(
                'Click the button below to set the default speed and default long press speed',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 14,
                right: 14,
                bottom: 10,
                top: 20,
              ),
              child: Text(
                'System Default Speed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 18,
                right: 18,
                bottom: 30,
              ),
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 2,
                children: [
                  for (var i in PlaySpeed.values) ...[
                    FilledButton.tonal(
                      onPressed: () => showBottomSheet('system', i.index),
                      child: Text(i.description),
                    ),
                  ]
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(
                  left: 14,
                  right: 14,
                ),
                child: Row(
                  children: [
                    Text(
                      'Custom Speed',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => onAddSpeed(),
                      child: const Text('Add'),
                    )
                  ],
                )),
            Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                bottom: MediaQuery.of(context).padding.bottom + 40,
              ),
              child: customSpeedsList.isNotEmpty
                  ? Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        for (int i = 0; i < customSpeedsList.length; i++) ...[
                          FilledButton.tonal(
                            onPressed: () => showBottomSheet('custom', i),
                            child: Text(customSpeedsList[i].toString()),
                          ),
                        ]
                      ],
                    )
                  : SizedBox(
                      height: 80,
                      child: Center(
                        child: Text(
                          'Not Added',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                    ),
            ),
            ListTile(
              subtitle: Text(
                'Note: Due to player performance limitations, 4k and 8k videos played at a speed greater than 2x may cause freezes, audio and video desync, etc. Please choose accordingly.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
