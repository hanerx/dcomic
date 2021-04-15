import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';

class LocalHistoryModel extends BaseModel {
  final SourceProvider provider;

  LocalHistoryModel(this.provider);

  List<HistoryComic> _list = [];

  Future<void> getHistories() async {
    for (var item in provider.activeSources) {
      _list += await item.getLocalHistoryComics();
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    _list.clear();
    await getHistories();
    notifyListeners();
  }

  List<HistoryComic> get list => _list;
}
