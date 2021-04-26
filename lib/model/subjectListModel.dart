import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class SubjectListModel extends BaseModel {
  final BaseSourceModel model;
  int page = 0;
  List<SubjectItem> _data = [];
  dynamic error;

  SubjectListModel(this.model);

  Future<void> getSubjectList(int page) async {
    try {
      _data += await this.model.getSubjectList(page);
      error = null;
      notifyListeners();
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'comicDetailLoadingFail');
      error = e;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _data.clear();
    page = 0;
    await getSubjectList(page);
    notifyListeners();
  }

  Future<void> next() async {
    page++;
    await getSubjectList(page);
    notifyListeners();
  }

  List<SubjectItem> get data => _data;

  int get length => _data.length;
}

class SubjectItem {
  final String cover;
  final String title;
  final String subtitle;
  final String subjectId;

  SubjectItem({this.cover, this.title, this.subtitle, this.subjectId});
}
