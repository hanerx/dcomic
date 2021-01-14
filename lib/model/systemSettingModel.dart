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
}
