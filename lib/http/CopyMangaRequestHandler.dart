import 'dart:convert';
import 'dart:math';

import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dio/dio.dart';

class CopyMangaRequestHandler extends SingleDomainRequestHandler {
  CopyMangaRequestHandler() : super('https://api.copymanga.com/');

  Future<Options> setHeader([Map<String,dynamic> headers]) async {
    if (await SourceDatabaseProvider.getSourceOption<bool>(
        'copy_manga', 'login',
        defaultValue: false)) {
      String token =
          await SourceDatabaseProvider.getSourceOption('copy_manga', 'token');
      if (headers == null) {
        headers = {};
      }
      headers['authorization'] = 'Token $token';
    }
    return Options(headers: headers);
  }

  Future<Response> getComicDetail(String comicId) {
    return dio.get('/api/v3/comic2/$comicId?platform=1');
  }

  Future<Response> getChapters(String comicId, String groupName,
      {int limit: 100, int page: 0}) {
    return dio.get(
        '/api/v3/comic/$comicId/group/$groupName/chapters?limit=$limit&offset=$page');
  }

  Future<Response> getComic(String comicId, String chapterId) async {
    return dio.get(
        '/api/v3/comic/$comicId/chapter/$chapterId?platform=1&_update=true',
        options: await setHeader({
          'User-Agent':
              'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36'
        }));
  }

  Future<Response> search(String keyword, {int page: 0}) {
    return dio.get(
        '/api/v3/search/comic?platform=1&q=$keyword&limit=20&offset=$page&q_type=&_update=true');
  }

  Future<Response> login(String username, String password) async {
    int salt = Random().nextInt(9000) + 1000;
    var data = FormData.fromMap({
      'username': username,
      'password': base64Encode(utf8.encode('$password-$salt')),
      'salt': salt,
      'source': 'freeSite',
      'version': '2021.04.01',
      'platform': 1
    });
    return dio.post('/api/v3/login', data: data);
  }

  Future<Response> logout() async {
    return dio.post('/api/v3/logout', options: await setHeader());
  }

  Future<Response> getSubscribe({int page: 0}) async {
    return dio.get(
        '/api/v3/member/collect/comics?free_type=1&limit=21&offset=$page&_update=true&ordering=-datetime_modifier',
        options: await setHeader());
  }

  Future<Response> getUserInfo() async {
    return dio.get('/api/v3/member/info', options: await setHeader());
  }

  Future<Response> getIfSubscribe(String comicId) async {
    return dio.get('/api/v3/comic2/query/$comicId?platform=1',
        options: await setHeader());
  }

  Future<Response> addSubscribe(String comicId, bool subscribe) async {
    var data = FormData.fromMap(
        {'comic_id': comicId, 'is_collect': subscribe ? 1 : 0});
    return dio.post('/api/v3/member/collect/comic',
        data: data, options: await setHeader());
  }
}
