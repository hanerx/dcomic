import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutterdmzj/database/database.dart';

class CustomHttp {
  Dio dio;
  Dio unCachedDio;
  String baseUrl = 'https://v3api.dmzj.com';
  final String queryOptions = 'channel=Android&version=2.7.017';
  DioCacheManager _cacheManager;

  CustomHttp() {
    dio = Dio();
    _cacheManager = DioCacheManager(CacheConfig(baseUrl: baseUrl));
    dio.interceptors.add(_cacheManager.interceptor);
    dio.interceptors.add(DioCacheManager(CacheConfig(baseUrl:'https://dark-dmzj.hloli.net')).interceptor);
    unCachedDio = Dio();
  }

  Future<Response<T>> getMainPageRecommend<T>() async {
    return dio.get(baseUrl + "/recommend.json?$queryOptions",
        options: buildCacheOptions(Duration(days: 1)));
  }

  Future<Response<T>> getCategory<T>(int page) async {
    return dio.get(baseUrl + '/$page/category.json?$queryOptions',
        options: buildCacheOptions(Duration(days: 3)));
  }

  Future<Response<T>> getFilterTags<T>() async {
    return dio.get(baseUrl + '/rank/type_filter.json?$queryOptions',
        options: buildCacheOptions(Duration(days: 7)));
  }

  Future<Response<T>> getRankList<T>(
      int date, int type, int tag, int page) async {
    return dio.get(baseUrl + '/rank/$tag/$date/$type/$page.json?$queryOptions',
        options: buildCacheOptions(Duration(hours: 2)));
  }

  Future<Response<T>> getComicDetail<T>(String comicId) async {
    return dio.get(baseUrl + '/comic/comic_$comicId.json?$queryOptions',
        options: buildCacheOptions(Duration(hours: 1)));
  }

  Future<Response<T>> getComic<T>(String comicId, String chapterId) async {
    return dio.get(baseUrl + '/chapter/$comicId/$chapterId.json?$queryOptions',
        options: buildCacheOptions(Duration(hours: 8)));
  }

  Future<Response<T>> getViewPoint<T>(String comicId, String chapterId) async {
    return dio.get(
        baseUrl + '/viewPoint/0/$comicId/$chapterId.json?$queryOptions',
        options: buildCacheOptions(Duration(hours: 8)));
  }

  Future<Response<T>> getSubjectDetail<T>(String subjectId) async {
    return dio.get(baseUrl + '/subject/$subjectId.json?$queryOptions');
  }

  Future<Response<T>> getCategoryFilter<T>() async {
    return dio.get(baseUrl + '/classify/filter.json?$queryOptions');
  }

  Future<Response<T>> getCategoryDetail<T>(
      int categoryId, int date, int tag, int type, int page) async {
    return dio.get(
        '$baseUrl/classify/$categoryId-$date-$tag/$type/$page.json?$queryOptions',
        options: buildCacheOptions(Duration(hours: 1)));
  }

  Future<Response<T>> getSubscribe<T>(int uid, int page) {
    return dio.get(
        '$baseUrl/UCenter/subscribe?uid=$uid&sub_type=1&letter=all&page=0&type=0?uid=$uid&sub_type=1&letter=all&page=$page&type=0&$queryOptions',
        options: buildCacheOptions(Duration(minutes: 5),
            subKey: 'uid=$uid&page=$page'));
  }

  Future<Response<T>> login<T>(String username, String password) {
    return unCachedDio.get(
        'https://i.dmzj.com/api/login?callback=&nickname=$username&password=$password&type=1');
  }

  Future<Response<T>> getUserInfo<T>(String uid) {
    return dio.get("$baseUrl/UCenter/comics/$uid.json?$queryOptions",
        options: buildCacheOptions(Duration(days: 7)));
  }

  Future<Response<T>> getMySubscribe<T>() async {
    DataBase dataBase = DataBase();
    var cookies = await dataBase.getCookies();
    var cookie = '';
    for (var item in cookies.first) {
      cookie += item['key'] + '=' + item['value'].split(';')[0] + ';';
    }
    Map<String, dynamic> headers = new Map();
    headers['Cookie'] = cookie;
    Options options = new Options(headers: headers);

    return unCachedDio.get("https://m.dmzj.com/mysubscribe", options: options);
  }

  Future<Response<T>> getIfSubscribe<T>(String comicId, String uid) async {
    return unCachedDio.get('$baseUrl/subscribe/0/$uid/$comicId?$queryOptions');
  }

  Future<Response<T>> cancelSubscribe<T>(String comicId, String uid) async {
    _cacheManager.delete("$baseUrl/UCenter/subscribe");
    return unCachedDio.get(
        '$baseUrl/subscribe/cancel?obj_ids=$comicId&uid=$uid&type=mh?obj_ids=$comicId&uid=$uid&type=mh&channel=Android&version=2.7.017');
  }

  Future<Response<T>> addSubscribe<T>(String comicId, String uid) async {
    _cacheManager.delete("$baseUrl/UCenter/subscribe");
    FormData formData =
        FormData.fromMap({"obj_ids": comicId, "uid": uid, 'type': 'mh'});
    return unCachedDio.post('$baseUrl/subscribe/add', data: formData);
  }

  Future<Response<T>> addReadHistory<T>(String comicId, String uid) async {
    return unCachedDio.get(
        '$baseUrl/subscribe/read?obj_ids=$comicId&uid=$uid&type=mh?obj_ids=$comicId&uid=$uid&type=mh&channel=Android&version=2.7.017');
  }

  Future<Response<T>> addReadHistory0<T>(String comicId, String uid) async {
    return unCachedDio.get('$baseUrl/subscribe/0/$uid/$comicId?$queryOptions');
  }

  Future<Response<T>> getReadHistory<T>(String uid, int page) {
    return dio.get(
        "https://interface.dmzj.com/api/getReInfo/comic/$uid/$page?$queryOptions",
        options: buildCacheOptions(Duration(minutes: 5)));
  }

  Future<Response<T>> getRecommendBatchUpdate<T>(String uid) {
    return dio.get(
        '$baseUrl/recommend/batchUpdate?uid=$uid&category_id=49&$queryOptions');
  }

  Future<Response<T>> search<T>(String keyword, int page) {
    return dio.get(
        '$baseUrl/search/show/0/${Uri.encodeComponent(keyword)}/$page.json?$queryOptions');
  }

  Future<Response<T>> getLatestList<T>(int tagId, int page) {
    return dio.get('$baseUrl/latest/$tagId/$page.json?$queryOptions');
  }

  Future<Response<T>> getDarkInfo<T>() {
    return dio.get('https://dark-dmzj.hloli.net/data.json');
  }

  Future<Response<T>> getComicComment<T>(String comicId, int page, int type) {
    return dio.get(
        '$baseUrl/old/comment/0/$type/$comicId/$page.json?$queryOptions',
        options: buildCacheOptions(Duration(days: 1)));
  }

  Future<Response<T>> checkUpdate<T>() {
    return dio.get(
        'https://api.github.com/repos/hanerx/flutter_dmzj/releases/latest');
  }
}
