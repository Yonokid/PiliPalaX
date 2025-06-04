import 'dart:ui';

import 'package:PiliPalaX/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:PiliPalaX/common/widgets/spring_physics.dart';

import 'controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginPageController _loginPageCtr = Get.put(LoginPageController());
  // late Future<Map<String, dynamic>> codeFuture;
  // 二维码生成时间
  bool showPassword = false;
  GlobalKey globalKey = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _loginPageCtr.dispose();
    super.dispose();
  }

  Widget loginByQRCode() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('Use the bilibili official app to scan the QR code and log in'),
        const SizedBox(height: 20),
        Obx(() => Text('Time until refresh: ${_loginPageCtr.qrCodeLeftTime}s',
            style: TextStyle(
                fontFeatures: const [FontFeature.tabularFigures()],
                color: Theme.of(context).colorScheme.primaryFixedDim))),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const SizedBox(width: 20),
            TextButton.icon(
              onPressed: _loginPageCtr.refreshQRCode,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh QR Code'),
            ),
            TextButton.icon(
              onPressed: () async {
                SmartDialog.showLoading(msg: 'Generating Screenshot');
                RenderRepaintBoundary boundary = globalKey.currentContext!
                    .findRenderObject()! as RenderRepaintBoundary;
                var image = await boundary.toImage();
                ByteData? byteData =
                    await image.toByteData(format: ImageByteFormat.png);
                Uint8List pngBytes = byteData!.buffer.asUint8List();
                SmartDialog.dismiss();
                SmartDialog.showLoading(msg: 'Saving to gallery');
                String picName =
                    "PiliPalaX_loginQRCode_${DateTime.now().toString().replaceAll(' ', '_').replaceAll(':', '-').split('.').first}";
                final SaveResult result = await SaverGallery.saveImage(
                  Uint8List.fromList(pngBytes),
                  fileName: picName,
                  extension: 'png',
                  // 保存到 PiliPalaX文件夹
                  androidRelativePath: "Pictures/PiliPalaX",
                  skipIfExists: false,
                );
                SmartDialog.dismiss();
                if (result.isSuccess) {
                  await SmartDialog.showToast('「$picName」 Saved ');
                } else {
                  await SmartDialog.showToast('Save Failed，${result.errorMessage}');
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save to album'),
            ),
          ],
        ),
        RepaintBoundary(
          key: globalKey,
          child: Obx(() {
            if (_loginPageCtr.codeInfo.value['data']?['url'] == null) {
              return const SizedBox(
                  height: 200,
                  width: 200,
                  child: Center(
                      child: CircularProgressIndicator(
                    semanticsLabel: 'QR Code Loading',
                  )));
            }
            final theme = Theme.of(context).colorScheme;
            final isDarkMode = theme.brightness == Brightness.dark;

            final bgColor = isDarkMode ? theme.onSurface : theme.surface;
            final dataColor = isDarkMode ? theme.onSecondary : theme.secondary;
            final eyeColor = isDarkMode ? theme.onPrimary : theme.primary;

            return QrImageView(
              backgroundColor: bgColor,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: eyeColor,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: dataColor,
              ),
              data: _loginPageCtr.codeInfo.value['data']!['url']!,
              size: 200,
              semanticsLabel: 'QR Code',
            );
          }),
        ),
        const SizedBox(height: 10),
        Obx(() => Text(
              _loginPageCtr.statusQRCode.value,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryFixedDim),
            )),
        Obx(() => GestureDetector(
              onTap: () {
                //以外部方式打开此链接
                // launchUrlString(
                //     _loginPageCtr.codeInfo.value['data']?['url'] ?? "",
                //     mode: LaunchMode.externalApplication);
                // 复制到剪贴板
                Clipboard.setData(ClipboardData(
                    text: _loginPageCtr.codeInfo.value['data']?['url'] ?? ""));
                SmartDialog.showToast('Copied to clipboard; Paste into the private message of the logged in app to send, then click the sent link to open',
                    displayTime: const Duration(seconds: 5));
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Text(_loginPageCtr.codeInfo.value['data']?['url'] ?? "",
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4))),
              ),
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Please be sure to download and install from trusted channels such as the PiliPalaX open source repository.',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4)))),
      ],
    );
  }

  Widget loginByPassword() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('Log in using your BiliBili Account'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            controller: _loginPageCtr.usernameTextController,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.account_box),
              border: const UnderlineInputBorder(),
              labelText: 'Account',
              hintText: 'Email/Phone Number',
              suffixIcon: IconButton(
                onPressed: _loginPageCtr.usernameTextController.clear,
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            obscureText: !showPassword,
            keyboardType: TextInputType.visiblePassword,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            controller: _loginPageCtr.passwordTextController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              border: const UnderlineInputBorder(),
              labelText: 'Password',
              suffixIcon: IconButton(
                onPressed: _loginPageCtr.passwordTextController.clear,
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 10),
            Checkbox(
              value: showPassword,
              onChanged: (value) {
                setState(() {
                  showPassword = value!;
                });
              },
            ),
            const Text('Remember Me'),
            const Spacer(),
            TextButton(
              onPressed: () {
                //https://passport.bilibili.com/h5-app/passport/login/findPassword
                //https://passport.bilibili.com/passport/findPassword
                showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: const Text('Forgot Password?'),
                      contentPadding:
                          const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 16.0),
                      children: [
                        const Padding(
                            padding: EdgeInsets.fromLTRB(25, 0, 25, 10),
                            child: Text("Try scanning the QR code, logging in with your phone number, or selecting")),
                        ListTile(
                            title: const Text(
                              'Forgot Password (Mobile Version)',
                            ),
                            leading: const Icon(Icons.smartphone_outlined),
                            subtitle: const Text(
                              'https://passport.bilibili.com/h5-app/passport/login/findPassword',
                            ),
                            dense: false,
                            onTap: () async {
                              Get.back();
                              Get.toNamed('/webview', parameters: {
                                'url':
                                    'https://passport.bilibili.com/h5-app/passport/login/findPassword',
                                'type': 'url',
                                'pageTitle': '忘记密码',
                              });
                            }),
                        ListTile(
                            title: const Text(
                              'Forgot Password (PC Version)',
                            ),
                            leading: const Icon(Icons.desktop_windows_outlined),
                            subtitle: const Text(
                              'https://passport.bilibili.com/pc/passport/findPassword',
                            ),
                            dense: false,
                            onTap: () async {
                              Get.back();
                              Get.toNamed('/webview', parameters: {
                                'url':
                                    'https://passport.bilibili.com/pc/passport/findPassword',
                                'type': 'url',
                                'pageTitle': '忘记密码',
                                'uaType': 'pc'
                              });
                            }),
                      ],
                    );
                  },
                );
              },
              child: const Text('Forgot Password?'),
            ),
            const SizedBox(width: 20),
          ],
        ),
        OutlinedButton.icon(
          onPressed: _loginPageCtr.loginByPassword,
          icon: const Icon(Icons.login),
          label: const Text('Login'),
        ),
        const SizedBox(height: 20),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
                'According to the official login interface specification of bilibili, the password will be salted and encrypted locally before transmission. \n'
                'The salt and public key are provided by the official; encrypted in RSA/ECB/PKCS1Padding. \n'
                'The account password is only used for this login interface and will not be saved; only login credentials are stored locally. \n'
                'Please be sure to download and install from trusted channels such as the PiliPalaX open source repository. ',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4)))),
      ],
    );
  }

  Widget loginBySmS() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('Log in using SMS Code'),
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: UnderlineTabIndicator(
                borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.phone),
                  const SizedBox(width: 12),
                  PopupMenuButton<Map<String, dynamic>>(
                    padding: EdgeInsets.zero,
                    tooltip: 'Select Country Code'
                        'Set as: ${_loginPageCtr.selectedCountryCodeId['cname']}，'
                        '+${_loginPageCtr.selectedCountryCodeId['country_id']}',
                    //position: PopupMenuPosition.under,
                    onSelected: (Map<String, dynamic> type) {},
                    itemBuilder: (BuildContext context) => Constants
                        .internationalDialingPrefix
                        .map((Map<String, dynamic> item) {
                      return PopupMenuItem<Map<String, dynamic>>(
                        onTap: () {
                          setState(() {
                            _loginPageCtr.selectedCountryCodeId = item;
                          });
                        },
                        value: item,
                        // height: menuItemHeight,
                        child: Row(children: [
                          Text(item['cname']),
                          const Spacer(),
                          Text("+${item['country_id']}")
                        ]),
                      );
                    }).toList(),
                    child: Text(
                        "+${_loginPageCtr.selectedCountryCodeId['country_id']}"),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    height: 24, // 这里设置固定高度
                    child: VerticalDivider(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                      child: TextField(
                    controller: _loginPageCtr.telTextController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Phone Number',
                      suffixIcon: IconButton(
                        onPressed: _loginPageCtr.telTextController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                  )),
                ],
              ),
            )),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: UnderlineTabIndicator(
                borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _loginPageCtr.smsCodeTextController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        border: InputBorder.none,
                        labelText: 'Code',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  Obx(() => TextButton.icon(
                        onPressed: _loginPageCtr.smsSendCooldown > 0
                            ? null
                            : _loginPageCtr.sendSmsCode,
                        icon: const Icon(Icons.send),
                        label: Text(_loginPageCtr.smsSendCooldown > 0
                            ? 'Wait ${_loginPageCtr.smsSendCooldown}s'
                            : 'Get Code'),
                      )),
                ],
              ),
            )),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _loginPageCtr.loginBySmsCode,
          icon: const Icon(Icons.login),
          label: const Text('Login'),
        ),
        const SizedBox(height: 20),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
                'The mobile phone number is only used for BiliBili Official to send verification codes and login interfaces, and will not be saved;\n'
                'Only login credentials are stored locally. \n'
                'Please be sure to download and install from trusted channels such as the PiliPalaX open source repository. ',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4)))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close_outlined),
              onPressed: Get.back),
          title: Row(children: [
            const Text('Login'),
            if (orientation == Orientation.landscape) ...[
              const Spacer(),
              Flexible(
                  child: TabBar(
                dividerHeight: 0,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.lock), Text(' Password')],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.email), Text(' SMS')],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.qr_code), Text(' QR Code')],
                    ),
                  ),
                ],
                controller: _loginPageCtr.tabController,
              ))
            ]
          ]),
          bottom: orientation == Orientation.portrait
              ? TabBar(
                  tabs: const [
                    Tab(icon: Icon(Icons.lock), text: 'Password'),
                    Tab(icon: Icon(Icons.email), text: 'SMS'),
                    Tab(icon: Icon(Icons.qr_code), text: 'QR Code'),
                  ],
                  controller: _loginPageCtr.tabController,
                )
              : null,
        ),
        body: NotificationListener(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              if (notification.metrics.axis == Axis.horizontal) {
                FocusScope.of(context).unfocus();
              }
            }
            return true;
          },
          child: TabBarView(
            physics: const CustomTabBarViewScrollPhysics(),
            controller: _loginPageCtr.tabController,
            children: [
              tabViewOuter(loginByPassword()),
              tabViewOuter(loginBySmS()),
              tabViewOuter(loginByQRCode()),
            ],
          ),
        ),
      );
    });
  }

  Widget tabViewOuter(child) {
    return SingleChildScrollView(
        child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 500,
              width: 600,
              child: child,
            )));
  }
}
