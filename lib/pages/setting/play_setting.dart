import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPalaX/plugin/pl_player/index.dart';
import 'package:PiliPalaX/services/service_locator.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:PiliPalaX/plugin/pl_player/models/player_middle_gesture.dart';
import 'package:PiliPalaX/plugin/pl_player/models/player_gesture_action.dart';
import 'package:PiliPalaX/models/video/play/subtitle.dart';
import 'widgets/switch_item.dart';

class PlaySetting extends StatefulWidget {
  const PlaySetting({super.key});

  @override
  State<PlaySetting> createState() => _PlaySettingState();
}

class _PlaySettingState extends State<PlaySetting> {
  Box setting = GStorage.setting;
  late String defaultSubtitlePreference;
  late int defaultFullScreenMode;
  late int defaultBtmProgressBehavior;
  late Map<PlayerMiddleGesture, PlayerGestureAction> defaultMiddleGestureAction;

  @override
  void initState() {
    super.initState();
    defaultFullScreenMode = setting.get(SettingBoxKey.fullScreenMode,
        defaultValue: FullScreenMode.values.first.code);
    defaultBtmProgressBehavior = setting.get(SettingBoxKey.btmProgressBehavior,
        defaultValue: BtmProgressBehavior.values.first.code);
    defaultSubtitlePreference = setting.get(SettingBoxKey.subtitlePreference,
        defaultValue: SubtitlePreference.values.first.code);
  }

  @override
  void dispose() {
    super.dispose();

    // 重新验证媒体通知后台播放设置
    videoPlayerServiceHandler.revalidateSetting();
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
          'Player',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          SetSwitchItem(
            title: 'Danmaku Display',
            subTitle: 'Display Danmaku (Flying Comments)',
            leading: const Icon(Icons.comment_outlined),
            setKey: SettingBoxKey.enableShowDanmaku,
            defaultVal: true,
            callFn: (_) {
              PlPlayerController.updateSettingsIfExist();
            },
          ),
          ListTile(
            dense: false,
            onTap: () => Get.toNamed('/playSpeedSet'),
            leading: const Icon(Icons.speed_outlined),
            title: Text('Speed Settings', style: titleStyle),
            subtitle: Text('Set Video Playback Speed', style: subTitleStyle),
          ),
          SetSwitchItem(
            title: 'Autoplay',
            subTitle: 'Enable/Disable Autoplay',
            leading: Icon(MdiIcons.playPause),
            setKey: SettingBoxKey.autoPlayEnable,
            defaultVal: true,
            callFn: (_) {
              PlPlayerController.updateSettingsIfExist();
            },
          ),
          const SetSwitchItem(
            title: 'Double-click left or right to fast-forward/rewind',
            subTitle: 'If disabled, double-clicking will pause/play.',
            leading: Icon(Icons.touch_app_outlined),
            setKey: SettingBoxKey.enableQuickDouble,
            defaultVal: true,
          ),
          SetSwitchItem(
            title: 'Slide left or right to adjust brightness/volume',
            subTitle: 'If closed, vertical swipe gesture is used',
            leading: Icon(MdiIcons.tuneVerticalVariant),
            setKey: SettingBoxKey.enableAdjustBrightnessVolume,
            defaultVal: true,
          ),
          ListTile(
            dense: false,
            title: Text('Vertical Swipe Gesture', style: titleStyle),
            leading: Icon(MdiIcons.gestureSwipeVertical),
            subtitle: Text(
              'Set the corresponding operation for the gesture in the middle of the screen',
              style: subTitleStyle,
            ),
            onTap: () => Get.toNamed('/gestureSetting'),
          ),
          SetSwitchItem(
            title: 'Show Extra Fullscreen Features',
            subTitle: 'Add [Lock] and [Screenshot] buttons',
            leading: Icon(MdiIcons.oneUp),
            setKey: SettingBoxKey.enableExtraButtonOnFullScreen,
            defaultVal: true,
          ),
          ListTile(
            dense: false,
            title: Text('Auto-Enable Subtitles', style: titleStyle),
            leading: const Icon(Icons.closed_caption_outlined),
            subtitle: Text(
                'Selected: '
                '${SubtitlePreferenceCode.fromCode(defaultSubtitlePreference)!.description}',
                style: subTitleStyle),
            onTap: () async {
              String? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<String>(
                      title: 'Subtitle Preference',
                      value: setting.get(SettingBoxKey.subtitlePreference,
                          defaultValue: SubtitlePreference.values.first.code),
                      values: SubtitlePreference.values.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                setting.put(SettingBoxKey.subtitlePreference, result);
                PlPlayerController.updateSettingsIfExist();
                defaultSubtitlePreference = result;
                setState(() {});
              }
            },
          ),
          const SetSwitchItem(
            title: 'Autofill Vertical Screen',
            subTitle: 'The aspect ratio of half-screen vertical video is expanded from 16:9 to 1:1 (does not support collapsing); when adapted to horizontal screen, it is expanded to 9:16',
            leading: Icon(Icons.expand_outlined),
            setKey: SettingBoxKey.enableVerticalExpand,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: 'Auto Enter Fullscreen',
            subTitle: 'Enter fullscreen on video start',
            leading: Icon(Icons.fullscreen_outlined),
            setKey: SettingBoxKey.enableAutoEnter,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: 'Auto Exit Fullscreen',
            subTitle: 'Exit fullscreen on video end',
            leading: Icon(Icons.fullscreen_exit_outlined),
            setKey: SettingBoxKey.enableAutoExit,
            defaultVal: true,
          ),
          const SetSwitchItem(
              title: 'Show Video Controls Longer',
              subTitle: 'After it is turned on, it is extended to 30 seconds to facilitate the screen reader to slide and switch the control focus',
              leading: Icon(Icons.timer_outlined),
              setKey: SettingBoxKey.enableLongShowControl,
              defaultVal: false),
          const SetSwitchItem(
            title: 'Allow Screen Rotation',
            subTitle: 'Allows the video to rotate with phone',
            leading: Icon(Icons.screen_rotation_alt_outlined),
            setKey: SettingBoxKey.allowRotateScreen,
            defaultVal: true,
          ),
          SetSwitchItem(
            title: 'Background Play',
            subTitle: 'Continue playing in background',
            leading: Icon(MdiIcons.locationExit),
            setKey: SettingBoxKey.continuePlayInBackground,
            defaultVal: false,
            callFn: (_) {
              PlPlayerController.updateSettingsIfExist();
            },
          ),
          const SetSwitchItem(
              title: 'In-App Widget',
              subTitle: 'When leaving the playback page, continue playing in a small window',
              leading: Icon(Icons.tab_unselected_outlined),
              setKey: SettingBoxKey.autoMiniPlayer,
              defaultVal: false),
          if (Platform.isAndroid || Platform.isIOS)
            SetSwitchItem(
                title: 'Picture-in-Picture Mode',
                subTitle: 'Play in small window (PiP) when entering the background',
                leading: const Icon(Icons.picture_in_picture_alt),
                setKey: SettingBoxKey.autoPiP,
                defaultVal: false,
                callFn: (val) {
                  if (val &&
                      !setting.get(SettingBoxKey.enableBackgroundPlay,
                          defaultValue: true)) {
                    SmartDialog.showToast('Enabling background audio is recommended');
                  }
                }),
          if (Platform.isAndroid)
            const SetSwitchItem(
              title: 'Disable Danmaku on Background PiP',
              subTitle: 'Danmaku will not display in PiP Mode',
              leading: Icon(Icons.comments_disabled_outlined),
              setKey: SettingBoxKey.pipNoDanmaku,
              defaultVal: true,
            ),
          // const SetSwitchItem(
          //   title: '全屏手势方向',
          //   subTitle: '关闭时，在播放器中部向上滑动进入全屏，向下退出\n开启时，向下全屏，向上退出',
          //   leading: Icon(Icons.swap_vert_outlined),
          //   setKey: SettingBoxKey.fullScreenGestureReverse,
          //   defaultVal: false,
          // ),
          // SetSwitchItem(
          //   title: '启用应用内小窗手势',
          //   subTitle: '与全屏手势相反方向滑动时，触发应用内小窗',
          //   leading: Icon(MdiIcons.gestureSwipeVertical),
          //   setKey: SettingBoxKey.enableFloatingWindowGesture,
          //   defaultVal: true,
          // ),
          const SetSwitchItem(
            title: 'Show Viewers',
            subTitle: 'Display number of concurrent viewers',
            leading: Icon(Icons.people_outlined),
            setKey: SettingBoxKey.enableOnlineTotal,
            defaultVal: false,
          ),
          ListTile(
            dense: false,
            title: Text('Default Fullscreen Orientation', style: titleStyle),
            leading: const Icon(Icons.open_with_outlined),
            subtitle: Text(
              'Current Orientation: ${FullScreenModeCode.fromCode(defaultFullScreenMode)!.description}',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: 'Default Fullscreen Orientation',
                      value: defaultFullScreenMode,
                      values: FullScreenMode.values.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultFullScreenMode = result;
                setting.put(SettingBoxKey.fullScreenMode, result);
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('Progress Bar Display', style: titleStyle),
            leading: const Icon(Icons.border_bottom_outlined),
            subtitle: Text(
              'Display Mode: ${BtmProgresBehaviorCode.fromCode(defaultBtmProgressBehavior)!.description}',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: 'Progress Bar Display',
                      value: defaultBtmProgressBehavior,
                      values: BtmProgressBehavior.values.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultBtmProgressBehavior = result;
                setting.put(SettingBoxKey.btmProgressBehavior, result);
                setState(() {});
              }
            },
          ),
          const SetSwitchItem(
            title: 'Adjust System Brightness (Permission Required)',
            subTitle: 'If automatic brightness is turned on, there may be no change after adjustment; if it is turned off, adjust the brightness within the app (only effective in this app, and system brightness changes may be ignored during the effective period)',
            leading: Icon(Icons.brightness_6_outlined),
            setKey: SettingBoxKey.setSystemBrightness,
            defaultVal: false,
            needReboot: true,
          ),
          const SetSwitchItem(
            title: 'Background Audio',
            subTitle: 'Avoid Picture-in-Picture without playback and pause functions',
            leading: Icon(Icons.volume_up_outlined),
            setKey: SettingBoxKey.enableBackgroundPlay,
            defaultVal: true,
          ),
        ],
      ),
    );
  }
}
