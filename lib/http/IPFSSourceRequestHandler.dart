import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dio/dio.dart';

class IPFSSourceRequestHandler extends SingleDomainRequestHandler {
  IPFSSourceRequestHandler(String baseUrl) : super(baseUrl);

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

  Future<Response> search(String keyword) {
    return dio.get('/comic/search/$keyword');
  }

  Future<Response> getServerState() {
    return dio.get('/server/state');
  }
}
