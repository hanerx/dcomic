import 'dart:convert';

import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comicRankingListModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ComicLatestUpdateModel extends BaseModel {
  final BaseSourceModel model;
  int page = 0;
  List<RankingComic> _data = [];

  ComicLatestUpdateModel(this.model);

  getLatestList() async {
    try {
      _data += await model.homePageHandler.getLatestUpdate(page);
      notifyListeners();
      logger.i(
          'class: ComicLatestUpdateModel,action: getLatestList, page: $page');
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'getLatestListFailed');
      logger.e(
          'class: ComicLatestUpdateModel, action: getLatestListFailed, exception: $e');
    }
  }

  Future<void> refresh() async {
    page = 0;
    _data.clear();
    await getLatestList();
    notifyListeners();
  }

  Future<void> next() async {
    page++;
    await getLatestList();
    notifyListeners();
  }

  int get length => _data.length;

  List get data => _data;
}
