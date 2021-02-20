import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'MangabzRequestHandler.dart';

class UniversalRequestModel {
  MangabzRequestHandler get mangabzRequestHandler => MangabzRequestHandler();
}

abstract class RequestHandler {
  Dio dio;
  DioCacheManager cacheManager;
  final String baseUrl;

  RequestHandler(this.baseUrl) {
    dio = Dio();
    cacheManager = DioCacheManager(CacheConfig(baseUrl: baseUrl));
    dio.interceptors.add(cacheManager.interceptor);
  }

  Future<bool> clearCache() {
    return cacheManager.clearAll();
  }

  Future<bool> clearExpired() {
    return cacheManager.clearExpired();
  }
}
