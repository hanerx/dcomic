import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/baseModel.dart';

class ComicLatestUpdateModel extends BaseModel {
  int filterTag = 100;
  int page = 0;
  List _data = [];
  Map tagTypeList = <int, String>{100: '全部漫画', 1: '原创漫画', 0: '译制漫画'};

  getLatestList() async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getLatestList(filterTag, page);
      if (response.statusCode == 200) {
        _data += response.data;
      }
      notifyListeners();
      logger.i(
          'class: ComicLatestUpdateModel,action: getLatestList, page: $page');
    } catch (e) {
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
