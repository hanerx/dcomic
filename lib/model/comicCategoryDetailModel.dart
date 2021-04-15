import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/baseModel.dart';

class ComicCategoryDetailModel extends BaseModel {
  final int categoryId;
  final String title;
  int filterDate = 0;
  int filterType = 0;
  int filterTag = 0;
  int page = 0;
  List _data = [];
  Map dateTypeList = <int, String>{};
  List typeTypeList = <String>['按人气', '按更新'];
  Map tagTypeList = <int, String>{};

  ComicCategoryDetailModel(this.categoryId, this.title) {
    init();
  }

  init() async {
    await getCategoryFilter();
  }

  Future<void> getCategoryFilter() async {
    CustomHttp http = CustomHttp();
    var response = await http.getCategoryFilter();
    if (response.statusCode == 200) {
      response.data[2]['items']
          .forEach((item) => dateTypeList[item['tag_id']] = item['tag_name']);
      response.data[3]['items']
          .forEach((item) => tagTypeList[item['tag_id']] = item['tag_name']);
    }
    notifyListeners();
  }

  getCategoryDetail() async {
    CustomHttp http = CustomHttp();
    var response = await http.getCategoryDetail(
        categoryId, filterDate, filterTag, filterType, page);
    if (response.statusCode == 200) {
      _data += response.data;
    }
    notifyListeners();
  }

  refresh()async{
    page=0;
    _data.clear();
    await getCategoryDetail();
    notifyListeners();
  }

  next()async{
    page++;
    await getCategoryDetail();
    notifyListeners();
  }

  int get length=>_data.length;

  List get data=>_data;
}
