import 'package:dcomic/http/IPFSSourceRequestHandler.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';

class ServerMainPageModel extends BaseModel {
  final IPFSSourceModel node;
  IPFSSourceRequestHandler _handler;
  String _username;

  ServerMainPageModel(this.node) {
    _handler = node.handler;
  }

  String get username => _username;

  String get title => node.title;

  String get address => node.address;

  String get name => node.name;

  String get version => node.version;

  int get mode => node.mode;

  String get description => node.description;
}
