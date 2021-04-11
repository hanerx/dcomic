import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_proxy/dio_proxy.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ProxyCacheManager extends BaseCacheManager {
  static const key = 'libCachedImageData';

  static ProxyCacheManager _instance;

  factory ProxyCacheManager(String ipAddr, int port) {
    _instance ??= ProxyCacheManager._(ipAddr, port);
    return _instance;
  }

  ProxyCacheManager._(String ipAddr, int port)
      : super(key, fileService: ProxyFileService.proxy(ipAddr, port));

  @override
  Future<String> getFilePath() async {
    // TODO: implement getFilePath
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }
}

class ProxyFileService implements FileService {
  Dio _dio;

  ProxyFileService.proxy(String ipAddr, int port) {
    _dio=Dio();
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
