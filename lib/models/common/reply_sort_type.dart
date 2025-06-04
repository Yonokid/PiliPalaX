enum ReplySortType { time, like }

extension ReplySortTypeExtension on ReplySortType {
  String get titles => ['最新评论', '最热评论'][index];
  String get labels => ['Newest', 'Hottest'][index];
}
