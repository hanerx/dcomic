import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ComicCommentModel extends BaseModel {
  int page = 0;
  List<ComicComment> _data = [];
  Map comments = {};

  String error;

  final ComicDetail detail;

  ComicCommentModel(this.detail);

  Future<void> getComment(int page) async {
    if (detail != null) {
      try {
        _data += await detail.getComments(page);
        notifyListeners();
      } on UnimplementedError {
        error = "该源不支持评论查看";
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(e, s,
            reason:
                'getComicCommentFailed: ${detail != null ? detail.comicId : null}');
        error = "未知错误：$e";
      }
    } else {
      error = '未获得漫画源';
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    _data.clear();
    page = 0;
    await getComment(page);
    notifyListeners();
  }

  Future<void> next() async {
    page++;
    await getComment(page);
    notifyListeners();
  }

  List<ComicComment> get data => _data;

  int get length => _data.length;
}
