import 'dart:io';

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
      : super(key, fileService: ProxyFileService(ipAddr, port));

  @override
  Future<String> getFilePath() async {
    // TODO: implement getFilePath
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }
}

class ProxyFileService implements FileService {
  HttpClient _httpClient;

  ProxyFileService(String ipAddr, int port) {
    _httpClient = HttpClient();
    String proxy = '$ipAddr:$port';
    _httpClient.findProxy = (url) {
      return 'PROXY $proxy';
    };
    _httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  }

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String> headers = const {}}) async {

    final req = http.Request('GET', Uri.parse(url));
    req.headers.addAll(headers);
    return HttpGetResponse(await req.send());
  }
}
