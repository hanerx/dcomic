import 'dart:convert';

import 'package:dcomic/database/cookieDatabaseProvider.dart';
import 'package:dio/dio.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';

class DMZJRequestHandler extends SingleDomainRequestHandler {
  DMZJRequestHandler() : super('https://v3api.dmzj1.com');

  Future<Response> getUserInfo(String uid) async {
    return dio.get('/UCenter/comics/$uid.json');
  }

  Future<Response> getIfSubscribe(String comicId, String uid,
      {int type: 0}) async {
    return dio.get('$baseUrl/subscribe/$type/$uid/$comicId');
  }

  Future<Response> cancelSubscribe(String comicId, String uid,
      {int type: 0}) async {
    return dio.get(
        '/subscribe/cancel?obj_ids=$comicId&uid=$uid&type=${type == 0 ? 'mh' : 'xs'}');
  }

  Future<Response> addSubscribe(String comicId, String uid,
      {int type: 0}) async {
    FormData formData = FormData.fromMap(
        {"obj_ids": comicId, "uid": uid, 'type': type == 0 ? 'mh' : 'xs'});
    return dio.post('/subscribe/add', data: formData);
  }

  Future<Response> getSubscribe(int uid, int page, {int type: 0}) {
    return dio.get(
        '/UCenter/subscribe?uid=$uid&sub_type=1&letter=all&page=$page&type=$type');
  }

  Future<Response> getViewpoint(String comicId, String chapterId) {
    return dio.get('/viewPoint/0/$comicId/$chapterId.json');
  }

  Future<Response> getComicDetail(String comicId) {
    return dio.get('/comic/comic_$comicId.json');
  }

  Future<Response> getComic(String comicId, String chapterId) {
    return dio.get('/chapter/$comicId/$chapterId.json');
  }

  Future<Response> search(String keyword, int page, {int type: 0}) {
    return dio
        .get('/search/show/$type/${Uri.encodeComponent(keyword)}/$page.json');
  }
}

class DMZJIRequestHandler extends SingleDomainRequestHandler {
  DMZJIRequestHandler() : super('https://i.dmzj1.com');

  Future<Response> login(String username, String password) async {
    return dio.get(
        '/api/login?callback=&nickname=$username&password=$password&type=1');
  }
}

class DMZJMobileRequestHandler extends SingleDomainRequestHandler {
  DMZJMobileRequestHandler() : super('https://m.dmzj.com');

  Future<Response> getComicWeb(String comicId, String chapterId) {
    return dio.get('/chapinfo/$comicId/$chapterId.html');
  }

  Future<Response> getComicDetailWeb(String comicId) {
    return dio.get('/info/$comicId.html');
  }

  Future<Response> getRankList(int date, int type, int tag, int page) {
    return dio.get("/rank/$type-$tag-$date-$page.json");
  }

  Future<Response> getLatest(int page) {
    return dio.get('/latest/$page.json');
  }
}

class DMZJInterfaceRequestHandler extends CookiesRequestHandler {
  DMZJInterfaceRequestHandler() : super('dmzj', 'https://interface.dmzj.com');

  Future<Response> updateUnread(String comicId) async {
    return dio.get('/api/subscribe/upread?sub_id=$comicId',
        options: await setHeader());
  }

  Future<Response> getHistory(String uid, int page) {
    return dio.get('/api/getReInfo/comic/$uid/$page');
  }

  Future<Response<T>> addHistory<T>(int comicId, String uid, int chapterId,
      {int page: 1}) async {
    Map map = {
      comicId.toString(): chapterId.toString(),
      "comicId": comicId.toString(),
      "chapterId": chapterId.toString(),
      "page": page,
      "time": DateTime.now().millisecondsSinceEpoch / 1000
    };
    var json = Uri.encodeComponent(jsonEncode(map));
    return dio.get(
        "/api/record/getRe?st=comic&uid=$uid&callback=record_jsonpCallback&json=[$json]&type=3");
  }
}

class DMZJAPIRequestHandler extends SingleDomainRequestHandler {
  DMZJAPIRequestHandler() : super('https://api.dmzj1.com');

  Future<Response> getComicDetailWithBackupApi(String comicId) {
    return dio.get('/dynamic/comicinfo/$comicId.json');
  }
}

class DMZJImageRequestHandler extends SingleDomainRequestHandler {
  DMZJImageRequestHandler() : super('http://imgsmall.dmzj1.com');

  Future<Response> getImage(
      String firstLetter, String comicId, String chapterId, int page) {
    return dio.get('/$firstLetter/$comicId/$chapterId/$page.jpg',
        options: Options(
            headers: {'referer': 'http://images.dmzj.com'},
            responseType: ResponseType.bytes));
  }
}

class DMZJSACGRequestHandler extends SingleDomainRequestHandler {
  DMZJSACGRequestHandler() : super('http://s.acg.dmzj.com');

  Future<Response> deepSearch(String keyword) {
    return dio.get('/comicsum/search.php?s=$keyword&callback=');
  }
}

class DMZJCommentRequestHandler extends SingleDomainRequestHandler {
  DMZJCommentRequestHandler() : super('https://v3comment.dmzj1.com');

  Future<Response> getComments(String comicId, int page,
      {int limit: 30, int type: 4}) {
    return dio
        .get('/v1/$type/latest/$comicId?limit=$limit&page_index=${page + 1}');
  }
}
