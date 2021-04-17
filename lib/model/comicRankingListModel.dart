import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ComicRankingListModel extends BaseModel {
  int filterDate = 0;
  int filterType = 0;
  int filterTag = 0;
  int page = 0;
  List _data = [];
  final List dateTypeList = <String>['日排行', '周排行', '月排行', '总排行'];
  final List typeTypeList = <String>['按人气', '按吐槽', '按订阅'];
  Map tagTypeList = <int, String>{0: '全部'};

  ComicRankingListModel(){
    init();
  }

  Future<void> init() async {
    await loadRankingList();
    await loadRankingTag();
  }

  loadRankingList() async {
    try {
      CustomHttp http = CustomHttp();
      var response =
          await http.getRankList(filterDate, filterType, filterTag, page);
      if (response.statusCode == 200) {
        if (response.data.length == 0) {
          return;
        }
        _data += response.data;
      }
      notifyListeners();
      logger.i(
          'class: ComicRankingList, action: loadingRankingList, page: $page');
    } catch (e,s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'loadRankingListFailed');
      logger.e(
          'class: ComicRankingList, action: loadRankingListFailed, exception: $e');
    }
  }

  loadRankingTag() async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getFilterTags();
      if (response.statusCode == 200) {
        response.data
            .forEach((item) => tagTypeList[item['tag_id']] = item['tag_name']);
      }
      notifyListeners();
      logger.i(
          'class: ComicRankingList, action: loadingRankingTag, tags: $tagTypeList');
    } catch (e) {
      logger.e(
          'class: ComicRankingList, action: loadRankingTagFailed, exception: $e');
    }
  }

  Future<void> refresh() async {
    page = 0;
    _data.clear();
    await loadRankingList();
    notifyListeners();
  }

  Future<void> next() async {
    page++;
    await loadRankingList();
    notifyListeners();
  }

  int get length => _data.length;

  List get data => _data;
}
