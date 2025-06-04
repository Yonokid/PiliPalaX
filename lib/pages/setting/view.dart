import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/pages/setting/index.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingController settingController = Get.put(SettingController());
    final TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    final TextStyle subTitleStyle = Theme.of(context)
        .textTheme
        .labelMedium!
        .copyWith(color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () => Get.toNamed('/privacySetting'),
            dense: false,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy', style: titleStyle),
            subtitle: Text('Blacklist, access_key Refresh, Incognito Mode', style: subTitleStyle),
          ),
          ListTile(
            onTap: () => Get.toNamed('/recommendSetting'),
            dense: false,
            leading: const Icon(Icons.explore_outlined),
            title: Text('Recommendations', style: titleStyle),
            subtitle: Text('Sources (web/app), Refresh Retention Content, Filters', style: subTitleStyle),
          ),
          ListTile(
            onTap: () => Get.toNamed('/videoSetting'),
            leading: const Icon(Icons.video_settings_outlined),
            dense: false,
            title: Text('Video', style: titleStyle),
            subtitle: Text('Image Quality, Sound quality, Decoding, Buffering, Audio Output', style: subTitleStyle),
          ),
          ListTile(
            onTap: () => Get.toNamed('/playSetting'),
            leading: const Icon(Icons.touch_app_outlined),
            dense: false,
            title: Text('Player', style: titleStyle),
            subtitle: Text('Double-click/long press, Fullscreen, Background Play, Subtitles, Progress Bar', style: subTitleStyle),
          ),
          ListTile(
            onTap: () => Get.toNamed('/styleSetting'),
            leading: const Icon(Icons.style_outlined),
            dense: false,
            title: Text('Style', style: titleStyle),
            subtitle: Text('Horizontal Settings (Tablet), Sidebar, Article Width, Homepage, Notifications, Theme, Font Size, Refresh Rate',
                style: subTitleStyle),
          ),
          ListTile(
            onTap: () => Get.toNamed('/extraSetting'),
            leading: const Icon(Icons.extension_outlined),
            dense: false,
            title: Text('Other', style: titleStyle),
            subtitle: Text('Vibration, Search, Collection, AI, Comments, Update Check', style: subTitleStyle),
          ),
          Obx(
            () => Visibility(
              visible: settingController.hiddenSettingUnlocked.value,
              child: ListTile(
                leading: const Icon(Icons.developer_board_outlined),
                onTap: () => Get.toNamed('/hiddenSetting'),
                dense: false,
                title: Text('Developer Options', style: titleStyle),
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: settingController.userLogin.value,
              child: ListTile(
                leading: const Icon(Icons.logout_outlined),
                onTap: () => settingController.loginOut(context),
                dense: false,
                title: Text('Log Out', style: titleStyle),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            onTap: () => Get.toNamed('/about'),
            dense: false,
            title: Text('About', style: titleStyle),
          ),
        ],
      ),
    );
  }
}
