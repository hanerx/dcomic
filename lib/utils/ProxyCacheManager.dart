// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:dio/dio.dart';
// import 'package:file/src/interface/file.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
//
// import 'HttpProxyAdapter.dart';
//
// class ProxyCacheManager extends BaseCacheManager {
//   static const key = 'libCachedImageData';
//
//   static ProxyCacheManager _instance;
//
//   factory ProxyCacheManager(String ipAddr, int port) {
//     _instance ??= ProxyCacheManager._(ipAddr, port);
//     return _instance;
//   }
//
//   ProxyCacheManager._(String ipAddr, int port)
//       : super(key, fileService: ProxyFileService.proxy(ipAddr, port));
//
//   @override
//   Future<String> getFilePath() async {
//     // TODO: implement getFilePath
//     var directory = await getTemporaryDirectory();
//     return p.join(directory.path, key);
//   }
//
//   @override
//   Future<void> dispose() {
//     // TODO: implement dispose
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<FileInfo> downloadFile(String url, {String key, Map<String, String> authHeaders, bool force = false}) {
//     // TODO: implement downloadFile
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<void> emptyCache() {
//     // TODO: implement emptyCache
//     throw UnimplementedError();
//   }
//
//   @override
//   Stream<FileInfo> getFile(String url, {String key, Map<String, String> headers}) {
//     // TODO: implement getFile
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<FileInfo> getFileFromCache(String key, {bool ignoreMemCache = false}) {
//     // TODO: implement getFileFromCache
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<FileInfo> getFileFromMemory(String key) {
//     // TODO: implement getFileFromMemory
//     throw UnimplementedError();
//   }
//
//   @override
//   Stream<FileResponse> getFileStream(String url, {String key, Map<String, String> headers, bool withProgress}) {
//     // TODO: implement getFileStream
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<File> getSingleFile(String url, {String key, Map<String, String> headers}) {
//     // TODO: implement getSingleFile
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<File> putFile(String url, Uint8List fileBytes, {String key, String eTag, Duration maxAge = const Duration(days: 30), String fileExtension = 'file'}) {
//     // TODO: implement putFile
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<File> putFileStream(String url, Stream<List<int>> source, {String key, String eTag, Duration maxAge = const Duration(days: 30), String fileExtension = 'file'}) {
//     // TODO: implement putFileStream
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<void> removeFile(String key) {
//     // TODO: implement removeFile
//     throw UnimplementedError();
//   }
// }
//
// class ProxyFileService implements FileService {
//   Dio _dio;
//
//   ProxyFileService.proxy(String ipAddr, int port) {
//     _dio=Dio();
//     _dio..httpClientAdapter = HttpProxyAdapter(ipAddr: ipAddr, port: port);
//   }
//
//   @override
//   Future<FileServiceResponse> get(String url,
//       {Map<String, String> headers = const {}}) async {
//     var response = await _dio.get(url,
//         options: Options(headers: headers, responseType: ResponseType.bytes));
//     return HttpGetResponse(http.StreamedResponse(
//         http.ByteStream.fromBytes(response.data), response.statusCode));
//   }
//
//   @override
//   int concurrentFetches;
// }
