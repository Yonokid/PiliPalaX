import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/http/member.dart';
import 'package:PiliPalaX/models/common/rcmd_type.dart';
import 'package:PiliPalaX/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPalaX/utils/recommend_filter.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:get/get.dart';

import 'widgets/switch_item.dart';

class RecommendSetting extends StatefulWidget {
  const RecommendSetting({super.key});

  @override
  State<RecommendSetting> createState() => _RecommendSettingState();
}

class _RecommendSettingState extends State<RecommendSetting> {
  Box setting = GStorage.setting;
  static Box localCache = GStorage.localCache;
  late dynamic defaultRcmdType;
  Box userInfoCache = GStorage.userInfo;
  late dynamic userInfo;
  bool userLogin = false;
  late dynamic accessKeyInfo;
  // late int filterUnfollowedRatio;
  late int minDurationForRcmd;
  late int minLikeRatioForRecommend;
  late String banWordForRecommend;

  @override
  void initState() {
    super.initState();
    // 首页默认推荐类型
    defaultRcmdType =
        setting.get(SettingBoxKey.defaultRcmdType, defaultValue: 'web');
    userInfo = userInfoCache.get('userInfoCache');
    userLogin = userInfo != null;
    accessKeyInfo = localCache.get(LocalCacheKey.accessKey, defaultValue: null);
    // filterUnfollowedRatio = setting
    //     .get(SettingBoxKey.filterUnfollowedRatio, defaultValue: 0);
    minDurationForRcmd =
        setting.get(SettingBoxKey.minDurationForRcmd, defaultValue: 0);
    minLikeRatioForRecommend =
        setting.get(SettingBoxKey.minLikeRatioForRecommend, defaultValue: 0);
    banWordForRecommend =
        setting.get(SettingBoxKey.banWordForRecommend, defaultValue: '');
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
          'Recommended Timeline Settings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            dense: false,
            title: Text('Homepage Recommended Type', style: titleStyle),
            leading: const Icon(Icons.model_training_outlined),
            subtitle: Text(
              'Using 「$defaultRcmdType Based」 Recommendations¹',
              style: subTitleStyle,
            ),
            onTap: () async {
              String? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<String>(
                    title: 'Recommendation Type',
                    value: defaultRcmdType,
                    values: RcmdType.values.map((e) {
                      return {'title': e.labels, 'value': e.values};
                    }).toList(),
                  );
                },
              );
              if (result != null) {
                if (result == 'app') {
                  if (accessKeyInfo == null) {
                    SmartDialog.showToast('Not Logged in, cannot use personalized recommendations ');
                  }
                }
                defaultRcmdType = result;
                setting.put(SettingBoxKey.defaultRcmdType, result);
                SmartDialog.showToast('Will take effect on restart');
                setState(() {});
              }
            },
          ),
          const SetSwitchItem(
            title: 'Recommended News',
            subTitle: 'Whether to display dynamic content in recommended content (app only)',
            leading: Icon(Icons.motion_photos_on_outlined),
            setKey: SettingBoxKey.enableRcmdDynamic,
            defaultVal: true,
          ),
          const SetSwitchItem(
            title: 'Homepage Recommendation Refresh',
            subTitle: 'Keep the last content when you pull down to refresh',
            leading: Icon(Icons.refresh),
            setKey: SettingBoxKey.enableSaveLastData,
            defaultVal: false,
          ),
          // 分割线
          const Divider(height: 1),
          ListTile(
            dense: false,
            leading: const Icon(Icons.thumb_up_outlined),
            title: Text('Like Rate Filter', style: titleStyle),
            subtitle: Text(
              'Filter out recommended videos with likes/playbacks less than $minLikeRatioForRecommend% (web only)',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: 'Select Rate (0 = No Filter)',
                      value: minLikeRatioForRecommend,
                      values: [0, 1, 2, 3, 4].map((e) {
                        return {'title': '$e %', 'value': e};
                      }).toList());
                },
              );
              if (result != null) {
                minLikeRatioForRecommend = result;
                setting.put(SettingBoxKey.minLikeRatioForRecommend, result);
                RecommendFilter.update();
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            leading: const Icon(Icons.title_outlined),
            title: Text('Title Keyword Filtering', style: titleStyle),
            subtitle: Text(
              banWordForRecommend.isEmpty ? "Click to add" : banWordForRecommend,
              style: subTitleStyle,
            ),
            onTap: () async {
              final TextEditingController textController =
                  TextEditingController(text: banWordForRecommend);
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Title Keyword Filtering'),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('Use spaces to separate, such as: 尝试 测试'),
                      TextField(
                        controller: textController,
                        //decoration: InputDecoration(hintText: hintText),
                      )
                    ]),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Clear'),
                        onPressed: () {
                          textController.text = '';
                        },
                      ),
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          SmartDialog.showToast('Keywords have not been modified');
                        },
                      ),
                      TextButton(
                        child: const Text('Save'),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          String filter = textController.text.trim();
                          banWordForRecommend = filter;
                          setting.put(SettingBoxKey.banWordForRecommend,
                              banWordForRecommend);
                          setState(() {});
                          RecommendFilter.update();
                          if (filter.isNotEmpty) {
                            SmartDialog.showToast('Saved：$banWordForRecommend');
                          } else {
                            SmartDialog.showToast('All keywords have been cleared');
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            dense: false,
            title: Text('Video Duration Filter', style: titleStyle),
            leading: const Icon(Icons.timelapse_outlined),
            subtitle: Text(
              'Filter out recommended videos with duration less than $minDurationForRcmd seconds',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: 'Select Duration (0 = No Filter)',
                      value: minDurationForRcmd,
                      values: [0, 30, 60, 90, 120].map((e) {
                        return {'title': '$e 秒', 'value': e};
                      }).toList());
                },
              );
              if (result != null) {
                minDurationForRcmd = result;
                setting.put(SettingBoxKey.minDurationForRcmd, result);
                RecommendFilter.update();
                setState(() {});
              }
            },
          ),
          SetSwitchItem(
            title: 'Following Filter Exemption',
            subTitle: 'Content posted by users you already follow in recommendations will not be filtered',
            leading: const Icon(Icons.favorite_border_outlined),
            setKey: SettingBoxKey.exemptFilterForFollowed,
            defaultVal: true,
            callFn: (_) {
              RecommendFilter.update();
            },
          ),
          // ListTile(
          //   dense: false,
          //   title: Text('按比例过滤未关注Up', style: titleStyle),
          //   subtitle: Text(
          //     '滤除推荐中占比「$filterUnfollowedRatio%」的未关注用户发布的内容',
          //     style: subTitleStyle,
          //   ),
          //   onTap: () async {
          //     int? result = await showDialog(
          //       context: context,
          //       builder: (context) {
          //         return SelectDialog<int>(
          //             title: '选择滤除比例（0即不过滤）',
          //             value: filterUnfollowedRatio,
          //             values: [0, 16, 32, 48, 64].map((e) {
          //               return {'title': '$e %', 'value': e};
          //             }).toList());
          //       },
          //     );
          //     if (result != null) {
          //       filterUnfollowedRatio = result;
          //       setting.put(
          //           SettingBoxKey.filterUnfollowedRatio, result);
          //       RecommendFilter.update();
          //       setState(() {});
          //     }
          //   },
          // ),
          SetSwitchItem(
            title: 'Apply Filter to Related Videos',
            subTitle: 'Related videos on the video details page are also filtered²',
            leading: const Icon(Icons.explore_outlined),
            setKey: SettingBoxKey.applyFilterToRelatedVideos,
            defaultVal: true,
            callFn: (_) {
              RecommendFilter.update();
            },
          ),
          SetSwitchItem(
            title: 'Disable Recommended Videos',
            subTitle: 'The related video area is displayed as blank, blocking the short, flat and fast immersive experience (when adapted to the horizontal screen, it can be used in conjunction with [Prioritize the display of the comment area])',
            leading: const Icon(Icons.explore_off_outlined),
            setKey: SettingBoxKey.disableRelatedVideos,
            defaultVal: false,
            callFn: (_) {
              RecommendFilter.update();
            },
          ),
          ListTile(
            dense: true,
            subtitle: Text(
                '¹ If the default web-side recommendation does not meet your expectations, you can try switching to the app side. \n'
                '¹ Select "Guest Mode (notLogin)", and the app recommendation interface will be requested with an empty key, but the playback page will still carry user information to ensure that the account can record progress, like and coin normally. \n\n'
                '² Since the interface does not provide follow information, it is not possible to exempt the Up in the related videos. \n\n'
                '* Others (such as popular videos, manual search, link jump, etc.) are not affected by the filter. \n'
                '* Setting more stringent conditions may lead to a sharp drop in the number of recommended items or multiple requests, please choose as appropriate. \n'
                '* More filtering conditions may be added in the future, so stay tuned. ',
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.7)),
            ),
          )
        ],
      ),
    );
  }
}
