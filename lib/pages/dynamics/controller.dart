// ignore_for_file: avoid_print

import 'package:PiliPalaX/http/follow.dart';
import 'package:PiliPalaX/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/http/dynamics.dart';
import 'package:PiliPalaX/http/search.dart';
import 'package:PiliPalaX/models/bangumi/info.dart';
import 'package:PiliPalaX/models/common/dynamics_type.dart';
import 'package:PiliPalaX/models/common/search_type.dart';
import 'package:PiliPalaX/models/dynamics/result.dart';
import 'package:PiliPalaX/models/dynamics/up.dart';
import 'package:PiliPalaX/models/live/item.dart';
import 'package:PiliPalaX/utils/feed_back.dart';
import 'package:PiliPalaX/utils/id_utils.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:PiliPalaX/utils/utils.dart';

import '../../models/follow/result.dart';

class DynamicsController extends GetxController
    with GetTickerProviderStateMixin {
  String? offset = '';
  final ScrollController scrollController = ScrollController();
  Rx<FollowUpModel> upData = FollowUpModel().obs;
  // 默认获取全部动态
  RxInt mid = (-1).obs;
  Rx<UpItem> upInfo = UpItem().obs;
  late TabController tabController;
  RxList<int> tempBannedList = <int>[].obs;
  late List<Widget> tabsPageList;
  bool flag = false;
  RxInt initialValue = 0.obs;
  Box userInfoCache = GStorage.userInfo;
  RxBool userLogin = false.obs;
  var userInfo;
  RxBool isLoadingDynamic = false.obs;
  Box setting = GStorage.setting;
  List<UpItem> hasUpdatedUps = <UpItem>[];
  List<UpItem> allFollowedUps = <UpItem>[];
  int allFollowedUpsPage = 1;
  int allFollowedUpsTotal = 0;

  @override
  void onInit() {
    userInfo = userInfoCache.get('userInfoCache');
    userLogin.value = userInfo != null;
    super.onInit();

    tabController = TabController(
      length: tabsConfig.length,
      vsync: this,
      initialIndex: setting.get(
        SettingBoxKey.defaultDynamicType,
        defaultValue: 0,
      ),
    );
    tabsPageList = tabsConfig.map((e) {
      return e['page'] as Widget;
    }).toList();
  }

  void refreshNotifier() {
    queryFollowUp();
  }

  onSelectType(value) async {
    initialValue.value = value;
  }

  pushDetail(item, floor, {action = 'all'}) async {
    feedBack();

    /// 点击评论action 直接查看评论
    if (action == 'comment') {
      Get.toNamed(
        '/dynamicDetail',
        arguments: {'item': item, 'floor': floor, 'action': action},
      );
      return false;
    }
    switch (item!.type) {
      /// 转发的动态
      case 'DYNAMIC_TYPE_FORWARD':
        Get.toNamed(
          '/dynamicDetail',
          arguments: {'item': item, 'floor': floor},
        );
        break;

      /// 图文动态查看
      case 'DYNAMIC_TYPE_DRAW':
        Get.toNamed(
          '/dynamicDetail',
          arguments: {'item': item, 'floor': floor},
        );
        break;
      case 'DYNAMIC_TYPE_AV':
        String bvid = item.modules.moduleDynamic.major.archive.bvid;
        String cover = item.modules.moduleDynamic.major.archive.cover;
        try {
          int cid = await SearchHttp.ab2c(bvid: bvid);
          Get.toNamed(
            '/video?bvid=$bvid&cid=$cid',
            arguments: {'pic': cover, 'heroTag': bvid},
          );
        } catch (err) {
          SmartDialog.showToast(err.toString());
        }
        break;

      /// 专栏文章查看
      case 'DYNAMIC_TYPE_ARTICLE':
        String title = item.modules.moduleDynamic.major.opus.title;
        String url = item.modules.moduleDynamic.major.opus.jumpUrl;
        if (url.contains('opus') || url.contains('read')) {
          RegExp digitRegExp = RegExp(r'\d+');
          Iterable<Match> matches = digitRegExp.allMatches(url);
          String number = matches.first.group(0)!;
          if (url.contains('read')) {
            number = 'cv$number';
          }
          Get.toNamed(
            '/htmlRender',
            parameters: {
              'url': url.startsWith('//') ? url.split('//').last : url,
              'title': title,
              'id': number,
              'dynamicType': url.split('//').last.split('/')[1],
            },
          );
        } else {
          Get.toNamed(
            '/webview',
            parameters: {
              'url': 'https:$url',
              'type': 'note',
              'pageTitle': title,
            },
          );
        }

        break;
      case 'DYNAMIC_TYPE_PGC':
        print('番剧');
        SmartDialog.showToast('暂未支持的类型，请联系开发者');
        break;

      /// 纯文字动态查看
      case 'DYNAMIC_TYPE_WORD':
        print('纯文本');
        Get.toNamed(
          '/dynamicDetail',
          arguments: {'item': item, 'floor': floor},
        );
        break;
      case 'DYNAMIC_TYPE_LIVE_RCMD':
        DynamicLiveModel liveRcmd = item.modules.moduleDynamic.major.liveRcmd;
        ModuleAuthorModel author = item.modules.moduleAuthor;
        LiveItemModel liveItem = LiveItemModel.fromJson({
          'title': liveRcmd.title,
          'uname': author.name,
          'cover': liveRcmd.cover,
          'mid': author.mid,
          'face': author.face,
          'roomid': liveRcmd.roomId,
          'watched_show': liveRcmd.watchedShow,
        });
        Get.toNamed(
          '/liveRoom?roomid=${liveItem.roomId}',
          arguments: {
            'liveItem': liveItem,
            'heroTag': liveItem.roomId.toString(),
          },
        );
        break;

      /// 合集查看
      case 'DYNAMIC_TYPE_UGC_SEASON':
        DynamicArchiveModel ugcSeason =
            item.modules.moduleDynamic.major.ugcSeason;
        int aid = ugcSeason.aid!;
        String bvid = IdUtils.av2bv(aid);
        String cover = ugcSeason.cover!;
        int cid = await SearchHttp.ab2c(bvid: bvid);
        Get.toNamed(
          '/video?bvid=$bvid&cid=$cid',
          arguments: {'pic': cover, 'heroTag': bvid},
        );
        break;

      /// 番剧查看
      case 'DYNAMIC_TYPE_PGC_UNION':
        print('DYNAMIC_TYPE_PGC_UNION 番剧');
        DynamicArchiveModel pgc = item.modules.moduleDynamic.major.pgc;
        if (pgc.epid != null) {
          SmartDialog.showLoading(msg: '获取中...');
          var res = await SearchHttp.bangumiInfo(epId: pgc.epid);
          SmartDialog.dismiss();
          if (res['status']) {
            EpisodeItem episode = res['data'].episodes.first;
            int? epId = res['data'].userStatus?.progress?.lastEpId;
            if (epId == null) {
              epId = episode.epId;
            } else {
              for (var item in res['data'].episodes) {
                if (item.epId == epId) {
                  episode = item;
                  break;
                }
              }
            }
            String bvid = episode.bvid!;
            int cid = episode.cid!;
            String pic = episode.cover!;
            String heroTag = Utils.makeHeroTag(cid);
            Get.toNamed(
              '/video?bvid=$bvid&cid=$cid&seasonId=${res['data'].seasonId}&epid=$epId',
              arguments: {
                'pic': pic,
                'heroTag': heroTag,
                'videoType': SearchType.media_bangumi,
                'bangumiItem': res['data'],
              },
            );
          } else {
            SmartDialog.showToast(res['msg']);
          }
        }
        break;
    }
  }

  Future queryFollowing2() async {
    if (allFollowedUps.length >= allFollowedUpsTotal) {
      SmartDialog.showToast('Nothing Here');
      return;
    }
    var res = await FollowHttp.followings(
      vmid: userInfo.mid,
      pn: allFollowedUpsPage,
      ps: 50,
      orderType: 'attention',
    );
    if (res['status']) {
      allFollowedUps.addAll(
        res['data'].list.map<UpItem>(
          (FollowItemModel e) => UpItem(
            face: e.face,
            mid: e.mid,
            uname: e.uname,
            hasUpdate: hasUpdatedUps.any(
              (element) =>
                  (element.mid == e.mid) && (element.hasUpdate == true),
            ),
          ),
        ),
      );
      allFollowedUpsPage += 1;
      allFollowedUpsTotal = res['data'].total;
      upData.value.upList = allFollowedUps;
      upData.refresh();
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  Future queryFollowUp({type = 'init'}) async {
    if (!userLogin.value) {
      return {'status': false, 'msg': 'Not Logged In'};
    }
    if (type == 'init') {
      upData.value.upList = [];
      upData.value.liveUsers = LiveUsers();
    }
    if (setting.get(
      SettingBoxKey.dynamicsShowAllFollowedUp,
      defaultValue: false,
    )) {
      allFollowedUpsPage = 1;
      Future f1 = DynamicsHttp.followUp();
      Future f2 = FollowHttp.followings(
        vmid: userInfo.mid,
        pn: allFollowedUpsPage,
        ps: 50,
        orderType: 'attention',
      );
      List<dynamic> ress = await Future.wait([f1, f2]);
      if (!ress[0]['status']) {
        SmartDialog.showToast("获取关注动态失败：${ress[0]['msg']}");
      } else {
        upData.value.liveUsers = ress[0]['data'].liveUsers;
        hasUpdatedUps = ress[0]['data'].upList!;
      }
      if (!ress[1]['status']) {
        SmartDialog.showToast("获取关注列表失败：${ress[1]['msg']}");
      } else {
        allFollowedUps = ress[1]['data'].list
            .map<UpItem>(
              (FollowItemModel e) => UpItem(
                face: e.face,
                mid: e.mid,
                uname: e.uname,
                hasUpdate: hasUpdatedUps.any(
                  (element) =>
                      (element.mid == e.mid) && (element.hasUpdate == true),
                ),
              ),
            )
            .toList();
        allFollowedUpsPage += 1;
        allFollowedUpsTotal = ress[1]['data'].total;
      }
      upData.value.upList = allFollowedUpsTotal > 0
          ? allFollowedUps
          : hasUpdatedUps;
      return ress[0];
    }
    var res = await DynamicsHttp.followUp();
    if (res['status']) {
      upData.value = res['data'];
      if (upData.value.upList!.isEmpty) {
        mid.value = -1;
      }
    }
    return res;
  }

  onSelectUp(mid) async {
    if (mid == this.mid.value) {
      this.mid.refresh();
      return;
    }
    this.mid.value = mid;
    tabController.index = (mid == -1 ? 0 : 4);
  }

  onRefresh() async {
    print('onRefresh');
    print(tabsConfig[tabController.index]['ctr']);
    await Future.wait(<Future>[
      queryFollowUp(),
      tabsConfig[tabController.index]['ctr'].onRefresh(),
    ]);
  }

  // 返回顶部并刷新
  void animateToTop() async {
    tabsConfig[tabController.index]['ctr'].animateToTop();
    scrollController.animToTop();
  }
}
