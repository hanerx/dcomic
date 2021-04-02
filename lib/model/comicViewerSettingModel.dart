import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/model/baseModel.dart';

class ComicViewerSettingModel extends BaseModel{
  bool _webApi=false;
  bool _direction = false;
  bool _debug = false;
  double _hitBox = 100;
  double _range = 500;
  bool _reverse = false;
  int _backgroundColor = 0;
  bool _animation=true;
  bool _autoDark=false;
  DataBase _dataBase=DataBase();
  static const List backgroundColors = [
    Colors.white,
    Colors.black,
    Colors.brown,
    Colors.blueGrey,
    Color.fromARGB(100, 242, 235, 217),
    Color.fromRGBO(239, 217, 176, 1),
    Color.fromRGBO(255, 240, 205, 1)
  ];

  ComicViewerSettingModel(){
    init();
  }

  init()async{
    _webApi=await _dataBase.getWebApi();
    _direction=await _dataBase.getReadDirection();
    _hitBox=await _dataBase.getControlSize();
    _range=await _dataBase.getRange();
    _reverse=await _dataBase.getHorizontalDirection();
    _backgroundColor=await _dataBase.getBackground();
    _animation=await _dataBase.getAnimation();
    _autoDark=await _dataBase.getAutoDark();
    notifyListeners();
  }

  bool get webApi=>_webApi;

  set webApi(bool state){
    _dataBase.setWebApi(state);
    _webApi=state;
    notifyListeners();
  }

  int get backgroundColor => _backgroundColor;

  set backgroundColor(int value) {
    _dataBase.setBackground(value);
    _backgroundColor = value;
    notifyListeners();
  }

  bool get reverse => _reverse;

  set reverse(bool value) {
    _dataBase.setHorizontalDirection(value);
    _reverse = value;
    notifyListeners();
  }

  double get range => _range;

  set range(double value) {
    _dataBase.setRange(value);
    _range = value;
    notifyListeners();
  }

  double get hitBox => _hitBox;

  set hitBox(double value) {
    _dataBase.setControlSize(value);
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
    _dataBase.setReadDirection(value);
    _direction = value;
    notifyListeners();
  }

  bool get animation=>_animation;

  set animation(bool value){
    _dataBase.setAnimation(value);
    _animation=value;
    notifyListeners();
  }

  bool get autoDark=>_autoDark;

  set autoDark(bool value){
    _dataBase.setAutoDark(value);
    _autoDark=value;
    notifyListeners();
  }
}