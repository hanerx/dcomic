import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class HomepageModel extends BaseModel {
  final BaseSourceModel model;
  List<HomePageCardModel> _data = [];
  dynamic error;

  HomepageModel(this.model);

  Future<void> init() async {
    try {
      _data = await model.homePageHandler.getHomePage();
      error = null;
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'getHomepageFailed');
      error = '未知错误：$e';
    }
    notifyListeners();
  }

  List<HomePageCardModel> get data => _data;

  int get length => _data.length;
}
