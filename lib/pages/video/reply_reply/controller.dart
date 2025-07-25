import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/http/reply.dart';
import 'package:PiliPalaX/models/common/reply_type.dart';
import 'package:PiliPalaX/models/video/reply/item.dart';

class VideoReplyReplyController extends GetxController {
  VideoReplyReplyController(this.aid, this.rpid, this.replyType);
  final ScrollController scrollController = ScrollController();
  // 视频aid 请求时使用的oid
  int? aid;
  // rpid 请求楼中楼回复
  String? rpid;
  ReplyType replyType; // = ReplyType.video;
  RxList<ReplyItemModel> replyList = <ReplyItemModel>[].obs;
  // 当前页
  int currentPage = 0;
  bool isLoadingMore = false;
  RxString noMore = ''.obs;
  // 当前回复的回复
  ReplyItemModel? currentReplyItem;
  ReplyItemModel? root;

  @override
  void onInit() {
    super.onInit();
    currentPage = 0;
  }

  Future queryReplyList({type = 'init'}) async {
    if (type == 'init') {
      currentPage = 0;
    }
    if (isLoadingMore) {
      return;
    }
    isLoadingMore = true;
    final res = await ReplyHttp.replyReplyList(
      oid: aid!,
      root: rpid!,
      pageNum: currentPage + 1,
      type: replyType.index,
    );
    if (res['status']) {
      if (res['data'].root != null) root = res['data'].root;
      final List<ReplyItemModel> replies = res['data'].replies;
      if (replies.isNotEmpty) {
        noMore.value = '加载中...';
        if (replies.length == res['data'].page.count) {
          noMore.value = 'Nothing Here';
        }
        currentPage++;
      } else {
        // 未登录状态replies可能返回null
        noMore.value = currentPage == 0 ? '还没有评论' : 'Nothing Here';
      }
      if (type == 'init') {
        replyList.value = replies;
      } else {
        // 每次回复之后，翻页请求有且只有相同的一条回复数据
        if (replies.length == 1 && replies.last.rpid == replyList.last.rpid) {
          return;
        }
        replyList.addAll(replies);
        // res['data'].replies.addAll(replyList);
      }
    }
    isLoadingMore = false;
    return res;
  }

  @override
  void onClose() {
    currentPage = 0;
    super.onClose();
  }
}
