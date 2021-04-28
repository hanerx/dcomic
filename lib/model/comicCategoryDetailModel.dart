import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comicRankingListModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ComicCategoryDetailModel extends BaseModel {
  final String categoryId;
  final String title;
  final BaseSourceModel model;
  // int filterDate = 0;
  int filterType = 0;
  // int filterTag = 0;
  int page = 0;
  List<RankingComic> _data = [];
  // Map dateTypeList = <int, String>{};
  List typeTypeList = <String>['按人气', '按更新'];
  // Map tagTypeList = <int, String>{};

  ComicCategoryDetailModel(this.categoryId, this.title, this.model);

  // init() async {
  //   // await getCategoryFilter();
  // }

  // Future<void> getCategoryFilter() async {
  //   CustomHttp http = CustomHttp();
  //   var response = await http.getCategoryFilter();
  //   if (response.statusCode == 200) {
  //     response.data[2]['items']
  //         .forEach((item) => dateTypeList[item['tag_id']] = item['tag_name']);
  //     response.data[3]['items']
  //         .forEach((item) => tagTypeList[item['tag_id']] = item['tag_name']);
  //   }
  //   notifyListeners();
  // }

  getCategoryDetail() async {
    // var response = await UniversalRequestModel.dmzjRequestHandler.getCategoryDetail(
    //     categoryId, filterDate, filterTag, filterType, page);
    // if (response.statusCode == 200) {
    //   _data += response.data;
    // }
    try {
      _data += await model.homePageHandler
          .getCategoryDetail(categoryId, page: page, popular: filterType == 0);
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'comicGetCategoryFailed');
    }
    notifyListeners();
  }

  refresh() async {
    page = 0;
    _data.clear();
    await getCategoryDetail();
    notifyListeners();
  }

  next() async {
    page++;
    await getCategoryDetail();
    notifyListeners();
  }

  int get length => _data.length;

  List<RankingComic> get data => _data;
}
