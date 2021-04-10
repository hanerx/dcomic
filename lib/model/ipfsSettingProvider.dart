import 'package:flutterdmzj/model/baseModel.dart';

class IPFSSettingProvider extends BaseModel{
  int _mode=0;
  static List modes=['server','ipfsio','ipfslite'];
  String _server='127.0.0.1';
  int _port=5001;
  bool _enableProxy=false;
  String _proxyServer='127.0.0.1';
  int _proxyPort=0;

  int get mode => _mode;

  set mode(int value) {
    if(value>=0&&value<modes.length){
      _mode = value;
    }else{
      _mode=0;
    }
    notifyListeners();
  }

  String get server => _server;

  set server(String value) {
    _server = value;
    notifyListeners();
  }

  int get proxyPort => _proxyPort;

  set proxyPort(int value) {
    _proxyPort = value;
    notifyListeners();
  }

  String get proxyServer => _proxyServer;

  set proxyServer(String value) {
    _proxyServer = value;
    notifyListeners();
  }

  int get port => _port;

  set port(int value) {
    _port = value;
    notifyListeners();
  }

  bool get enableProxy => _enableProxy;

  set enableProxy(bool value) {
    _enableProxy = value;
    notifyListeners();
  }
}