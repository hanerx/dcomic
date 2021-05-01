import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ServerListModel extends BaseModel {
  final IPFSSourceModel node;

  List<Node> _data = [];

  ServerListModel(this.node);

  Future<void> init() async {
    try {
      var response = await node.handler.getServerList();
      if (response.statusCode == 200) {
        _data = response.data['data']
            .map<Node>((e) => Node(e['address'], e['token'], e['name'],
                e['title'], e['description'], e['type'], e['version']))
            .toList();
        notifyListeners();
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'serverListLoadingFailed: ${node.address}');
    }
  }

  Future<void> delete(String address) async {
    try {
      var response = await node.handler.deleteServer(address);
      if (response.statusCode == 200) {
        await init();
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'serverListDeleteFailed: ${address}');
    }
  }

  List<Node> get data => _data;
}

class Node {
  final String address;
  final String token;
  final String name;
  final String title;
  final String description;
  final int type;
  final String version;

  static List modeList = ['独立服务', '分发服务器', '从服务器', '双向共享服务器'];

  Node(this.address, this.token, this.name, this.title, this.description,
      this.type, this.version);

  String get mode =>
      type >= 0 && type < modeList.length ? modeList[type] : '未知服务器模式';
}
