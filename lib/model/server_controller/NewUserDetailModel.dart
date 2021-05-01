import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:dcomic/model/server_controller/NewComicDetailModel.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';

class NewUserDetailModel extends BaseModel {
  final EditMode mode;
  final IPFSSourceModel node;
  final String userId;

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController avatarController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();
  String _avatar;

  List<UserRight> _rights = [];

  String error;

  NewUserDetailModel(this.mode, this.node, this.userId);

  Future<void> init() async {
    if (mode == EditMode.edit) {
      try {
        var response = await node.handler.getUserInfo(userId);
        if (response.statusCode == 200) {
          usernameController.text = response.data['data']['username'];
          passwordController.text = response.data['data']['password'];
          nicknameController.text = response.data['data']['nickname'];
          _avatar = response.data['data']['avatar'];
          avatarController.text = _avatar;
          _rights = response.data['data']['rights']
              .map<UserRight>((e) => UserRight(
                  e['right_num'], e['right_description'], e['right_target']))
              .toList();
          error=null;
          notifyListeners();
        }
      } on DioError catch (e, s) {
        FirebaseCrashlytics.instance
            .recordError(e, s, reason: 'userLoadingFailed');
        error = e.response.data['msg'];
      } catch (e, s) {
        FirebaseCrashlytics.instance
            .recordError(e, s, reason: 'userLoadingFailed');
        error = '未知错误：$e';
      }
      notifyListeners();
    }
  }

  Future<void> uploadAvatar() async {
    var result = await FilePicker.platform.pickFiles(type: FileType.image);
    try {
      var response = await node.handler.uploadImage(result.files.single);
      if (response.statusCode == 200) {
        _avatar = response.data['data']['cid'];
        avatarController.text = _avatar;
        notifyListeners();
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'uploadCoverFailed');
    }
  }

  Future<bool> updateUser() async {
    try {
      if (mode == EditMode.edit) {
        var response =
            await node.handler.updateUser(usernameController.text, toMap());
        if (response.statusCode == 200) {
          return true;
        }
      } else {
        var response =
            await node.handler.addUser(usernameController.text, toMap());
        if (response.statusCode == 200) {
          return true;
        }
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'updateUserFailed');
    }
    return false;
  }

  Future<bool> deleteUser() async {
    try {
      var response = await node.handler.deleteUser(usernameController.text);
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'updateUserFailed');
    }
    return false;
  }

  void addRight(UserRight right) {
    _rights.add(right);
    notifyListeners();
  }

  void deleteRight(UserRight right) {
    _rights.remove(right);
    notifyListeners();
  }

  Map toMap() {
    return {
      "username": usernameController.text,
      "password": passwordController.text,
      "avatar": avatarController.text,
      "rights": _rights.map<Map>((e) => e.toMap()).toList(),
      "nickname": nicknameController.text
    };
  }

  String get avatar => '${node.address}/upload/ipfs/$_avatar';

  bool get hasAvatar => _avatar != null;

  List<UserRight> get rights => _rights;
}

class UserRight {
  final int rightNum;
  final String rightDescription;
  final Map rightTarget;

  UserRight(this.rightNum, this.rightDescription, this.rightTarget);

  Map toMap() {
    return {
      "right_num": rightNum,
      "right_description": rightDescription,
      "right_target": rightTarget
    };
  }
}
