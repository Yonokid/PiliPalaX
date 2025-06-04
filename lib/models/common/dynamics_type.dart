import 'package:get/get.dart';
import '../../pages/dynamics/tab/controller.dart';
import '../../pages/dynamics/tab/view.dart';

enum DynamicsType {
  all,
  video,
  pgc,
  article,
  up,
}

extension BusinessTypeExtension on DynamicsType {
  String get values => ['all', 'video', 'pgc', 'article', 'up'][index];
  String get labels => ['All', 'Community', 'Anime', 'Article', 'Up'][index];
}

List tabsConfig = [
  {
    'value': DynamicsType.all,
    'label': 'All',
    'enabled': true,
    'ctr': Get.put<DynamicsTabController>(DynamicsTabController(), tag: 'all'),
    'page': const DynamicsTabPage(dynamicsType: 'all'),
  },
  {
    'value': DynamicsType.video,
    'label': 'Community',
    'enabled': true,
    'ctr':
        Get.put<DynamicsTabController>(DynamicsTabController(), tag: 'video'),
    'page': const DynamicsTabPage(dynamicsType: 'video'),
  },
  {
    'value': DynamicsType.pgc,
    'label': 'Anime',
    'enabled': true,
    'ctr': Get.put<DynamicsTabController>(DynamicsTabController(), tag: 'pgc'),
    'page': const DynamicsTabPage(dynamicsType: 'pgc'),
  },
  {
    'value': DynamicsType.article,
    'label': 'Article',
    'enabled': true,
    'ctr':
        Get.put<DynamicsTabController>(DynamicsTabController(), tag: 'article'),
    'page': const DynamicsTabPage(dynamicsType: 'article'),
  },
  {
    'value': DynamicsType.up,
    'label': 'Up',
    'enabled': true,
    'ctr': Get.put<DynamicsTabController>(DynamicsTabController(), tag: 'up'),
    'page': const DynamicsTabPage(dynamicsType: 'up'),
  },
];
