import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/models/common/theme_type.dart';
import 'package:PiliPalaX/pages/setting/pages/color_select.dart';
import 'package:PiliPalaX/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPalaX/pages/setting/widgets/slide_dialog.dart';
import 'package:PiliPalaX/utils/global_data.dart';
import 'package:PiliPalaX/utils/storage.dart';

import '../../models/common/dynamic_badge_mode.dart';
import '../../models/common/side_bar_position.dart';
import '../../models/common/up_panel_position.dart';
import '../../plugin/pl_player/controller.dart';
import '../../plugin/pl_player/utils/fullscreen.dart';
import '../../models/common/nav_bar_config.dart';
import 'controller.dart';
import 'widgets/switch_item.dart';

class StyleSetting extends StatefulWidget {
  const StyleSetting({super.key});

  @override
  State<StyleSetting> createState() => _StyleSettingState();
}

class _StyleSettingState extends State<StyleSetting> {
  final SettingController settingController = Get.put(SettingController());
  final ColorSelectController colorSelectController =
      Get.put(ColorSelectController());
  FlexSchemeVariant _dynamicSchemeVariant = FlexSchemeVariant.values[
      GStorage.setting.get(SettingBoxKey.schemeVariant, defaultValue: 10)];

  Box setting = GStorage.setting;
  late int picQuality;
  late double maxRowWidth;
  late UpPanelPosition upPanelPosition;
  late SideBarPosition sideBarPosition;

  @override
  void initState() {
    super.initState();
    picQuality = setting.get(SettingBoxKey.defaultPicQa, defaultValue: 10);
    maxRowWidth =
        setting.get(SettingBoxKey.maxRowWidth, defaultValue: 240.0) as double;
    upPanelPosition = UpPanelPosition.values[setting.get(
        SettingBoxKey.upPanelPosition,
        defaultValue: UpPanelPosition.leftFixed.code)];
    sideBarPosition = SideBarPositionCode.fromCode(setting.get(
        SettingBoxKey.sideBarPosition,
        defaultValue: SideBarPosition.none.code))!;
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
          'Style',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          SetSwitchItem(
              title: 'Horizontal Screen Adaptation',
              subTitle: 'Enable horizontal screen layout and logic, which can be turned on for tablets, folding screens, etc.; it is recommended to set the full screen direction to [Do not change the current direction]',
              leading: const Icon(Icons.phonelink_outlined),
              setKey: SettingBoxKey.horizontalScreen,
              defaultVal: false,
              callFn: (value) {
                if (value) {
                  autoScreen();
                  SmartDialog.showToast('Enabled');
                } else {
                  AutoOrientation.portraitUpMode();
                  SmartDialog.showToast('Disabled');
                }
                PlPlayerController.updateSettingsIfExist();
              }),
          // const SetSwitchItem(
          //   title: '改用侧边栏',
          //   subTitle: '开启后底栏与顶栏被替换，且相关设置失效',
          //   leading: Icon(Icons.chrome_reader_mode_outlined),
          //   setKey: SettingBoxKey.useSideBar,
          //   defaultVal: false,
          //   needReboot: true,
          // ),
          ListTile(
            dense: false,
            title: Text('Homepage Sidebar Layout', style: titleStyle),
            leading: const Icon(Icons.chrome_reader_mode_outlined),
            subtitle: Text(
                'Current: ${sideBarPosition.labels}. When enabled, the bottom bar and top bar will be replaced by the side bar. Recommended for landscape or folding screens.',
                style: subTitleStyle),
            onTap: () async {
              SideBarPosition? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<SideBarPosition>(
                    title: 'Homepage Sidebar Layout',
                    value: sideBarPosition,
                    values: SideBarPosition.values.map((e) {
                      return {'title': e.labels, 'value': e};
                    }).toList(),
                  );
                },
              );
              if (result != null) {
                sideBarPosition = result;
                setting.put(SettingBoxKey.sideBarPosition, result.code);
                SmartDialog.showToast('Restart to take effect');
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            onTap: () => Get.toNamed('/colorSetting'),
            leading: const Icon(Icons.color_lens_outlined),
            title: Text('Theme', style: titleStyle),
            subtitle: Obx(() => Text(
                '${settingController.themeType.value.description}   '
                '${colorSelectController.type.value == 0 ? 'Dynamic' : 'Specify'}   '
                '${_dynamicSchemeVariant.variantName}',
                style: subTitleStyle)),
          ),
          const SetSwitchItem(
            title: 'MD3 Tab Bar Style',
            subTitle: 'Material You standard design，Can be narrowed when closed',
            leading: Icon(Icons.design_services_outlined),
            setKey: SettingBoxKey.enableMYBar,
            defaultVal: true,
            needReboot: true,
          ),
          const SetSwitchItem(
            title: 'Homepage Background Gradient',
            setKey: SettingBoxKey.enableGradientBg,
            leading: Icon(Icons.gradient_outlined),
            defaultVal: true,
            needReboot: true,
          ),
          ListTile(
            onTap: () async {
              double? result = await showDialog(
                  context: context,
                  builder: (context) {
                    return SlideDialog<double>(
                      title: 'Max Row Width (up to 240dp)',
                      value: maxRowWidth,
                      min: 150.0,
                      max: 500.0,
                      divisions: 35,
                      suffix: 'dp',
                    );
                  });
              if (result != null) {
                maxRowWidth = result;
                setting.put(SettingBoxKey.maxRowWidth, result);
                SmartDialog.showToast('Restart to take effect');
                setState(() {});
              }
            },
            leading: const Icon(Icons.calendar_view_week_outlined),
            dense: false,
            title: Text('List Width (dp) Limit', style: titleStyle),
            subtitle: Text(
              'Current: ${maxRowWidth.toInt()}dp，Screen Width:${MediaQuery.of(context).size.width.toPrecision(2)}dp.'
              'The smaller the width, the more rows there are. Horizontal bars and large cards will be cut in half',
              style: subTitleStyle,
            ),
          ),
          const SetSwitchItem(
            title: 'Use Background Color for Progress Bar',
            subTitle: 'Will display as black if turned off',
            leading: Icon(Icons.border_outer_outlined),
            setKey: SettingBoxKey.videoPlayerShowStatusBarBackgroundColor,
            defaultVal: false,
            needReboot: true,
          ),
          const SetSwitchItem(
            title: 'Remove Safety Margins from Video Player Area',
            subTitle: 'Hide the status bar and fill the screen, but the playback controls are still in the safe zone',
            leading: Icon(Icons.fit_screen_outlined),
            setKey: SettingBoxKey.videoPlayerRemoveSafeArea,
            defaultVal: false,
            needReboot: true,
          ),
          const SetSwitchItem(
            title: 'Enable Infinite Scroll',
            subTitle: 'Disable to display as a single column',
            leading: Icon(Icons.view_array_outlined),
            setKey: SettingBoxKey.dynamicsWaterfallFlow,
            defaultVal: true,
            needReboot: true,
          ),
          ListTile(
            dense: false,
            title: Text('Dynamic page Up Main Display Position', style: titleStyle),
            leading: const Icon(Icons.person_outlined),
            subtitle:
                Text('Current: ${upPanelPosition.labels}', style: subTitleStyle),
            onTap: () async {
              UpPanelPosition? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<UpPanelPosition>(
                    title: 'Dynamic page Up Main Display Position',
                    value: upPanelPosition,
                    values: UpPanelPosition.values.map((e) {
                      return {'title': e.labels, 'value': e};
                    }).toList(),
                  );
                },
              );
              if (result != null) {
                upPanelPosition = result;
                setting.put(SettingBoxKey.upPanelPosition, result.code);
                SmartDialog.showToast('Restart to take effect');
                setState(() {});
              }
            },
          ),
          const SetSwitchItem(
            title: 'Show All Followed Up Dynamically',
            subTitle: 'And sort by most frequently visited Up',
            leading: Icon(Icons.people_alt_outlined),
            setKey: SettingBoxKey.dynamicsShowAllFollowedUp,
            defaultVal: false,
          ),
          ListTile(
            dense: false,
            onTap: () => settingController.setDynamicBadgeMode(context),
            title: Text('Dynamic Badges', style: titleStyle),
            leading: const Icon(Icons.motion_photos_on_outlined),
            subtitle: Obx(() => Text(
                'Current Badge Style: ${settingController.dynamicBadgeType.value.description}',
                style: subTitleStyle)),
          ),
          const SetSwitchItem(
            title: 'Hide Search Bar',
            subTitle: 'When the homepage list slides, hide the top bar',
            leading: Icon(Icons.vertical_align_top_outlined),
            setKey: SettingBoxKey.hideSearchBar,
            defaultVal: false,
            needReboot: true,
          ),
          const SetSwitchItem(
            title: 'Hide Tab Bar',
            subTitle: 'When the homepage list slides, hide the tab bar',
            leading: Icon(Icons.vertical_align_bottom_outlined),
            setKey: SettingBoxKey.hideTabBar,
            defaultVal: false,
            needReboot: true,
          ),
          ListTile(
            dense: false,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, StateSetter setState) {
                      final SettingController settingController =
                          Get.put(SettingController());
                      return AlertDialog(
                        title: const Text('Image Quality'),
                        contentPadding: const EdgeInsets.only(
                            top: 20, left: 8, right: 8, bottom: 8),
                        content: SizedBox(
                          height: 40,
                          child: Slider(
                            value: picQuality.toDouble(),
                            min: 10,
                            max: 100,
                            divisions: 9,
                            label: '$picQuality%',
                            onChanged: (double val) {
                              picQuality = val.toInt();
                              setState(() {});
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Get.back(),
                              child: Text('Cancel',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline))),
                          TextButton(
                            onPressed: () {
                              setting.put(
                                  SettingBoxKey.defaultPicQa, picQuality);
                              Get.back();
                              settingController.picQuality.value = picQuality;
                              GlobalData().imgQuality = picQuality;
                              SmartDialog.showToast('Operation Success');
                            },
                            child: const Text('Confirm'),
                          )
                        ],
                      );
                    },
                  );
                },
              );
            },
            title: Text('Image Quality', style: titleStyle),
            subtitle: Text('Select an image resolution, up to 100%', style: subTitleStyle),
            leading: const Icon(Icons.image_outlined),
            trailing: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Obx(
                () => Text(
                  '${settingController.picQuality.value}%',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          ),
          ListTile(
            dense: false,
            onTap: () async {
              double? result = await showDialog(
                context: context,
                builder: (context) {
                  return SlideDialog<double>(
                    title: 'Toast Opacity',
                    value: settingController.toastOpacity.value,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                  );
                },
              );
              if (result != null) {
                settingController.toastOpacity.value = result;
                SmartDialog.showToast('Operation Success');
                setting.put(SettingBoxKey.defaultToastOp, result);
              }
            },
            leading: const Icon(Icons.opacity_outlined),
            title: Text('Bubble Tooltip Opacity', style: titleStyle),
            subtitle: Text('Customize the opacity of Toast', style: subTitleStyle),
            trailing: Obx(() => Text(
                settingController.toastOpacity.value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleSmall)),
          ),
          ListTile(
            dense: false,
            onTap: () => settingController.setDefaultHomePage(context),
            leading: const Icon(Icons.home_outlined),
            title: Text('Default Startup Page', style: titleStyle),
            subtitle: Obx(() => Text(
                'Current Page: ${defaultNavigationBars.firstWhere((e) => e['id'] == settingController.defaultHomePage.value)['label']}',
                style: subTitleStyle)),
          ),
          ListTile(
            dense: false,
            onTap: () => Get.toNamed('/fontSizeSetting'),
            title: Text('Font Size Settings', style: titleStyle),
            leading: const Icon(Icons.format_size_outlined),
          ),
          ListTile(
            dense: false,
            onTap: () => Get.toNamed('/tabbarSetting'),
            title: Text('Tab Bar Settings', style: titleStyle),
            subtitle: Text('Delete or swap home page tabs', style: subTitleStyle),
            leading: const Icon(Icons.toc_outlined),
          ),
          if (Platform.isAndroid)
            ListTile(
              dense: false,
              onTap: () => Get.toNamed('/displayModeSetting'),
              title: Text('Refresh Rate Settings', style: titleStyle),
              leading: const Icon(Icons.autofps_select_outlined),
            )
        ],
      ),
    );
  }
}
