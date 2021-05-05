import 'package:dcomic/database/historyDatabaseProvider.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/component/SubscribeCard.dart';
import 'package:dcomic/database/database.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/view/comic_detail_page.dart';

class ComicFavoriteModel extends BaseModel {
  final BaseSourceModel model;
  List<FavoriteComic> comics = [];
  int page = 0;
  String error = '没有更多数据了';

  ComicFavoriteModel(this.model);

  Future<void> getSubscribe() async {
    try {
      comics += await model.getFavoriteComics(page);
    } on UnimplementedError catch (e) {
      error = '该订阅模块尚未实现';
    } on FavoriteUnavailableError catch (e) {
      error = '该解析源不支持订阅';
    } on LoginRequiredError catch (e) {
      error = '该解析源需要登录，请先登录';
    } catch (e) {
      error = '未知错误: $e';
    }
    notifyListeners();
  }

  Future<void> nextPage() async {
    page++;
    await getSubscribe();
    notifyListeners();
  }

  Future<void> refresh() async {
    page = 0;
    comics.clear();
    await getSubscribe();
    notifyListeners();
  }

  List<Widget> getFavoriteWidget(context) {
    return comics
        .map<Widget>((e) => SubscribeCard(
              cover: e.cover,
              title: e.title,
              subTitle: e.latestChapter,
              isUnread: e.update,
              type: e.type,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ComicDetailPage(
                          id: e.comicId,
                          title: e.title,
                          model: e.model,
                        )));
              },
            ))
        .toList();
  }

  bool get empty => comics.length == 0;
}
