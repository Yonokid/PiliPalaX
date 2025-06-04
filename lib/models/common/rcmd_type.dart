// 首页推荐类型
enum RcmdType { web, app, notLogin }

extension RcmdTypeExtension on RcmdType {
  String get values => ['web', 'app', 'notLogin'][index];
  String get labels => ['Web Based', 'App Based', 'Guest Mode'][index];
}
