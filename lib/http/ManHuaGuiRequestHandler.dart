import 'package:dio/dio.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';

class ManHuaGuiRequestHandler extends CookiesRequestHandler {
  ManHuaGuiRequestHandler() : super('manhuagui', 'https://m.manhuagui.com');

  Future<Response> search(String keyword) {
    return dio.get('/s/${Uri.encodeComponent(keyword)}.html');
  }

  Future<Response> getComic(String comicId) {
    return dio.get('/comic/$comicId/');
  }

  Future<Response> getChapter(String comicId, String chapterId) {
    return dio.get('/comic/$comicId/$chapterId.html');
  }

  Future<Response> getComicComments(String comicId, int page) {
    return dio.get(
        '/tools/submit_ajax.ashx?action=comment_list&book_id=$comicId&page_index=${page + 1}');
  }

  Future<Response> addSubscribe(String comicId) async {
    var data = FormData.fromMap({'book_id': comicId});
    return dio.post('/tools/submit_ajax.ashx?action=user_book_shelf_add',
        data: data, options: await setHeader());
  }

  Future<Response> cancelSubscribe(String comicId) async {
    var data = FormData.fromMap({'book_id': comicId});
    return dio.post('/tools/submit_ajax.ashx?action=user_book_shelf_delete',
        data: data, options: await setHeader());
  }

  Future<Response> getIfSubscribe(String comicId) async {
    return dio.get(
        '/tools/submit_ajax.ashx?action=user_book_shelf_check&book_id=$comicId',
        options: await setHeader());
  }

  Future<Response> logout() async {
    return dio.get('/user/center/exit', options: await setHeader());
  }

  Future<Response> login(String username, String password) {
    var data = FormData.fromMap({
      'txtUserName': username,
      'txtPassword': password,
      'chkRemember': 'checked'
    });
    return dio.post('/tools/submit_ajax.ashx?action=user_login', data: data);
  }

  Future<Response> getLoginInfo() async {
    return dio.get('/tools/submit_ajax.ashx?action=user_check_login',
        options: await setHeader());
  }

  Future<Response> getSubscribe() async {
    return dio.get('/user/book/shelf',
        options: await setHeader());
  }
}
