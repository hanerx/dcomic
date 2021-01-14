import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/DataBaseDefineTile.dart';
import 'package:flutterdmzj/component/DataBaseTable.dart';
import 'package:flutterdmzj/database/databaseCommon.dart';
import 'package:flutterdmzj/model/baseModel.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseDetailModel extends BaseModel{
  Database _database;
  String path;
  int version;
  Map<String,List<Map<String,dynamic>>> data= {};


  DatabaseDetailModel(){
    init();
  }

  Future<void> init()async{
    _database=await DatabaseCommon.initDatabase();
    path=_database.path;
    version=await _database.getVersion();
    for(var element in tabs){
      data[element]=await _database.query(element);
    }
    notifyListeners();
  }

  List<Tab> getTabs(context){
    return tabs.map<Tab>((e) => Tab(text: '$e',)).toList();
  }

  Future<String> moveDatabase(String path)async{
    try{
      var file=File(this.path);
      var directory = new Directory('$path');
      directory.createSync(recursive: true);
      String save='${directory.path}/dmzj.db';
      await file.copy(save);
      return save;
    }catch(e){
      logger.e('class: DatabaseDetailModel, action: moveFileFailed, exception: $e');
    }
    return null;
  }

  List<Widget> getTabViews(context){
    return tabs.map<Widget>((e) => DataBaseTable(headers:DatabaseCommon.databases[e].tables.keys.toList(),data: data[e],)).toList();
  }

  Widget getDatabaseDefine(context,index){
    var e=tabs[index];
    return DatabaseDefineTile(model: DatabaseCommon.databases[e],table: e,);
  }

  List get tabs=>DatabaseCommon.databases.keys.toList();
}