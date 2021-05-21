import 'dart:convert';
import 'dart:io';

import 'package:dcomic/database/cookieDatabaseProvider.dart';
import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/protobuf/comic.pb.dart';
import 'package:dcomic/protobuf/novel_chapter.pb.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:dio/dio.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

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

  Future<Response> getSubjectList(String uid, {int page: 0}) {
    return dio.get('/subject_with_level/0/$page.json?uid=$uid');
  }

  Future<Response> getCategory({int type: 0}) {
    return dio.get('/$type/category.json');
  }

  Future<Response> getMainPageRecommend() {
    return dio.get('/recommend.json');
  }

  Future<Response> getUpdateBatch(String uid) {
    return dio.get('/recommend/batchUpdate?uid=$uid&category_id=49');
  }

  Future<Response> getSubjectDetail(String subjectId) {
    return dio.get('/subject/$subjectId.json');
  }

  Future<Response> getCategoryDetail(
      int categoryId, int date, int tag, int type, int page) {
    return dio.get('/classify/$categoryId-$date-$tag/$type/$page.json');
  }

  Future<Response> getAuthorDetail(int authorId) {
    return dio.get('/UCenter/author/$authorId.json');
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

  Future<Response> getCategoryDetail(String categoryId,
      {int page: 0, bool popular: true}) {
    return dio.get('/tags/$categoryId/${popular ? 0 : 1}/$page.json');
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

class DMZJV4RequestHandler extends SingleDomainRequestHandler {
  DMZJV4RequestHandler() : super('https://nnv4api.dmzj1.com');

  Future<Map> getParam({bool login: false}) async {
    var data = {
      "channel": Platform.operatingSystem,
      "version": "3.0.0",
      "timestamp":
          (DateTime.now().millisecondsSinceEpoch / 1000).toStringAsFixed(0),
    };
    if (login &&
        await SourceDatabaseProvider.getSourceOption<bool>('dmzj', 'login')) {
      data['uid'] = await SourceDatabaseProvider.getSourceOption('dmzj', 'uid');
    }
    return data;
  }

  Future<NovelDetailInfoResponse> getNovelDetail(String novelId) async {
    var response = await dio.get('/novel/detail/$novelId');
    if (response.statusCode == 200) {
      return NovelDetailResponse.fromBuffer(ToolMethods.decrypt(response.data))
          .data;
    }
    return null;
  }

  Future<ComicDetailInfoResponse> getComicDetail(String comicId) async {
    var response = await dio.get('/comic/detail/$comicId',
        queryParameters: await getParam(login: true));
    if (response.statusCode == 200) {
      var data =
          ComicDetailResponse.fromBuffer(ToolMethods.decrypt(response.data));
      if (data.errno != 0) {
        throw data.errmsg;
      }
      return data.data;
    }
    return null;
  }
  
  Future<ComicChapterDetailInfoResponse> getComic(String comicId,String chapterId)async{
    var response=await dio.get('/comic/chapter/$comicId/$chapterId',queryParameters: await getParam(login: true));
    if (response.statusCode == 200) {
      var data =
      ComicChapterDetailResponse.fromBuffer(ToolMethods.decrypt(response.data));
      if (data.errno != 0) {
        throw data.errmsg;
      }
      return data.data;
    }
    return null;
  }
}
