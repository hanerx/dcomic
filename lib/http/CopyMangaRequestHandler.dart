import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dio/dio.dart';

class CopyMangaRequestHandler extends SingleDomainRequestHandler {
  CopyMangaRequestHandler() : super('https://api.copymanga.com/');

  Future<Response> getComicDetail(String comicId) {
    return dio.get('/api/v3/comic2/$comicId?platform=1');
  }

  Future<Response> getChapters(String comicId, String groupName,
      {int limit: 100, int page: 0}) {
    return dio.get(
        '/api/v3/comic/$comicId/group/$groupName/chapters?limit=$limit&offset=$page');
  }

  Future<Response> getComic(String comicId, String chapterId) {
    return dio.get(
        '/api/v3/comic/$comicId/chapter/$chapterId?platform=2&_update=true',
        options: Options(headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36'
        }));
  }

  Future<Response> search(String keyword,{int page:0}){
    return dio.get('/api/v3/search/comic?platform=1&q=$keyword&limit=20&offset=$page&q_type=&_update=true');
  }
}
