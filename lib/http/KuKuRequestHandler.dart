

import 'package:dio/dio.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:gbk2utf8/gbk2utf8.dart';

class KuKuRequestHandler extends KKKKRequestHandler {
  KuKuRequestHandler() : super('https://manhua.kukudm.com/');
}

class SoKuKuRequestHandler extends SingleDomainRequestHandler {
  SoKuKuRequestHandler() : super('https://so.kukudm.com/');

  Future<Response> search(String keyword, {int page: 0}) async {
    return dio.get(
      '/search.asp?kw=${(gbk.encode(keyword)).map((e) => '%${e.toRadixString(16)}'.toUpperCase()).toList().join('')}&page=$page',
      options: Options(responseDecoder: gbkDecoder),
    );
  }
}

class KKKKRequestHandler extends SingleDomainRequestHandler {
  KKKKRequestHandler(String baseUrl) : super(baseUrl,policy: CachePolicy.request);

  Future<Response> getComic(String comicId) {
    return dio.get('/comiclist/$comicId',
        options: Options(responseDecoder: gbkDecoder));
  }

  Future<Map<String, dynamic>> getChapter(
      String comicId, String chapterId, int page) async {
    return {
      'data': await dio.get('/comiclist/$comicId/$chapterId/$page.htm',
          options: Options(responseDecoder: gbkDecoder)),
      'page': page
    };
  }

  Future<Map<String, String>> getImageHosts() async {
    try {
      var response = await dio.get('/js2/js4.js');
      if (response.statusCode == 200) {
        Map<String, String> map = {};
        print(response.data.toString().split('\n'));
        for (var item in response.data.toString().split('\n')) {
          map[item.substring(item.indexOf('{') + 1, item.indexOf('='))] =
              item.substring(item.indexOf('=\'') + 2, item.indexOf('\';'));
        }
        return map;
      }
    } catch (e) {
      print(e);
    }
    return {};
  }
}
