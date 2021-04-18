import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ComicSearchModel extends BaseModel {
  List<SearchResult> _list = [];
  int page = 0;
  final BaseSourceModel model;
  final String keyword;

  ComicSearchModel(this.model, this.keyword);

  Future<void> search(String keyword) async {
    if (keyword != null && keyword != '') {
      try {
        _list += await model.search(keyword, page: page);
        notifyListeners();
      } catch (e, s) {
        FirebaseCrashlytics.instance
            .recordError(e, s, reason: 'searchFailed: ${model.type.name}');
        logger.e('action: searchFailed, keyword: $keyword');
      }
    }
  }

  Future<void> refresh() async {
    _list.clear();
    page = 0;
    await search(keyword);
    notifyListeners();
  }

  Future<void> next() async {
    page++;
    await search(keyword);
    notifyListeners();
  }

  List<SearchResult> get list => _list;

  int get length => _list.length;
}
