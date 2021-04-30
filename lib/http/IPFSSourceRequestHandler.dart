import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dio/dio.dart';

class IPFSSourceRequestHandler extends SingleDomainRequestHandler {
  final SourceDetail sourceDetail;

  IPFSSourceRequestHandler(String baseUrl, this.sourceDetail) : super(baseUrl);

  Future<Map<String, String>> setHeader([Map<String, String> headers]) async {
    if (await SourceDatabaseProvider.getSourceOption<bool>(
        sourceDetail.name, "login")) {
      if (headers == null) {
        headers = {};
      }
      headers['token'] = await SourceDatabaseProvider.getSourceOption(
          sourceDetail.name, "token");
    }
    return headers;
  }

  Future<Response> getComicDetail(String comicId) {
    return dio.get('/comic/$comicId');
  }

  Future<Response> getGroup(String comicId, String groupId) {
    return dio.get('/comic/$comicId/$groupId');
  }

  Future<Response> getChapter(
      String comicId, String groupId, String chapterId) {
    return dio.get('/comic/$comicId/$groupId/$chapterId');
  }

  Future<Response> login(String username, String password) {
    var data = FormData.fromMap({"username": username, "password": password});
    return dio.post('/user/login', data: data);
  }

  Future<Response> logout() async {
    return dio.post('/user/logout',
        options: Options(headers: await setHeader()));
  }

  Future<Response> search(String keyword) {
    return dio.get('/comic/search/$keyword');
  }

  Future<Response> getServerState() {
    return dio.get('/server/state');
  }

  Future<Response> getUserState() async {
    return dio.get('/user/my', options: Options(headers: await setHeader()));
  }
}
