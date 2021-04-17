import 'dart:typed_data';

import 'package:dcomic/utils/HttpProxyAdapter.dart';
import 'package:dio/dio.dart';
import 'package:dcomic/database/configDatabaseProvider.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:ipfs/ipfs.dart';

class IPFSSettingProvider extends BaseModel {
  int _mode = 0;
  static List modes = ['server', 'ipfsio', 'ipfslite'];
  String _server = '127.0.0.1';
  int _port = 5001;
  bool _enableProxy = false;
  String _proxyServer = '127.0.0.1';
  int _proxyPort = 0;
  IPFSConfigDatabaseProvider _databaseProvider = IPFSConfigDatabaseProvider();

  IPFSSettingProvider() {
    init();
  }

  Future<void> init() async {
    _mode = await _databaseProvider.mode;
    _server = await _databaseProvider.server;
    _port = await _databaseProvider.port;
    _enableProxy = await _databaseProvider.enableProxy;
    _proxyServer = await _databaseProvider.proxyServer;
    _proxyPort = await _databaseProvider.proxyPort;
    notifyListeners();
  }

  int get mode => _mode;

  set mode(int value) {
    if (value >= 0 && value < modes.length) {
      _mode = value;
    } else {
      _mode = 0;
    }
    _databaseProvider.mode = Future.value(_mode);
    notifyListeners();
  }

  String get server => _server;

  set server(String value) {
    _server = value;
    _databaseProvider.server = Future.value(value);
    notifyListeners();
  }

  int get proxyPort => _proxyPort;

  set proxyPort(int value) {
    _proxyPort = value;
    _databaseProvider.proxyPort = Future.value(value);
    notifyListeners();
  }

  String get proxyServer => _proxyServer;

  set proxyServer(String value) {
    _proxyServer = value;
    _databaseProvider.proxyServer = Future.value(value);
    notifyListeners();
  }

  int get port => _port;

  set port(int value) {
    _port = value;
    _databaseProvider.port = Future.value(value);
    notifyListeners();
  }

  bool get enableProxy => _enableProxy;

  set enableProxy(bool value) {
    _enableProxy = value;
    _databaseProvider.enableProxy = Future.value(value);
    notifyListeners();
  }


  Future<Uint8List> catBytes(String cid)async{
    Dio dio = Dio();
    if (enableProxy) {
      dio
        ..httpClientAdapter = HttpProxyAdapter(
            ipAddr: proxyServer,
            port: proxyPort);
    }
    switch (mode) {
      case 0:
        Ipfs ipfs = Ipfs.dio(
            baseUrl: server,
            port: port,
            dio: dio);
        var item = await ipfs.catBytes(cid);
        return Uint8List.fromList(item);
        break;
      case 1:
        var response = await dio.get(
            'https://ipfs.io/ipfs/$cid',
            options: Options(responseType: ResponseType.bytes));
        return Uint8List.fromList(response.data);
        break;
    }
    return null;
  }
}
