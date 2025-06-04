import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/http/user.dart';
import 'package:PiliPalaX/models/user/fav_folder.dart';
import 'package:PiliPalaX/utils/storage.dart';

class MediaController extends GetxController {
  Rx<FavFolderData> favFolderData = FavFolderData().obs;
  Box userInfoCache = GStorage.userInfo;
  RxBool userLogin = false.obs;
  List list = [
    // {
    //   'icon': Icons.file_download_outlined,
    //   'title': '离线缓存',
    //   'onTap': () {
    //     SmartDialog.showToast('功能开发中');
    //   },
    // },
    {
      'icon': Icons.history,
      'title': 'History',
      'onTap': () => Get.toNamed('/history'),
    },
    {
      'icon': Icons.subscriptions_outlined,
      'title': 'Subscriptions',
      'onTap': () => Get.toNamed('/subscription'),
    },
    {
      'icon': Icons.watch_later_outlined,
      'title': 'Watch Later',
      'onTap': () => Get.toNamed('/later'),
    },
    {
      'icon': Icons.create_outlined,
      'title': 'Creator Studio',
      'onTap': () => Get.toNamed('/webview', parameters: {
            'url': 'https://member.bilibili.com/platform/home',
            'type': 'url',
            'pageTitle': "创作中心（建议浏览器打开）",
          }),
    },
  ];
  var userInfo;
  int? mid;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    userLogin.value = userInfo != null;
  }

  Future<dynamic> queryFavFolder() async {
    if (!userLogin.value) {
      return {'status': false, 'data': [], 'msg': 'Not Logged In'};
    }
    var res = await await UserHttp.userfavFolder(
      pn: 1,
      ps: 10,
      mid: mid ?? GStorage.userInfo.get('userInfoCache').mid,
    );
    favFolderData.value = res['data'];
    return res;
  }
}
