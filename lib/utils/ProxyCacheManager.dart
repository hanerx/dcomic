
import 'dart:io';

import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import'package:http/io_client.dart';

import 'HttpProxyAdapter.dart';


class ProxyCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'libCachedImageData';

  static ProxyCacheManager _instance;
  factory ProxyCacheManager({String ipAddr,int port}) {
    if(_instance==null){
      _instance=ProxyCacheManager._(ipAddr, port);
    }
    return _instance;

  }

  ProxyCacheManager._(String ipAddr, int port)
      : super(Config(key, fileService: ProxyFileService.proxy(ipAddr:ipAddr, port:port)));
}

class BadCertificateCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'libCachedImageData';

  static final BadCertificateCacheManager _instance=BadCertificateCacheManager._();
  factory BadCertificateCacheManager() {
    return _instance;
  }

  static http.Client getClient(){
    var ioClient = new HttpClient()..badCertificateCallback =  (X509Certificate cert, String host, int port) => true;

    return IOClient(ioClient);
  }

  BadCertificateCacheManager._()
      : super(Config(key, fileService: HttpFileService(httpClient: getClient())));
}

class DioFileService extends FileService{
  Dio _dio;
  CacheOptions options;

  DioFileService() {
    _dio = Dio();
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
        maxStale: const Duration(days: 7),
        // Very optional. Overrides any HTTP directive to delete entry past this duration.
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      );
      _dio.interceptors.add(PerformanceInterceptor(options: options));
    });
    _dio..httpClientAdapter=BadCertificateAdapter();
  }

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String> headers = const {}}) async {
    var response = await _dio.get(url,
        options: Options(headers: headers, responseType: ResponseType.bytes));
    return HttpGetResponse(http.StreamedResponse(
        http.ByteStream.fromBytes(response.data), response.statusCode));
  }
}

class ProxyFileService extends FileService {
  Dio _dio;
  CacheOptions options;

  ProxyFileService.proxy({String ipAddr, int port}) {
    _dio = Dio();
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
        maxStale: const Duration(days: 7),
        // Very optional. Overrides any HTTP directive to delete entry past this duration.
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      );
      _dio.interceptors.add(PerformanceInterceptor(options: options));
    });
    if(ipAddr!=null&&port!=null){
      _dio..httpClientAdapter = HttpProxyAdapter(ipAddr: ipAddr, port: port);
    }
  }

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String> headers = const {}}) async {
    var response = await _dio.get(url,
        options: Options(headers: headers, responseType: ResponseType.bytes));
    return HttpGetResponse(http.StreamedResponse(
        http.ByteStream.fromBytes(response.data), response.statusCode));
  }
}
