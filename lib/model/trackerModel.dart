import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/SubscribeCard.dart';
import 'package:flutterdmzj/database/tracker.dart';
import 'package:flutterdmzj/model/baseModel.dart';
import 'package:flutterdmzj/model/comicDetail.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';

class TrackerModel extends BaseModel {
  List<TracingComic> tracingComic = [];
  TrackerProvider _provider = TrackerProvider();

  TrackerModel() {
    init();
  }

  Future<void> init() async {
    tracingComic = await _provider.getAllComic();
    notifyListeners();
  }

  List<Widget> getFavoriteWidget(context) {
    return tracingComic
        .map<Widget>((e) => SubscribeCard(
              cover: e.cover,
              title: e.title,
              subTitle: '无',
              isUnread: false,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ComicDetailPage(e.comicId)));
              },
            ))
        .toList();
  }

  Future<void> add(ComicDetailModel model) async {
    var comic = await _provider.insertComic(model.model);
    tracingComic.add(comic);
    notifyListeners();
  }

  Future<void> delete(ComicDetailModel model) async {
    await _provider.deleteComic(model.comicId);
    await init();
    notifyListeners();
  }

  Future<void> subscribe(ComicDetailModel model) async {
    if (await _provider.getComic(model.comicId) == null) {
      await add(model);
    } else {
      await delete(model);
    }
    notifyListeners();
  }
}
