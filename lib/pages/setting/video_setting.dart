import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/models/video/play/quality.dart';
import 'package:PiliPalaX/models/video/play/CDN.dart';
import 'package:PiliPalaX/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'widgets/switch_item.dart';

class VideoSetting extends StatefulWidget {
  const VideoSetting({super.key});

  @override
  State<VideoSetting> createState() => _VideoSettingState();
}

class _VideoSettingState extends State<VideoSetting> {
  Box setting = GStorage.setting;
  late dynamic defaultVideoQa;
  late dynamic defaultAudioQa;
  late dynamic defaultDecode;
  late dynamic secondDecode;
  late dynamic hardwareDecoding;
  late dynamic videoSync;
  late dynamic defaultCDNService;

  @override
  void initState() {
    super.initState();
    defaultVideoQa = setting.get(SettingBoxKey.defaultVideoQa,
        defaultValue: VideoQuality.values.last.code);
    defaultAudioQa = setting.get(SettingBoxKey.defaultAudioQa,
        defaultValue: AudioQuality.values.last.code);
    defaultDecode = setting.get(SettingBoxKey.defaultDecode,
        defaultValue: VideoDecodeFormats.values.last.code);
    secondDecode = setting.get(SettingBoxKey.secondDecode,
        defaultValue: VideoDecodeFormats.values[1].code);
    hardwareDecoding = setting.get(SettingBoxKey.hardwareDecoding,
        defaultValue: Platform.isAndroid ? 'auto-safe' : 'auto');
    videoSync =
        setting.get(SettingBoxKey.videoSync, defaultValue: 'display-resample');
    defaultCDNService = setting.get(SettingBoxKey.CDNService,
        defaultValue: CDNService.backupUrl.code);
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
          'Audio & Video',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          const SetSwitchItem(
            title: 'Enable Hard Decoding',
            subTitle: 'Play videos with lower power consumption. If it freezes abnormally, please disable',
            leading: Icon(Icons.flash_on_outlined),
            setKey: SettingBoxKey.enableHA,
            defaultVal: true,
          ),
          const SetSwitchItem(
            title: 'No login 1080p',
            subTitle: 'Use 1080p quality without login',
            leading: Icon(Icons.hd_outlined),
            setKey: SettingBoxKey.p1080,
            defaultVal: true,
          ),
          ListTile(
            // enabled: false,
            // onTap: null,
            title: Text("Use BiliBili Proxy", style: titleStyle),
            subtitle: Text("If there is traffic directed to BiliBili and no proxy is used, it will be used automatically. You can check the traffic records of the operator to confirm that this function cannot be turned off.",
                style: subTitleStyle),
            leading: const Icon(Icons.perm_data_setting_outlined),
            trailing: Transform.scale(
              alignment: Alignment.centerRight, // 缩放Switch的大小后保持右侧对齐, 避免右侧空隙过大
              scale: 0.8,
              child: Switch(
                thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                    (Set<WidgetState> states) {
                  if (states.isNotEmpty &&
                      states.first == WidgetState.selected) {
                    return const Icon(Icons.lock_outline_rounded);
                  }
                  return null; // All other states will use the default thumbIcon.
                }),
                value: true,
                onChanged: (bool value) {
                  if (!value) {
                    SmartDialog.showToast('Since the app uses official interfaces, this function cannot be turned off.');
                  }
                },
              ),
            ),
          ),
          ListTile(
            title: Text('CDN Settings', style: titleStyle),
            leading: Icon(MdiIcons.cloudPlusOutline),
            subtitle: Text(
              'Using：${CDNServiceCode.fromCode(defaultCDNService)!.description}，Some CDNs may not work',
              style: subTitleStyle,
            ),
            onTap: () async {
              String? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<String>(
                      title: 'CDN Settings',
                      value: defaultCDNService,
                      values: CDNService.values.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultCDNService = result;
                setting.put(SettingBoxKey.CDNService, result);
                setState(() {});
              }
            },
          ),
          SetSwitchItem(
            title: 'Get audio without CDN',
            subTitle: 'Directly use alternate URL to fix some videos being silent',
            leading: Icon(MdiIcons.musicNotePlus),
            setKey: SettingBoxKey.disableAudioCDN,
            defaultVal: true,
          ),
          ListTile(
            dense: false,
            title: Text('Default Video Quality', style: titleStyle),
            leading: const Icon(Icons.video_settings_outlined),
            subtitle: Text(
              'Current Quality: ${VideoQualityCode.fromCode(defaultVideoQa)!.description!}',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: 'Default Video Quality',
                      value: defaultVideoQa,
                      values: VideoQuality.values.reversed.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultVideoQa = result;
                setting.put(SettingBoxKey.defaultVideoQa, result);
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('Default Audio Quality', style: titleStyle),
            leading: const Icon(Icons.music_video_outlined),
            subtitle: Text(
              'Current Quality: ${AudioQualityCode.fromCode(defaultAudioQa)!.description!}',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: 'Default Audio Quality',
                      value: defaultAudioQa,
                      values: AudioQuality.values.reversed.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultAudioQa = result;
                setting.put(SettingBoxKey.defaultAudioQa, result);
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('Preferred Decoding Format', style: titleStyle),
            leading: const Icon(Icons.movie_creation_outlined),
            subtitle: Text(
              'Selected Format: ${VideoDecodeFormatsCode.fromCode(defaultDecode)!.description!}，Please adjust according to device',
              style: subTitleStyle,
            ),
            onTap: () async {
              String? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<String>(
                      title: 'Select Decoding Format',
                      value: defaultDecode,
                      values: VideoDecodeFormats.values.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultDecode = result;
                setting.put(SettingBoxKey.defaultDecode, result);
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('Fallback Decoding Format', style: titleStyle),
            subtitle: Text(
              'Selected Format: ${VideoDecodeFormatsCode.fromCode(secondDecode)!.description!}，If no format is selected, default is used',
              style: subTitleStyle,
            ),
            leading: const Icon(Icons.swap_horizontal_circle_outlined),
            onTap: () async {
              String? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<String>(
                      title: 'Fallback Decoding Format',
                      value: secondDecode,
                      values: VideoDecodeFormats.values.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                secondDecode = result;
                setting.put(SettingBoxKey.secondDecode, result);
                setState(() {});
              }
            },
          ),
          if (Platform.isAndroid)
            const SetSwitchItem(
              title: 'Use OpenSL ES for Audio Output',
              leading: Icon(Icons.speaker_outlined),
              subTitle:
                  'If it is turned off, AudioTrack will be used to output audio (this item is --ao of mpv). If you encounter problems such as system sound loss, silence, audio and video out of sync, etc., please try to switch.',
              setKey: SettingBoxKey.useOpenSLES,
              defaultVal: false,
            ),
          const SetSwitchItem(
            title: 'Increase Buffer',
            leading: Icon(Icons.storage_outlined),
            subTitle: 'The default buffer is 4MB for video/16MB for live broadcast. Switching this will change it to 32MB/64MB, and may increase loading times',
            setKey: SettingBoxKey.expandBuffer,
            defaultVal: false,
          ),
          //video-sync
          ListTile(
            dense: false,
            title: Text('Video Sync', style: titleStyle),
            leading: const Icon(Icons.view_timeline_outlined),
            subtitle: Text(
              'Current：$videoSync（mpv --video-sync）',
              style: subTitleStyle,
            ),
            onTap: () async {
              String? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<String>(
                      title: 'Video Sync',
                      value: videoSync,
                      values: [
                        'audio',
                        'display-resample',
                        'display-resample-vdrop',
                        'display-resample-desync',
                        'display-tempo',
                        'display-vdrop',
                        'display-adrop',
                        'display-desync',
                        'desync'
                      ].map((e) {
                        return {'title': e, 'value': e};
                      }).toList());
                },
              );
              if (result != null) {
                setting.put(SettingBoxKey.videoSync, result);
                videoSync = result;
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('Hard Decoding Mode', style: titleStyle),
            leading: const Icon(Icons.memory_outlined),
            subtitle: Text(
              'Current: $hardwareDecoding（mpv --hwdec）',
              style: subTitleStyle,
            ),
            onTap: () async {
              String? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<String>(
                      title: 'Hard Decoding Mode',
                      value: hardwareDecoding,
                      values: ['auto', 'auto-copy', 'auto-safe', 'no', 'yes']
                          .map((e) {
                        return {'title': e, 'value': e};
                      }).toList());
                },
              );
              if (result != null) {
                setting.put(SettingBoxKey.hardwareDecoding, result);
                hardwareDecoding = result;
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }
}
