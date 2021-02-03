import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/model/baseModel.dart';

class SystemSettingModel extends BaseModel {
  static const List darkMode = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark
  ];

  // 夜间模式
  int _darkState = 0;

  // 备用API
  bool _backupApi = false;

  bool _blackBox = false;

  String _savePath = '';

  bool _noMedia = false;

  DataBase _dataBase = DataBase();

  SystemSettingModel() {
    this
        .init()
        .then((value) => logger.i('class: SystemSettingModel, action: init'));
  }

  Future<void> init() async {
    _darkState = await _dataBase.getDarkMode();
    _backupApi = await _dataBase.getBackupApi();
    _blackBox = await _dataBase.getBlackBox();
    _savePath = await _dataBase.getDownloadPath();
    _noMedia = await File('$savePath/.nomedia').exists();
    notifyListeners();
  }

  ThemeMode get themeMode => darkMode[_darkState];

  set darkState(int state) {
    _dataBase.setDarkMode(state);
    _darkState = state;
    notifyListeners();
  }

  int get darkState => _darkState;

  bool get backupApi => _backupApi;

  set backupApi(bool state) {
    _dataBase.setBackupApi(state);
    _backupApi = state;
    notifyListeners();
  }

  bool get blackBox => _blackBox;

  set blackBox(bool value) {
    _dataBase.setBlackBox(value);
    _blackBox = value;
    notifyListeners();
  }

  String get savePath => _savePath;

  set savePath(String path) {
    _dataBase.setDownloadPath(path);
    _savePath = path;
    notifyListeners();
  }

  bool get noMedia => _noMedia;

  set noMedia(bool value) {
    _noMedia = value;
    var file = File('$savePath/.nomedia');
    if (value) {
      file.exists().then((value) {
        if (!value) {
          file.create(recursive: true);
        }
      });
    } else {
      file.exists().then((value) {
        if (value) {
          file.delete();
        }
      });
    }
    notifyListeners();
  }
}
