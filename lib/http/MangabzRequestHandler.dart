import 'package:dio/dio.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';

class MangabzRequestHandler extends CookiesRequestHandler {
  MangabzRequestHandler() : super('mangabz', 'http://mangabz.com');

  Future<Map<String, dynamic>> getOptions(String url) async {
    try {
      var response = await dio.get('/$url');
      if (response.statusCode == 200) {
        var cid = RegExp('(?<=var MANGABZ_CID=)[^;]*;')
            .stringMatch(response.data.toString());
        cid = cid.substring(0, cid.length - 1);
        var mid = RegExp('(?<=var MANGABZ_MID=)[^;]*;')
            .stringMatch(response.data.toString());
        mid = mid.substring(0, mid.length - 1);
        var dt = RegExp('(?<=var MANGABZ_VIEWSIGN_DT=")[^;]*;')
            .stringMatch(response.data.toString());
        dt = dt.substring(0, dt.length - 2);
        var sign = RegExp('(?<=var MANGABZ_VIEWSIGN=")[^;]*;')
            .stringMatch(response.data.toString());
        sign = sign.substring(0, sign.length - 2);
        return {'cid': cid, 'mid': mid, 'dt': dt, 'sign': sign};
      }
    } catch (e) {}
    return null;
  }

  Future<Response> getChapterImage(String chapterId, int page) async {
    var param = await getOptions('$chapterId');
    return dio.get('/$chapterId/chapterimage.ashx', queryParameters: {
      'cid': param['cid'],
      '_cid': param['cid'],
      'key': '',
      '_mid': param['mid'],
      '_sign': param['sign'],
      '_dt': param['dt'],
      'page': page
    });
  }

  Future<Response> getChapter(String chapterId) async {
    return dio.get('/$chapterId/',
        options: Options(headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Mobile Safari/537.36'
        }));
  }

  Future<Response> search(String keyword, {int page: 0}) {
    return dio.get('/search?title=$keyword&page=${page + 1}',
        options: Options(headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36'
        }));
  }

  Future<Response> getComic(String comicId) async {
    return dio.get('/$comicId', options: await setHeader());
  }

  Future<Response> login(String username, String password) {
    var data =
        FormData.fromMap({'txt_username': username, "txt_password": password});
    return dio.post('/login', data: data);
  }

  Future<Response> home({Map headers}) async {
    return dio.get('/', options: Options(headers: headers));
  }

  Future<Response> getSubscribe() async {
    Options options = await setHeader(headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36'
    });
    return dio.get('/bookmarker', options: options);
  }

  Future<Response> addSubscribe(String comicId, String userId) async {
    var data = FormData.fromMap({
      'cid': 0,
      'mid': comicId.replaceAll('bz', ''),
      'page': 0,
      'uid': userId,
      'language': 1
    });
    return dio.post(
        '/$comicId/bookmarker.ashx?d=${DateTime.now().millisecondsSinceEpoch}',
        data: data,
        options: await setHeader());
  }
}
