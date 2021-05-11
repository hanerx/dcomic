import 'dart:convert';

import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class IPFSSourceRequestHandler extends SingleDomainRequestHandler {
  final SourceDetail sourceDetail;

  IPFSSourceRequestHandler(String baseUrl, this.sourceDetail) : super(baseUrl);

  Future<Map<String, String>> setHeader([Map<String, String> headers]) async {
    if (await SourceDatabaseProvider.getSourceOption<bool>(
        sourceDetail.name, "login")) {
      if (headers == null) {
        headers = {};
      }
      headers['token'] = await SourceDatabaseProvider.getSourceOption(
          sourceDetail.name, "token");
    }
    return headers;
  }

  Future<Response> getComicDetail(String comicId) {
    return dio.get('/comic/$comicId');
  }

  Future<Response> getGroup(String comicId, String groupId) {
    return dio.get('/comic/$comicId/$groupId');
  }

  Future<Response> getChapter(
      String comicId, String groupId, String chapterId) {
    return dio.get('/comic/$comicId/$groupId/$chapterId');
  }

  Future<Response> login(String username, String password) {
    var data = FormData.fromMap({"username": username, "password": password});
    return dio.post('/user/login', data: data);
  }

  Future<Response> logout() async {
    return dio.post('/user/logout',
        options: Options(headers: await setHeader()));
  }

  Future<Response> search(String keyword) {
    return dio.get('/comic/search/$keyword');
  }

  Future<Response> getServerState() {
    return dio.get('/server/state');
  }

  Future<Response> getUserState() async {
    return dio.get('/user/my', options: Options(headers: await setHeader()));
  }

  Future<Response> getServerList() async {
    return dio.get('/server/', options: Options(headers: await setHeader()));
  }

  Future<Response> deleteServer(String address) async {
    return dio.delete("/server/delete?address=$address",
        options: Options(headers: await setHeader()));
  }

  Future<Response> addServer(String address, String token) async {
    return dio.post('/server/add',
        data: jsonEncode({"address": address, "token": token}),
        options: Options(headers: await setHeader()));
  }

  Future<Response> getUserList() async {
    return dio.get('/user/', options: Options(headers: await setHeader()));
  }

  Future<Response> uploadImage(PlatformFile file) async {
    FormData data = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        file.path, //图片路径
        filename: file.name, //图片名称
      )
    });
    return dio.post('/upload/image',
        data: data, options: Options(headers: await setHeader()));
  }

  Future<Response> updateComic(String comicId, Map data) async {
    return dio.put('/comic/$comicId',
        data: jsonEncode(data), options: Options(headers: await setHeader()));
  }

  Future<Response> addComic(String comicId, Map data) async {
    return dio.post('/comic/$comicId',
        data: jsonEncode(data), options: Options(headers: await setHeader()));
  }

  Future<Response> deleteComic(String comicId) async {
    return dio.delete('/comic/$comicId',
        options: Options(headers: await setHeader()));
  }

  Future<Response> getUserInfo(String userId) async {
    return dio.get('/user/$userId',
        options: Options(headers: await setHeader()));
  }

  Future<Response> deleteUser(String username) async {
    return dio.delete('/user/$username',
        options: Options(headers: await setHeader()));
  }

  Future<Response> addUser(String username, Map data) async {
    return dio.post('/user/$username',
        data: jsonEncode(data), options: Options(headers: await setHeader()));
  }

  Future<Response> updateUser(String username, Map data) async {
    return dio.put('/user/$username',
        data: jsonEncode(data), options: Options(headers: await setHeader()));
  }

  Future<Response> getSubscribe() async {
    return dio.get('/user/subscribe',
        options: Options(headers: await setHeader()));
  }

  Future<Response> addSubscribe(String comicId) async {
    return dio.post('/user/subscribe/$comicId',
        options: Options(headers: await setHeader()));
  }

  Future<Response> cancelSubscribe(String comicId) async {
    return dio.delete('/user/subscribe/$comicId',
        options: Options(headers: await setHeader()));
  }

  Future<Response> getIfSubscribe(String comicId) async {
    return dio.get('/user/subscribe/$comicId',
        options: Options(headers: await setHeader()));
  }

  Future<Response> getAuthor(String authorId) {
    return dio.get('/author/$authorId');
  }

  Future<Response> getCategoryDetail(String categoryId) {
    return dio.get('/tag/$categoryId');
  }
}
