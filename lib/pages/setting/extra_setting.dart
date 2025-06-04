import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/models/common/dynamics_type.dart';
import 'package:PiliPalaX/models/common/reply_sort_type.dart';
import 'package:PiliPalaX/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../utils/utils.dart';
import '../home/index.dart';
import 'controller.dart';
import 'widgets/switch_item.dart';

class ExtraSetting extends StatefulWidget {
  const ExtraSetting({super.key});

  @override
  State<ExtraSetting> createState() => _ExtraSettingState();
}

class _ExtraSettingState extends State<ExtraSetting> {
  Box setting = GStorage.setting;
  final SettingController settingController = Get.put(SettingController());
  late dynamic defaultReplySort;
  late dynamic defaultDynamicType;
  late dynamic enableSystemProxy;
  late String defaultSystemProxyHost;
  late String defaultSystemProxyPort;
  bool userLogin = false;

  @override
  void initState() {
    super.initState();
    // 默认优先显示最新评论
    defaultReplySort =
        setting.get(SettingBoxKey.replySortType, defaultValue: 0);
    if (defaultReplySort == 2) {
      setting.put(SettingBoxKey.replySortType, 0);
      defaultReplySort = 0;
    }
    // 优先展示全部动态 all
    defaultDynamicType =
        setting.get(SettingBoxKey.defaultDynamicType, defaultValue: 0);
    enableSystemProxy =
        setting.get(SettingBoxKey.enableSystemProxy, defaultValue: false);
    defaultSystemProxyHost =
        setting.get(SettingBoxKey.systemProxyHost, defaultValue: '');
    defaultSystemProxyPort =
        setting.get(SettingBoxKey.systemProxyPort, defaultValue: '');
  }

  // 设置代理
  void twoFADialog() {
    var systemProxyHost = '';
    var systemProxyPort = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proxy Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  isDense: true,
                  labelText: defaultSystemProxyHost != ''
                      ? defaultSystemProxyHost
                      : 'Please enter the Host IP, separated by .',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  hintText: defaultSystemProxyHost,
                ),
                onChanged: (e) {
                  systemProxyHost = e;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: defaultSystemProxyPort != ''
                      ? defaultSystemProxyPort
                      : 'Please Enter Port',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  hintText: defaultSystemProxyPort,
                ),
                onChanged: (e) {
                  systemProxyPort = e;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Get.back();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                setting.put(SettingBoxKey.systemProxyHost, systemProxyHost);
                setting.put(SettingBoxKey.systemProxyPort, systemProxyPort);
                Get.back();
                // Request.dio;
              },
              child: const Text('Confirm'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    TextStyle subTitleStyle = Theme.of(context)
        .textTheme
        .labelMedium!
        .copyWith(color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'Other',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          Obx(
            () => ListTile(
              enableFeedback: true,
              onTap: () => settingController.onOpenFeedBack(),
              leading: const Icon(Icons.vibration_outlined),
              title: Text('Vibration', style: titleStyle),
              subtitle: Text('Please make sure vibration feedback is turned on in your phone settings', style: subTitleStyle),
              trailing: Transform.scale(
                alignment: Alignment.centerRight,
                scale: 0.8,
                child: Switch(
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                        (Set<MaterialState> states) {
                      if (states.isNotEmpty &&
                          states.first == MaterialState.selected) {
                        return const Icon(Icons.done);
                      }
                      return null; // All other states will use the default thumbIcon.
                    }),
                    value: settingController.feedBackEnable.value,
                    onChanged: (value) => settingController.onOpenFeedBack()),
              ),
            ),
          ),
          const SetSwitchItem(
            title: 'Show Search Recommendations',
            subTitle: 'Enable/Disable Search Recommendations',
            leading: Icon(Icons.data_thresholding_outlined),
            setKey: SettingBoxKey.enableHotKey,
            defaultVal: true,
          ),
          SetSwitchItem(
            title: 'Show Default Search',
            subTitle: 'Enable/Disable Default Search in search bar',
            leading: const Icon(Icons.whatshot_outlined),
            setKey: SettingBoxKey.enableSearchWord,
            defaultVal: true,
            callFn: (val) {
              Get.find<HomeController>().defaultSearch.value = '';
            },
          ),
          const SetSwitchItem(
            title: 'Bookmarks',
            subTitle: 'Tap to save to default, long press to select folder',
            leading: Icon(Icons.bookmark_add_outlined),
            setKey: SettingBoxKey.enableQuickFav,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: 'Search keywords in Comments',
            subTitle: 'Display search keywords in the comments',
            leading: Icon(Icons.search_outlined),
            setKey: SettingBoxKey.enableWordRe,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: 'Enable AI Summary',
            subTitle: 'Enable AI summary on video details page',
            leading: Icon(Icons.engineering_outlined),
            setKey: SettingBoxKey.enableAi,
            defaultVal: true,
          ),
          const SetSwitchItem(
            title: 'Disable the "Likes Received" feature on the Messages page',
            subTitle: 'Prohibit opening of entrances to reduce dependence on online social networking',
            leading: Icon(Icons.beach_access_outlined),
            setKey: SettingBoxKey.disableLikeMsg,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: 'Display Comments',
            subTitle: 'Switch to the comment area page by default on the video details page (tab layout only)',
            leading: Icon(Icons.mode_comment_outlined),
            setKey: SettingBoxKey.defaultShowComment,
            defaultVal: false,
          ),
          SetSwitchItem(
            title: 'Default Introduction Expansion',
            subTitle: 'Expand the introduction by default on the video details page',
            leading: Icon(MdiIcons.arrowExpandDown),
            setKey: SettingBoxKey.defaultExpandIntroduction,
            defaultVal: false,
          ),
          ListTile(
            dense: false,
            title: Text('Comments Display', style: titleStyle),
            leading: const Icon(Icons.whatshot_outlined),
            subtitle: Text(
              'Current Display: 「${ReplySortType.values[defaultReplySort].titles}」',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: 'Comments Display',
                      value: defaultReplySort,
                      values: ReplySortType.values.map((e) {
                        return {'title': e.titles, 'value': e.index};
                      }).toList());
                },
              );
              if (result != null) {
                defaultReplySort = result;
                setting.put(SettingBoxKey.replySortType, result);
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('Dynamic Display', style: titleStyle),
            leading: const Icon(Icons.dynamic_feed_outlined),
            subtitle: Text(
              'Current Display: 「${DynamicsType.values[defaultDynamicType].labels}」',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: 'Dynamic Display',
                      value: defaultDynamicType,
                      values: DynamicsType.values.sublist(0, 4).map((e) {
                        return {'title': e.labels, 'value': e.index};
                      }).toList());
                },
              );
              if (result != null) {
                defaultDynamicType = result;
                setting.put(SettingBoxKey.defaultDynamicType, result);
                setState(() {});
              }
            },
          ),
          ListTile(
            enableFeedback: true,
            onTap: () => twoFADialog(),
            leading: const Icon(Icons.airplane_ticket_outlined),
            title: Text('Proxy Settings', style: titleStyle),
            subtitle: Text('Proxy as host:port', style: subTitleStyle),
            trailing: Transform.scale(
              alignment: Alignment.centerRight,
              scale: 0.8,
              child: Switch(
                thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                    (Set<MaterialState> states) {
                  if (states.isNotEmpty &&
                      states.first == MaterialState.selected) {
                    return const Icon(Icons.done);
                  }
                  return null; // All other states will use the default thumbIcon.
                }),
                value: enableSystemProxy,
                onChanged: (val) {
                  setting.put(
                      SettingBoxKey.enableSystemProxy, !enableSystemProxy);
                  setState(() {
                    enableSystemProxy = !enableSystemProxy;
                  });
                },
              ),
            ),
          ),
          const SetSwitchItem(
            title: 'Auto Clear Cache',
            subTitle: 'Clear cache on startup',
            leading: Icon(Icons.auto_delete_outlined),
            setKey: SettingBoxKey.autoClearCache,
            defaultVal: false,
          ),
          SetSwitchItem(
            title: 'Check for Updates',
            subTitle: 'Check for updates on startup',
            leading: const Icon(Icons.system_update_alt_outlined),
            setKey: SettingBoxKey.autoUpdate,
            defaultVal: false,
            callFn: (val) {
              if (val) {
                Utils.checkUpdate();
              }
            },
          ),
        ],
      ),
    );
  }
}
