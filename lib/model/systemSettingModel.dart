import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/model/baseModel.dart';

class SystemSettingModel extends BaseModel {
  static const List darkMode = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark
  ];
  int _darkState = 0;
  bool _backupApi = false;

  SystemSettingModel() {
    this
        .init()
        .then((value) => logger.i('class: SystemSettingModel, action: init'));
  }

  Future<void> init() async {
    await getDarkState();
    await getBackupApi();
  }

  Future<void> getDarkState() async {
    DataBase dataBase = DataBase();
    _darkState = await dataBase.getDarkMode();
    notifyListeners();
  }

  Future<void> getBackupApi() async {
    DataBase dataBase = DataBase();
    _backupApi = await dataBase.getBackupApi();
    notifyListeners();
  }

  ThemeMode get themeMode => darkMode[_darkState];

  set darkState(int state) {
    DataBase dataBase = DataBase();
    dataBase.setDarkMode(state);
    _darkState = state;
    notifyListeners();
  }

  int get darkState => _darkState;

  bool get backupApi => _backupApi;

  set backupApi(bool state) {
    DataBase dataBase = DataBase();
    dataBase.setBackupApi(state);
    _backupApi = state;
    notifyListeners();
  }
}
