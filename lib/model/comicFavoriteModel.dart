import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/component/SubscribeCard.dart';
import 'package:dcomic/database/database.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/view/comic_detail_page.dart';

class ComicFavoriteModel extends BaseModel {
  final String uid;
  List comics = [];
  Map unreadList = {};
  int page = 0;

  ComicFavoriteModel(this.uid);

  Future<void> getSubscribe() async {
    CustomHttp http = CustomHttp();
    try {
      var response = await http.getSubscribe(int.parse(uid), page);
      if (response.statusCode == 200) {
        for (var item in response.data) {
          bool unread = item['sub_readed'] == 0;
          if (unreadList[item['id'].toString()] != null &&
              unreadList[item['id'].toString()] >= item['sub_uptime'] * 1000) {
            unread = false;
          }
          item['unread'] = unread;
        }
        comics += response.data;
      }
      notifyListeners();
    } catch (e) {
      logger.e(
          'class: ComicFavoriteModel, action: getSubscribeFailed, expection: $e');
    }
  }

  Future<void> nextPage() async {
    page++;
    await getSubscribe();
    notifyListeners();
  }

  Future<void> refresh() async {
    page = 0;
    comics.clear();
    DataBase dataBase = DataBase();
    unreadList = await dataBase.getAllUnread();
    await getSubscribe();
    notifyListeners();
  }

  List<Widget> getFavoriteWidget(context) {
    return comics
        .map<Widget>((e) => SubscribeCard(
              cover: e['sub_img'],
              title: e['name'],
              subTitle: e['sub_update'],
              isUnread: e['unread'],
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ComicDetailPage(id:e['id'].toString(),title: e['name'],)));
              },
            ))
        .toList();
  }

  bool get empty=>comics.length==0;

}
