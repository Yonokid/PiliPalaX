import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:PiliPalaX/http/index.dart';
import 'package:PiliPalaX/models/github/latest.dart';
import 'package:PiliPalaX/pages/setting/controller.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:PiliPalaX/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/cache_manage.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final AboutController _aboutController = Get.put(AboutController());
  String cacheSize = '';

  @override
  void initState() {
    super.initState();
    // 读取缓存占用
    getCacheSize();
  }

  Future<void> getCacheSize() async {
    final res = await CacheManage().loadApplicationCache();
    cacheSize = res;
    if (!mounted) return;
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    final Color outline = Theme.of(context).colorScheme.outline;
    TextStyle subTitleStyle =
        TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(
        title: Text('About', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: ListView(
        children: [
          Column(children: [
            Image.asset(
              excludeFromSemantics: true,
              height: 150,
              'assets/images/logo/logo_android_2.png',
            ),
            Text('PiliPalaX',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleMedium,
                semanticsLabel: 'PiliPalaX 与你一起，发现不一样的世界'),
            Text(
              '3rd Party BiliBili Client Developed with Flutter⁺',
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline, height: 3),
              semanticsLabel: '3rd Party BiliBili Client Developed with Flutter（带无障碍适配）',
            ),
          ]),
          Obx(
            () => ListTile(
              onTap: () => _aboutController.tapOnVersion(),
              title: const Text('Version'),
              leading: Icon(MdiIcons.sourceCommitLocal),
              trailing: Text(_aboutController.currentVersion.value,
                  style: subTitleStyle),
            ),
          ),
          Obx(
            () => ListTile(
              onTap: () => _aboutController.onUpdate(),
              title: const Text('Check for Updates'),
              leading: Icon(MdiIcons.newBox),
              trailing: Text(
                _aboutController.isLoading.value
                    ? 'Loading'
                    : _aboutController.isUpdate.value
                        ? 'New Version Available  ❤️${_aboutController.remoteVersion.value}'
                        : 'Using Latest Version',
                style: subTitleStyle,
              ),
            ),
          ),
          // ListTile(
          //   onTap: () {},
          //   title: const Text('更新日志'),
          //   trailing: const Icon(
          //     Icons.arrow_forward_ios,
          //     size: 16,
          //   ),
          // ),
          Divider(
            thickness: 1,
            height: 30,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          ListTile(
            onTap: () => _aboutController.githubUrl(),
            leading: Icon(MdiIcons.github),
            title: const Text('Github Repo⭐'),
            trailing: Text(
              'Github.com/Yonokid/PiliPalaX',
              style: subTitleStyle,
            ),
          ),
          ListTile(
            onTap: () => _aboutController.qqGroup(),
            leading: Icon(MdiIcons.qqchat),
            title: const Text('QQ (CN Only)'),
            trailing: Text(
              '392176105',
              style: subTitleStyle,
            ),
          ),
          ListTile(
            onTap: () => _aboutController.tgChannel(),
            leading: Icon(MdiIcons.sendCircle),
            title: const Text('Telegram (CN Only)'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: outline),
          ),
          ListTile(
            onTap: () => _aboutController.feedback(context),
            leading: Icon(MdiIcons.chatAlert),
            title: const Text('Feedback'),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: outline,
            ),
          ),
          // ListTile(
          //   onTap: () => _aboutController.aPay(),
          //   leading: const Icon(Icons.wallet_giftcard_outlined),
          //   title: const Text('赞赏'),
          //   trailing: Icon(Icons.arrow_forward_ios, size: 16, color: outline),
          // ),
          ListTile(
            onTap: () => _aboutController.logs(),
            leading: const Icon(Icons.bug_report),
            title: const Text('Report Bug'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: outline),
          ),
          ListTile(
            onTap: () async {
              await CacheManage().clearCacheAll(context);
              getCacheSize();
            },
            leading: const Icon(Icons.delete),
            title: const Text('Clear Cache'),
            trailing: Text('Image & Network Cache $cacheSize', style: subTitleStyle),
          ),
          ListTile(
              title: const Text('Import/Export Settings'),
              dense: false,
              leading: const Icon(Icons.import_export),
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: const Text('Import/Export Settings'),
                      children: [
                        ListTile(
                          title: const Text('Export Settings to Clipboard'),
                          onTap: () async {
                            Get.back();
                            String data = await GStorage.exportAllSettings();
                            Clipboard.setData(ClipboardData(text: data));
                            SmartDialog.showToast('Copied to clipboard');
                          },
                        ),
                        ListTile(
                          title: const Text('Import settings from clipboard'),
                          onTap: () async {
                            Get.back();
                            ClipboardData? data =
                                await Clipboard.getData('text/plain');
                            if (data == null ||
                                data.text == null ||
                                data.text!.isEmpty) {
                              SmartDialog.showToast('No data in clipboard');
                              return;
                            }
                            if (!context.mounted) return;
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Do you want to import the following settings?'),
                                  content: Text(data.text!),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Get.back();
                                        try {
                                          await GStorage.importAllSettings(
                                              data.text!);
                                          SmartDialog.showToast('Imported.');
                                        } catch (e) {
                                          SmartDialog.showToast('Import Failed：$e');
                                        }
                                      },
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              }),
          ListTile(
            title: const Text('Reset to Default Settings'),
            leading: const Icon(Icons.settings_backup_restore),
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Reset All Settings'),
                    content: const Text('Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          GStorage.setting.clear();
                          GStorage.video.clear();
                          SmartDialog.showToast('Reset Success.');
                        },
                        child: const Text('Reset Exportable Settings'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          GStorage.userInfo.clear();
                          GStorage.setting.clear();
                          GStorage.localCache.clear();
                          GStorage.video.clear();
                          GStorage.historyWord.clear();
                          GStorage.onlineCache.clear();
                          SmartDialog.showToast('Reset Success.');
                        },
                        child: const Text('Reset all data (including login information)'),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}

class AboutController extends GetxController {
  Box setting = GStorage.setting;
  final SettingController settingController = Get.put(SettingController());
  RxString currentVersion = ''.obs;
  RxString remoteVersion = ''.obs;
  late LatestDataModel remoteAppInfo;
  RxBool isUpdate = true.obs;
  RxBool isLoading = true.obs;
  LatestDataModel? data;
  RxInt count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // init();
    // 获取当前版本
    getCurrentApp();
    // 获取最新的版本
    getRemoteApp();
  }

  // 获取设备信息
  // Future init() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     print(androidInfo.supportedAbis);
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     print(iosInfo);
  //   }
  // }

  // 获取当前版本
  Future getCurrentApp() async {
    var currentInfo = await PackageInfo.fromPlatform();
    String buildNumber = currentInfo.buildNumber;
    //if is android
    if (Platform.isAndroid) {
      buildNumber = buildNumber.substring(0, buildNumber.length - 1);
    }
    currentVersion.value = "${currentInfo.version}+$buildNumber";
  }

  // 获取远程版本
  Future getRemoteApp() async {
    var result = await Request().get(Api.latestApp, extra: {'ua': 'pc'});
    if (result.data.isEmpty) {
      SmartDialog.showToast('检查更新失败，github接口未返回数据，请检查网络');
      return false;
    } else if (result.data[0] == null) {
      SmartDialog.showToast('检查更新失败，github接口返回如下内容：\n${result.data}');
      return false;
    }
    data = LatestDataModel.fromJson(result.data[0]);
    remoteAppInfo = data!;
    remoteVersion.value = data!.tagName!;
    isUpdate.value =
        Utils.needUpdate(currentVersion.value, remoteVersion.value);
    isLoading.value = false;
  }

  // 跳转下载/本地更新
  Future onUpdate() async {
    if (data == null) {
      SmartDialog.showLoading(msg: '正在尝试从Github获取最新版本');
      await getRemoteApp();
      SmartDialog.dismiss();
      return;
    }
    Utils.matchVersion(data);
  }

  // 跳转github
  githubUrl() {
    launchUrl(
      Uri.parse('https://github.com/orz12/pilipala'),
      mode: LaunchMode.externalApplication,
    );
  }

  githubRelease() {
    launchUrl(
      Uri.parse('https://github.com/guozhigq/pilipala/release'),
      mode: LaunchMode.externalApplication,
    );
  }

  // 从网盘下载
  panDownload() {
    Clipboard.setData(
      const ClipboardData(text: 'pili'),
    );
    SmartDialog.showToast(
      '已复制提取码：pili',
      displayTime: const Duration(milliseconds: 500),
    ).then(
      (value) => launchUrl(
        Uri.parse('https://www.123pan.com/s/9sVqVv-flu0A.html'),
        mode: LaunchMode.externalApplication,
      ),
    );
  }

  // 问题反馈
  feedback(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('问题反馈\n（建议直接加群）'),
          children: [
            ListTile(
              title: const Text('GitHub Issue'),
              onTap: () => launchUrl(
                Uri.parse('https://github.com/orz12/pilipala/issues'),
                // 系统自带浏览器打开
                mode: LaunchMode.externalApplication,
              ),
            ),
            // ListTile(
            //   title: const Text('腾讯兔小巢'),
            //   onTap: () => launchUrl(
            //     Uri.parse('https://support.qq.com/embed/phone/637735'),
            //     // 系统自带浏览器打开
            //     mode: LaunchMode.externalApplication,
            //   ),
            // ),
          ],
        );
      },
    );
  }

  // qq群
  qqGroup() {
    Clipboard.setData(
      const ClipboardData(text: '392176105'),
    );
    SmartDialog.showToast('已复制QQ群号');
    try {
      launchUrl(
        Uri.parse(
            'mqqapi://card/show_pslcard?src_type=internal&version=1&uin=392176105&card_type=group&source=qrcode'),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print(e);
    }
  }

  // tg群
  tgChannel() {
    Clipboard.setData(
      const ClipboardData(text: 'https://t.me/+162zlPtZlT9hNWVl'),
    );
    SmartDialog.showToast(
      '已复制，即将在浏览器打开',
      displayTime: const Duration(milliseconds: 500),
    ).then(
      (value) => launchUrl(
        Uri.parse('https://t.me/+162zlPtZlT9hNWVl'),
        mode: LaunchMode.externalApplication,
      ),
    );
  }

  // 官网
  // webSiteUrl() {
  //   launchUrl(
  //     Uri.parse('https://pilipalanet.mysxl.cn/pilipala-x'),
  //     mode: LaunchMode.externalApplication,
  //   );
  // }

  // aPay() {
  //   try {
  //     launchUrl(
  //       Uri.parse('https://pilipalanet.mysxl.cn/pilipalaxadmire'),
  //       mode: LaunchMode.externalApplication,
  //     );
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  aPay() {
    SmartDialog.showToast('感谢你的喜欢，给个Star就行~');
  }

  // 日志
  logs() {
    Get.toNamed('/logs');
  }

  tapOnVersion() {
    if (settingController.hiddenSettingUnlocked.value) {
      SmartDialog.showToast('您已解锁开发人员选项, 无需再次操作');
      return;
    }
    count.value++;
    if (count.value == 5) {
      setting.put(SettingBoxKey.hiddenSettingUnlocked, true);
      SmartDialog.showToast('恭喜您发现了开发人员选项!');
    }
  }
}
