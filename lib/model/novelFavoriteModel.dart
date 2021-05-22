import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/component/SubscribeCard.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/view/novel_pages/novel_detail_page.dart';

class NovelFavoriteModel extends BaseModel {
  final String uid;
  List novels = [];
  int page = 0;

  NovelFavoriteModel(this.uid);

  Future<void> getSubscribe() async {
    try {
      var response = await UniversalRequestModel.dmzjRequestHandler
          .getSubscribe(int.parse(uid), page, type: 1);
      if (response.statusCode == 200) {
        for (var item in response.data) {
          bool unread = item['sub_readed'] == 0;
          item['unread'] = unread;
        }
        novels += response.data;
      }
      notifyListeners();
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'getSubscribeFailed');
      logger.e(
          'class: NovelFavoriteModel, action: getSubscribeFailed, expection: $e');
    }
  }

  Future<void> nextPage() async {
    page++;
    await getSubscribe();
    notifyListeners();
  }

  Future<void> refresh() async {
    page = 0;
    novels.clear();
    await getSubscribe();
    notifyListeners();
  }

  List<Widget> getFavoriteWidget(context) {
    return novels
        .map<Widget>((e) => SubscribeCard(
              cover: e['sub_img'],
              title: e['name'],
              subTitle: e['sub_update'],
              isUnread: e['unread'],
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NovelDetailPage(
                          id: e['id'],
                        )));
              },
            ))
        .toList();
  }

  bool get empty => novels.length == 0;
}
