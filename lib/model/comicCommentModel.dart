import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ComicCommentModel extends BaseModel {
  int page = 0;
  List _data = [];
  Map comments = {};

  final String comicId;

  ComicCommentModel(this.comicId);

  Future<void> getComment(String comicId, int page) async {
    try {
      var response = await UniversalRequestModel.dmzjCommentRequestHandler
          .getComments(comicId, page, type: 4);
      if (response.statusCode == 200 || response.statusCode == 304) {
        var idList = response.data['commentIds'];
        comments.addAll(response.data['comments']);
        for (String item in idList) {
          var commentList = item.split(',');
          var firstComment = comments[commentList.first];
          _data.add({
            'avatar': firstComment['avatar_url'],
            'nickname': firstComment['nickname'],
            'content': firstComment['content'],
            'timestamp': int.tryParse(firstComment['create_time'].toString()),
            'like': firstComment['like_amount'],
            'upload_image':firstComment['upload_image'],
            'reply': commentList.sublist(1).map<Map>((e) {
              if (comments[e] == null) {
                return {
                  'avatar': 'https://avatar.dmzj.com/default.png',
                  'nickname': '异次元',
                  'content': '被异次元吞噬的评论'
                };
              }
              return {
                'avatar': comments[e]['avatar_url'],
                'nickname': comments[e]['nickname'],
                'content': comments[e]['content']
              };
            }).toList()
          });
        }
        notifyListeners();
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'getComicCommentFailed: $comicId');
    }
  }

  Future<void> refresh() async {
    _data.clear();
    page = 0;
    await getComment(comicId, page);
    notifyListeners();
  }

  Future<void> next() async {
    page++;
    await getComment(comicId, page);
    notifyListeners();
  }

  List get data => _data;

  int get length => _data.length;
}
