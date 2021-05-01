import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/database/configDatabaseProvider.dart';
import 'package:dcomic/model/baseModel.dart';

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

  bool _labState = false;

  bool _novel = false;

  bool _deepSearch = false;

  bool _darkSide = false;

  bool _crashReport = true;

  FirebaseAnalytics analytics = FirebaseAnalytics();

  SystemConfigDatabaseProvider _databaseProvider =
      SystemConfigDatabaseProvider();

  SystemSettingModel() {
    this
        .init()
        .then((value) => logger.i('class: SystemSettingModel, action: init'));
  }

  Future<void> init() async {
    _crashReport = await _databaseProvider.crashReport;
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(_crashReport);
    if (_crashReport) {
      initAnonymousUser();
    }
    _darkState = await _databaseProvider.darkMode;
    _backupApi = await _databaseProvider.backupApi;
    _blackBox = await _databaseProvider.blackBox;
    _savePath = await _databaseProvider.downloadPath;
    _noMedia = await File('$savePath/.nomedia').exists();
    _labState = await _databaseProvider.labState;
    _novel = await _databaseProvider.novelState;
    _darkSide = await _databaseProvider.darkSide;
    _deepSearch = await _databaseProvider.deepSearch;
    notifyListeners();
  }

  initAnonymousUser() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    FirebaseCrashlytics.instance.setUserIdentifier(userCredential.user.uid);
  }

  ThemeMode get themeMode => darkMode[_darkState];

  set darkState(int state) {
    _databaseProvider.darkMode = Future.value(state);
    _darkState = state;
    notifyListeners();
  }

  int get darkState => _darkState;

  bool get backupApi => _backupApi;

  set backupApi(bool state) {
    _databaseProvider.backupApi = Future.value(state);
    _backupApi = state;
    notifyListeners();
  }

  bool get blackBox => _blackBox;

  set blackBox(bool value) {
    _databaseProvider.blackBox = Future.value(value);
    _blackBox = value;
    notifyListeners();
  }

  String get savePath => _savePath;

  set savePath(String path) {
    _databaseProvider.downloadPath = Future.value(path);
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

  bool get labState => _labState;

  set labState(bool value) {
    _databaseProvider.labState = Future.value(value);
    _labState = value;
    notifyListeners();
  }

  bool get darkSide => _darkSide;

  set darkSide(bool value) {
    _databaseProvider.darkSide = Future.value(value);
    _darkSide = value;
    notifyListeners();
  }

  bool get deepSearch => _deepSearch;

  set deepSearch(bool value) {
    _databaseProvider.deepSearch = Future.value(value);
    _deepSearch = value;
    notifyListeners();
  }

  bool get novel => _novel;

  set novel(bool value) {
    _databaseProvider.novelState = Future.value(value);
    _novel = value;
    notifyListeners();
  }

  bool get crashReport => _crashReport;

  set crashReport(bool value) {
    _databaseProvider.crashReport = Future.value(value);
    _crashReport = value;
    analytics.logEvent(name: 'stop_crash_report');
    notifyListeners();
  }
}
