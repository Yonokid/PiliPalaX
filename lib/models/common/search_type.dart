// ignore_for_file: constant_identifier_names
enum SearchType {
  // 视频：video
  video,
  // 番剧：media_bangumi,
  media_bangumi,
  // 影视：media_ft
  // media_ft,
  // 直播间及主播：live
  // live,
  // 直播间：live_room
  live_room,
  // 主播：live_user
  // live_user,
  // 话题：topic
  // topic,
  // 用户：bili_user
  bili_user,
  // 专栏：article
  article,
  // 相簿：photo
  // photo
}

extension SearchTypeExtension on SearchType {
  String get type =>
      ['video', 'media_bangumi', 'live_room', 'bili_user', 'article'][index];
  String get label => ['Video', 'Anime', 'Live', 'User', 'Article'][index];
}

// 搜索类型为视频、专栏及相簿时
enum ArchiveFilterType {
  totalrank,
  click,
  pubdate,
  dm,
  stow,
  scores,
  // 专栏
  // attention,
}

extension ArchiveFilterTypeExtension on ArchiveFilterType {
  String get description =>
      ['Default', 'Most Viewed', 'New', 'Most Danmaku', 'Most Saved', 'Most COmments', 'Most Liked'][index];
}
