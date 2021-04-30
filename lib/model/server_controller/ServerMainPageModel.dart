import 'package:dcomic/http/IPFSSourceRequestHandler.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ServerMainPageModel extends BaseModel {
  final IPFSSourceModel node;
  IPFSSourceRequestHandler _handler;
  String _username;
  String _nickname;
  String _avatar;
  List _rights = [];

  ServerMainPageModel(this.node) {
    _handler = node.handler;
    init();
  }

  Future<void> init() async {
    try {
      var response = await _handler.getUserState();
      if (response.statusCode == 200) {
        _username = response.data['data']['username'];
        _nickname = response.data['data']['nickname'];
        _rights = response.data['data']['rights'];
        _avatar = response.data['data']['avatar'];
        notifyListeners();
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'serverLoadingFailed: $address');
    }
  }

  Future<void> addServer(String address, String token) async {
    try {
      var response = await _handler.addServer(address, token);
      if (response.statusCode == 200) {
        return;
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'serverAddFailed: $address');
    }
  }

  String get username => _username;

  String get title => node.title;

  String get address => node.address;

  String get name => node.name;

  String get version => node.version;

  int get mode => node.mode;

  String get description => node.description;

  List get rights => _rights;

  String get nickname => _nickname;

  String get avatar => _avatar;

  bool get admin {
    for (var item in rights) {
      if (item['right_num'] == 1) {
        return true;
      }
    }
    return false;
  }
}
