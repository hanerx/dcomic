import 'package:dcomic/database/cookieDatabaseProvider.dart';
import 'package:dcomic/http/CopyMangaRequestHandler.dart';
import 'package:dcomic/http/GithubRequestHandler.dart';
import 'package:dcomic/utils/HttpProxyAdapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dcomic/http/DMZJRequestHandler.dart';
import 'package:dcomic/http/KuKuRequestHandler.dart';
import 'package:dcomic/http/ManHuaGuiRequestHandler.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:path_provider/path_provider.dart';

import 'MangabzRequestHandler.dart';

class CacheDatabase {
  static DbCacheStore _store;

  static Future<DbCacheStore> get store async {
    if (_store == null) {
      var value = await getExternalStorageDirectory();
      _store = DbCacheStore(databasePath: value.path + '/cache/dio');
    }
    return _store;
  }
}

class UniversalRequestModel {
  static MangabzRequestHandler mangabzRequestHandler = MangabzRequestHandler();

  static ManHuaGuiRequestHandler manHuaGuiRequestHandler =
      ManHuaGuiRequestHandler();

  static KuKuRequestHandler kuKuRequestHandler = KuKuRequestHandler();

  static SoKuKuRequestHandler soKuKuRequestHandler = SoKuKuRequestHandler();

  static KKKKRequestHandler kkkkRequestHandler1 =
      KKKKRequestHandler('http://comic.kkkkdm.com/');

  static KKKKRequestHandler kkkkRequestHandler2 =
      KKKKRequestHandler('http://comic2.kkkkdm.com/');

  static KKKKRequestHandler kkkkRequestHandler3 =
      KKKKRequestHandler('http://comic3.kkkkdm.com/');

  static DMZJRequestHandler dmzjRequestHandler = DMZJRequestHandler();

  static DMZJIRequestHandler dmzjiRequestHandler = DMZJIRequestHandler();

  static DMZJInterfaceRequestHandler dmzjInterfaceRequestHandler =
      DMZJInterfaceRequestHandler();

  static DMZJAPIRequestHandler dmzjapiRequestHandler = DMZJAPIRequestHandler();

  static DMZJImageRequestHandler dmzjImageRequestHandler =
      DMZJImageRequestHandler();
  static DMZJMobileRequestHandler dmzjMobileRequestHandler =
      DMZJMobileRequestHandler();

  static DMZJSACGRequestHandler dmzjsacgRequestHandler =
      DMZJSACGRequestHandler();

  static DMZJCommentRequestHandler dmzjCommentRequestHandler =
      DMZJCommentRequestHandler();

  static DMZJV4RequestHandler dmzjv4requestHandler = DMZJV4RequestHandler();

  static DMZJJuriRequestHandler dmzjJuriRequestHandler =DMZJJuriRequestHandler();

  static DarkSideRequestHandler darkSideRequestHandler =DarkSideRequestHandler();

  static GithubRequestHandler githubRequestHandler = GithubRequestHandler();

  static CopyMangaRequestHandler copyMangaRequestHandler =
      CopyMangaRequestHandler();
}

abstract class RequestHandler {
  Dio dio;

  Future<bool> clearCache();

  Future<bool> clearExpired();

  void setProxy(String ip, int port);

  String gbkDecoder(List<int> responseBytes, RequestOptions options,
      ResponseBody responseBody) {
    return gbk.decode(responseBytes);
  }

  List<int> gbkEncoder(String requestString, RequestOptions options) {
    return gbk.encode(requestString);
  }

  Future<int> ping({String path: '/'}) async {
    DateTime now = DateTime.now();
    try {
      await dio.get(path);
      return DateTime.now().millisecondsSinceEpoch - now.millisecondsSinceEpoch;
    } catch (e) {}
    return -1;
  }
}

class PerformanceInterceptor extends DioCacheInterceptor {
  HttpMetric metric;


  PerformanceInterceptor({@required CacheOptions options}):super(options: options);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: implement onRequest
    var method = HttpMethod.Get;
    switch (options.method.toUpperCase()) {
      case "GET":
        method = HttpMethod.Get;
        break;
      case "POST":
        method = HttpMethod.Post;
        break;
      case "PUT":
        method = HttpMethod.Put;
        break;
      case "DELETE":
        method = HttpMethod.Delete;
        break;
    }
    metric = FirebasePerformance.instance
        .newHttpMetric(options.uri.toString(), method);
    metric.start();
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // TODO: implement onResponse
    super.onResponse(response, handler);
    metric
      ..responseContentType = response.headers.value('Content-Length')
      ..responseContentType = response.headers.value('Content-Type')
      ..httpResponseCode = response.statusCode;
    metric.stop();
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // TODO: implement onError
    super.onError(err, handler);
    metric
      ..responseContentType = err.response.headers.value('Content-Length')
      ..responseContentType = err.response.headers.value('Content-Type')
      ..httpResponseCode = err.response.statusCode;
    metric.stop();
  }
}

abstract class SingleDomainRequestHandler extends RequestHandler {
  Dio dio;
  CacheOptions options;
  final String baseUrl;

  SingleDomainRequestHandler(this.baseUrl,
      {CachePolicy policy: CachePolicy.request}) {
    dio = Dio()..options.baseUrl = baseUrl;
    CacheDatabase.store.then((value) {
      options = CacheOptions(
        store: value,
        // Required.
        policy: policy,
        // Default. Checks cache freshness, requests otherwise and caches response.
        hitCacheOnErrorExcept: [401, 403],
        // Optional. Returns a cached response on error if available but for statuses 401 & 403.
        priority: CachePriority.normal,
        // Optional. Default. Allows 3 cache sets and ease cleanup.
        maxStale: const Duration(days: 7),
        // Very optional. Overrides any HTTP directive to delete entry past this duration.
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      );
      dio.interceptors.add(PerformanceInterceptor(options: options));
    });
  }

  Future<bool> clearCache() async {
    await (await CacheDatabase.store).clean();
    return true;
  }

  Future<bool> clearExpired() async {
    await (await CacheDatabase.store).clean(staleOnly: true);
    return true;
  }

  void setProxy(String ip, int port) {
    dio = Dio()
      ..options.baseUrl = baseUrl
      ..httpClientAdapter = HttpProxyAdapter(ipAddr: ip, port: port);
    CacheDatabase.store.then((value) {
      options = CacheOptions(
        store: value,
        // Required.
        policy: CachePolicy.request,
        // Default. Checks cache freshness, requests otherwise and caches response.
        hitCacheOnErrorExcept: [401, 403],
        // Optional. Returns a cached response on error if available but for statuses 401 & 403.
        priority: CachePriority.normal,
        // Optional. Default. Allows 3 cache sets and ease cleanup.
        maxStale: const Duration(
            days:
                7), // Very optional. Overrides any HTTP directive to delete entry past this duration.
      );
      dio.interceptors.add(DioCacheInterceptor(options: options));
    });
  }
}

class CookiesRequestHandler extends SingleDomainRequestHandler {
  final String name;

  CookiesRequestHandler(this.name, String baseUrl) : super(baseUrl);

  Future<Options> setHeader({Map<String, dynamic> headers}) async {
    var cookies = await CookieDatabaseProvider(name).getAll();
    var cookie = '';
    for (var item in cookies.first) {
      cookie += item['key'] + '=' + item['value'].split(';')[0] + ';';
    }
    if (headers == null) {
      headers = {};
    }
    headers['Cookie'] = cookie;
    Options options = new Options(headers: headers);
    return options;
  }
}
