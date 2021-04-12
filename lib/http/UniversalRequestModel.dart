import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dio_proxy/dio_proxy.dart';
import 'package:dcomic/http/DMZJRequestHandler.dart';
import 'package:dcomic/http/KuKuRequestHandler.dart';
import 'package:dcomic/http/ManHuaGuiRequestHandler.dart';
import 'package:gbk_codec/gbk_codec.dart';

import 'MangabzRequestHandler.dart';

class UniversalRequestModel {
  MangabzRequestHandler mangabzRequestHandler = MangabzRequestHandler();

  ManHuaGuiRequestHandler manHuaGuiRequestHandler = ManHuaGuiRequestHandler();

  KuKuRequestHandler kuKuRequestHandler = KuKuRequestHandler();

  SoKuKuRequestHandler soKuKuRequestHandler = SoKuKuRequestHandler();

  KKKKRequestHandler kkkkRequestHandler1 =
      KKKKRequestHandler('http://comic.kkkkdm.com/');

  KKKKRequestHandler kkkkRequestHandler2 =
      KKKKRequestHandler('http://comic2.kkkkdm.com/');

  KKKKRequestHandler kkkkRequestHandler3 =
      KKKKRequestHandler('http://comic3.kkkkdm.com/');

  DMZJRequestHandler dmzjRequestHandler = DMZJRequestHandler();

  DMZJIRequestHandler dmzjiRequestHandler = DMZJIRequestHandler();

  DMZJInterfaceRequestHandler dmzjInterfaceRequestHandler =DMZJInterfaceRequestHandler();
}

abstract class RequestHandler {
  Dio dio;

  Future<bool> clearCache();

  Future<bool> clearExpired();

  void setProxy(String ip, int port);

  String gbkDecoder(List<int> responseBytes, RequestOptions options,
      ResponseBody responseBody) {
    return gbk_bytes.decode(responseBytes);
  }

  List<int> gbkEncoder(String requestString, RequestOptions options) {
    return gbk_bytes.encode(requestString);
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

abstract class SingleDomainRequestHandler extends RequestHandler {
  Dio dio;
  DioCacheManager cacheManager;
  final String baseUrl;

  SingleDomainRequestHandler(this.baseUrl) {
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

@Deprecated('没意义')
abstract class MultiDomainRequestHandler extends RequestHandler {
  List<String> baseUrl;
  List<DioCacheManager> cacheManagers;
}
