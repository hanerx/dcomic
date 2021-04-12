import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';

class MangabzRequestHandler extends SingleDomainRequestHandler {
  MangabzRequestHandler() : super('http://www.mangabz.com');

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
    return dio.get('/$chapterId/chapterimage.ashx',
        options: buildCacheOptions(Duration(days: 1), subKey: 'page=$page',options: Options(headers: {'referer': '$baseUrl'}),),
        queryParameters: {
          'cid': param['cid'],
          '_cid': param['cid'],
          'key': '',
          '_mid': param['mid'],
          '_sign': param['sign'],
          '_dt': param['dt'],
          'page': page
        });
  }

  Future<Response> getChapter(String chapterId)async{
    return dio.get('/$chapterId/',options: Options(headers: {'User-Agent':'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Mobile Safari/537.36'}));
  }

  Future<Response> search(String keyword) {
    return dio.get('/search?title=$keyword');
  }

  Future<Response> getComic(String comicId){
    return dio.get('/$comicId');
  }
}
