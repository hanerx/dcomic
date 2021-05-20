
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

import 'HttpProxyAdapter.dart';

class ProxyCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'libCachedImageData';

  static ProxyCacheManager _instance;
  factory ProxyCacheManager(String ipAddr,int port) {
    if(_instance==null){
      _instance=ProxyCacheManager._(ipAddr, port);
    }
    return _instance;
  }

  ProxyCacheManager._(String ipAddr, int port)
      : super(Config(key, fileService: ProxyFileService.proxy(ipAddr, port)));
}

class ProxyFileService extends FileService {
  Dio _dio;

  ProxyFileService.proxy(String ipAddr, int port) {
    _dio = Dio();
    _dio..httpClientAdapter = HttpProxyAdapter(ipAddr: ipAddr, port: port);
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
