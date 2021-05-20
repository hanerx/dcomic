import 'package:flutter/material.dart';
import 'package:dcomic/database/configDatabaseProvider.dart';
import 'package:dcomic/model/baseModel.dart';

class ComicViewerSettingModel extends BaseModel {
  bool _direction = false;
  bool _debug = false;
  double _hitBox = 100;
  double _range = 500;
  bool _reverse = false;
  int _backgroundColor = 0;
  bool _animation = true;
  bool _autoDark = false;
  bool _enableViewpoint = false;
  ViewerConfigDatabaseProvider _databaseProvider =
      ViewerConfigDatabaseProvider();
  static const List backgroundColors = [
    Colors.white,
    Colors.black,
    Colors.brown,
    Colors.blueGrey,
    Color.fromARGB(100, 242, 235, 217),
    Color.fromRGBO(239, 217, 176, 1),
    Color.fromRGBO(255, 240, 205, 1)
  ];

  ComicViewerSettingModel() {
    init();
  }

  init() async {
    _direction = await _databaseProvider.readDirection;
    _hitBox = await _databaseProvider.hitBox;
    _range = await _databaseProvider.range;
    _reverse = await _databaseProvider.readHorizontalDirection;
    _backgroundColor = await _databaseProvider.backgroundColor;
    _animation = await _databaseProvider.enableAnimation;
    _autoDark = await _databaseProvider.autoDark;
    _enableViewpoint = await _databaseProvider.enableViewpoint;
    notifyListeners();
  }

  int get backgroundColor => _backgroundColor;

  set backgroundColor(int value) {
    _databaseProvider.backgroundColor = Future.value(value);
    _backgroundColor = value;
    notifyListeners();
  }

  bool get reverse => _reverse;

  set reverse(bool value) {
    _databaseProvider.readHorizontalDirection = Future.value(value);
    _reverse = value;
    notifyListeners();
  }

  double get range => _range;

  set range(double value) {
    _databaseProvider.range = Future.value(value);
    _range = value;
    notifyListeners();
  }

  double get hitBox => _hitBox;

  set hitBox(double value) {
    _databaseProvider.hitBox = Future.value(value);
    _hitBox = value;
    notifyListeners();
  }

  bool get debug => _debug;

  set debug(bool value) {
    _debug = value;
    notifyListeners();
  }

  bool get direction => _direction;

  set direction(bool value) {
    _databaseProvider.readDirection = Future.value(value);
    _direction = value;
    notifyListeners();
  }

  bool get animation => _animation;

  set animation(bool value) {
    _databaseProvider.enableAnimation = Future.value(value);
    _animation = value;
    notifyListeners();
  }

  bool get autoDark => _autoDark;

  set autoDark(bool value) {
    _databaseProvider.autoDark = Future.value(value);
    _autoDark = value;
    notifyListeners();
  }

  bool get enableViewpoint => _enableViewpoint;

  set enableViewpoint(bool value) {
    _databaseProvider.enableViewpoint = Future.value(value);
    _enableViewpoint = value;
    notifyListeners();
  }
}
