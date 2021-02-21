import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dio_proxy/dio_proxy.dart';
import 'package:flutterdmzj/http/ManHuaGuiRequestHandler.dart';

import 'MangabzRequestHandler.dart';

class UniversalRequestModel {
  MangabzRequestHandler mangabzRequestHandler = MangabzRequestHandler();

  ManHuaGuiRequestHandler manHuaGuiRequestHandler = ManHuaGuiRequestHandler();
}

abstract class RequestHandler {
  Dio dio;
  DioCacheManager cacheManager;
  final String baseUrl;

  RequestHandler(this.baseUrl) {
    dio = Dio()..options.baseUrl = baseUrl;
    cacheManager = DioCacheManager(CacheConfig(baseUrl: baseUrl));
    dio.interceptors.add(cacheManager.interceptor);
  }

  Future<bool> clearCache() {
    return cacheManager.clearAll();
  }

  Future<bool> clearExpired() {
    return cacheManager.clearExpired();
  }

  void setProxy(String ip, int port) {
    dio = Dio()
      ..options.baseUrl = baseUrl
      ..httpClientAdapter = HttpProxyAdapter(ipAddr: ip, port: port);
    cacheManager = DioCacheManager(CacheConfig(baseUrl: baseUrl));
    dio.interceptors.add(cacheManager.interceptor);
  }
}
