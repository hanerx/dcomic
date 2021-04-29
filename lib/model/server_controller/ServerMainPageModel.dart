import 'package:dcomic/model/baseModel.dart';

class ServerMainPageModel extends BaseModel {
  final Map node;

  ServerMainPageModel(this.node);

  String get title => node['title'];

  String get address => node['address'];

  String get name => node['name'];

  String get version => node['version'];

  int get mode => node['type'];

  String get description => node['description'];
}
