import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/subjectListModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'comic_source/baseSourceModel.dart';

class SubjectDetailModel extends BaseModel {
  final String subjectId;
  final BaseSourceModel model;
  String error;
  SubjectModel detail;

  SubjectDetailModel(this.subjectId, this.model);

  Future<void> getSubjectDetail() async {
    try {
      detail = await model.homePageHandler.getSubject(subjectId);
      error = null;
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'subjectDetailLoadingFail: $subjectId');
      error = '未知错误：$e';
    }
    notifyListeners();
  }

  String get cover => detail == null
      ? 'http://manhua.dmzj.com/css/img/mh_logo_dmzj.png?t=20131122'
      : detail.cover;

  Map<String, String> get headers =>
      detail == null ? {"referer": "https://m.dmzj.com"} : detail.headers;

  String get title => detail == null ? '加载中' : detail.title;

  String get description => detail == null ? '加载中...' : detail.description;

  List<RecommendComic> get data => detail == null ? [] : detail.data;
}

class SubjectModel {
  final String cover;
  final String title;
  final String description;
  final Map<String, String> headers;
  final List<RecommendComic> data;

  SubjectModel(
      {this.cover, this.title, this.description, this.headers, this.data});
}

class RecommendComic {
  final String cover;
  final String title;
  final String comicId;
  final String brief;
  final String reason;

  RecommendComic(
      {this.cover, this.title, this.comicId, this.brief, this.reason});
}
