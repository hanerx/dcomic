import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/SubscribeCard.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/baseModel.dart';
import 'package:flutterdmzj/view/novel_pages/novel_detail_page.dart';

class NovelFavoriteModel extends BaseModel{
  final String uid;
  List novels=[];
  int page=0;

  NovelFavoriteModel(this.uid);

  Future<void> getSubscribe() async {
    CustomHttp http = CustomHttp();
    try{
      var response =
      await http.getSubscribe(int.parse(uid), page, type: 1);
      if (response.statusCode == 200) {
        for (var item in response.data) {
          bool unread = item['sub_readed'] == 0;
          item['unread'] = unread;
        }
        novels+=response.data;
      }
      notifyListeners();
    }catch(e){
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
            builder: (context) => NovelDetailPage(id: e['id'],)));
      },
    ))
        .toList();
  }

  bool get empty=>novels.length==0;
}