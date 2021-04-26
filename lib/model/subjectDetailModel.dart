import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class SubjectDetailModel extends BaseModel {
  final String subjectId;
  Map<String, String> _headers = {"referer": "https://m.dmzj.com"};
  String _cover = 'http://manhua.dmzj.com/css/img/mh_logo_dmzj.png?t=20131122';
  String _title = "";
  String _description = "";
  List _data = [];
  String error;

  SubjectDetailModel(this.subjectId);

  Future<void> getSubjectDetail() async {
    try {
      var response = await UniversalRequestModel.dmzjRequestHandler
          .getSubjectDetail(subjectId);
      if (response.statusCode == 200) {
        _cover = response.data['mobile_header_pic'];
        _title = response.data['title'];
        _description = response.data['description'];
        _data = response.data['comics'];
        notifyListeners();
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'subjectDetailLoadingFail: $subjectId');
      error = '未知错误：$e';
      notifyListeners();
    }
  }

  String get cover => _cover;

  Map<String, String> get headers => _headers;

  String get title => _title;

  String get description => _description;

  List get data => _data;
}
