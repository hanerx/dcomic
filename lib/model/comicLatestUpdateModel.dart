import 'dart:convert';

import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comicRankingListModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ComicLatestUpdateModel extends BaseModel {
  int filterTag = 100;
  int page = 0;
  List _data = [];
  Map tagTypeList = <int, String>{100: '全部漫画', 1: '原创漫画', 0: '译制漫画'};

  getLatestList() async {
    try {
      var response=await UniversalRequestModel.dmzjMobileRequestHandler.getLatest(page);
      if (response.statusCode == 200) {
        _data += jsonDecode(response.data).map<RankingComic>((item)=>RankingComic(
            cover: 'https://images.dmzj.com/' + item['cover'],
            title: item['name'],
            types: item['types'],
            authors: item['authors'],
            timestamp: item['last_updatetime'],
            headers: {'referer': 'https://m.dmzj.com'},
            comicId: item['comic_id'])).toList();
      }
      notifyListeners();
      logger.i(
          'class: ComicLatestUpdateModel,action: getLatestList, page: $page');
    } catch (e,s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'getLatestListFailed');
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
