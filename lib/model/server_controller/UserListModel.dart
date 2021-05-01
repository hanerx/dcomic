import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class UserListModel extends BaseModel {
  final IPFSSourceModel node;
  List<User> _data = [];

  UserListModel(this.node);

  Future<void> init() async {
    try {
      var response = await node.handler.getUserList();
      if (response.statusCode == 200) {
        _data = response.data['data']
            .map<User>((e) =>
                User(e['username'], e['nickname'], e['rights'], e['avatar']))
            .toList();
        notifyListeners();
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'userLoadingFailed');
    }
  }

  List<User> get data => _data;
}

class User {
  final String username;
  final String nickname;
  final List rights;
  final String avatar;

  User(this.username, this.nickname, this.rights, this.avatar);

  bool get admin {
    for (var item in rights) {
      if (item['right_num'] == 1) {
        return true;
      }
    }
    return false;
  }
}
