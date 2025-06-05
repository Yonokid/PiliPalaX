import 'dart:convert';
import 'package:PiliPalaX/http/constants.dart';
import 'package:PiliPalaX/http/init.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/http/member.dart';
import 'package:PiliPalaX/http/user.dart';
import 'package:PiliPalaX/http/video.dart';
import 'package:PiliPalaX/models/member/archive.dart';
import 'package:PiliPalaX/models/member/coin.dart';
import 'package:PiliPalaX/models/member/info.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'package:PiliPalaX/pages/video/introduction/widgets/group_panel.dart';

import '../../common/widgets/my_dialog.dart';

class MemberController extends GetxController with GetTickerProviderStateMixin {
  int? mid;
  MemberController({this.mid});
  Rx<MemberInfoModel> memberInfo = MemberInfoModel().obs;
  late Map userStat;
  RxString face = ''.obs;
  String? heroTag;
  Box userInfoCache = GStorage.userInfo;
  late int ownerMid;
  bool specialFollowed = false;
  // 投稿列表
  RxList<VListItemModel>? archiveList = <VListItemModel>[].obs;
  dynamic userInfo;
  RxInt attribute = (-1).obs;
  RxString attributeText = 'Follow'.obs;
  RxList<MemberCoinsDataModel> recentCoinsList = <MemberCoinsDataModel>[].obs;
  // String? wwebid;
  late TabController tabController;

  @override
  void onInit() async {
    super.onInit();
    mid = mid ?? int.parse(Get.parameters['mid']!);
    userInfo = userInfoCache.get('userInfoCache');
    ownerMid = userInfo?.mid ?? -1;
    face.value = Get.arguments?['face'] ?? '';
    heroTag = Get.arguments?['heroTag'] ?? '';
    tabController = TabController(length: 3, vsync: this);
  }

  // 获取用户信息
  Future<Map<String, dynamic>> getInfo() async {
    // await getMemberStat();
    // await getMemberView();
    // await getWwebid();
    var res = await MemberHttp.memberInfo(mid: mid);
    print(res);
    if (res['status']) {
      memberInfo.value = res['data'];
      relationSearch();
      face.value = res['data'].card?.face;
    } else {
      SmartDialog.showToast(res['msg']);
    }
    return res;
  }

  // Future getWwebid() async {
  //   try {
  //     dynamic response =
  //         await Request().get('${HttpString.spaceBaseUrl}/$mid/dynamic');
  //     dom.Document document = html_parser.parse(response.data);
  //     dom.Element? scriptElement =
  //         document.querySelector('script#__RENDER_DATA__');
  //     wwebid = jsonDecode(
  //         Uri.decodeComponent(scriptElement?.text ?? ''))['access_id'];
  //   } catch (e) {
  //     print('failed to get wwebid: $e');
  //   }
  // }

  // 获取用户状态
  // Future<Map<String, dynamic>> getMemberStat() async {
  //   var res = await MemberHttp.memberStat(mid: mid);
  //   if (res['status']) {
  //     userStat = res['data'];
  //   }
  //   return res;
  // }

  // 获取用户播放数 获赞数
  // Future<Map<String, dynamic>> getMemberView() async {
  //   var res = await MemberHttp.memberView(mid: mid!);
  //   if (res['status']) {
  //     userStat.addAll(res['data']);
  //   }
  //   return res;
  // }

  Future delayedUpdateRelation() async {
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      SmartDialog.showToast('Updating Status');
      // await relationSearch();
      await getInfo();
      // memberInfo.update((val) {});
    });
  }

  // 关注/取关up
  Future actionRelationMod(BuildContext context) async {
    if (userInfo == null) {
      SmartDialog.showToast('Not Logged In');
      return;
    }
    // if (memberInfo.value == null) {
    //   SmartDialog.showToast('尚未获取到用户信息');
    //   return;
    // }
    if (attribute.value == 128) {
      blockUser(context);
      return;
    }
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          actions: [
            if (memberInfo.value.card!.isFollow!) ...[
              TextButton(
                onPressed: () async {
                  final res = await MemberHttp.addUsers(
                    mid,
                    specialFollowed ? '0' : '-10',
                  );
                  SmartDialog.showToast(res['msg']);
                  if (res['status']) {
                    specialFollowed = !specialFollowed;
                  }
                  Get.back();
                  await delayedUpdateRelation();
                },
                child: Text(
                  specialFollowed
                      ? 'Remove Special Follow'
                      : 'Add Special Follow',
                ),
              ),
              TextButton(
                onPressed: () async {
                  Get.back();
                  await MyDialog.show(context, GroupPanel(mid: mid));
                  await delayedUpdateRelation();
                },
                child: const Text('Set up Group'),
              ),
            ],
            TextButton(
              onPressed: () async {
                var res = await VideoHttp.relationMod(
                  mid: mid!,
                  act: memberInfo.value.card!.isFollow! ? 2 : 1,
                  reSrc: 11,
                );
                SmartDialog.showToast(
                  res['status'] ? "Operation Success" : res['msg'],
                );
                if (res['status']) {
                  memberInfo.value.card!.isFollow =
                      !memberInfo.value.card!.isFollow!;
                }
                Get.back();
                await delayedUpdateRelation();
              },
              child: Text(
                memberInfo.value.card!.isFollow! ? 'Unfollow' : 'Follow',
              ),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
          ],
        );
      },
    );
  }

  // 关系查询
  Future relationSearch() async {
    attribute.value = memberInfo.value.card!.relationStatus!;
    switch (attribute.value) {
      case 2:
        attributeText.value = 'Following';
        break;
      case 3:
        attributeText.value = 'Follows you';
        break;
      case 4:
        attributeText.value = 'Mutuals';
        break;
      case 5:
        attributeText.value = 'Special Follow';
        break;
      case 128:
        attributeText.value = 'Blocked';
        break;
      case -999:
      default:
        attributeText.value = 'Follow';
    }
  }

  // 拉黑用户
  Future blockUser(BuildContext context) async {
    if (userInfo == null) {
      SmartDialog.showToast('Not Logged In');
      return;
    }
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hint'),
          content: Text(
            attribute.value != 128
                ? 'Are you sure you want to block UPs?'
                : 'Remove block from UP',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Disliked',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                var res = await VideoHttp.relationMod(
                  mid: mid!,
                  act: attribute.value != 128 ? 5 : 6,
                  reSrc: 11,
                );
                if (res['status']) {
                  attribute.value = attribute.value != 128 ? 128 : 0;
                  attributeText.value = attribute.value == 128
                      ? 'Blocked'
                      : 'Follow';
                  memberInfo.value.card!.isFollow = false;
                  relationSearch();
                  memberInfo.update((val) {});
                }
              },
              child: const Text('Default'),
            ),
          ],
        );
      },
    );
  }

  void shareUser() {
    Share.share(
      '${memberInfo.value.card!.name} - https://space.bilibili.com/$mid',
    );
  }

  // 请求投币视频
  Future getRecentCoinVideo() async {
    if (userInfo == null) return;
    var res = await MemberHttp.getRecentCoinVideo(mid: mid!);
    recentCoinsList.value = res['data'];
    return res;
  }

  // // 跳转查看动态
  // void pushDynamicsPage() => Get.toNamed('/memberDynamics?mid=$mid');
  //
  // // 跳转查看投稿
  // void pushArchivesPage() => Get.toNamed('/memberArchive?mid=$mid');
  //
  // // 跳转查看专栏
  // void pushSeasonsPage() {}
  // // 跳转查看最近投币
  // void pushRecentCoinsPage() async {
  //   if (recentCoinsList.isNotEmpty) {}
  // }
}
