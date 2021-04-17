import 'dart:io';

import 'package:dcomic/component/EmptyView.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/component/DataBaseDefineTile.dart';
import 'package:dcomic/component/DataBaseTable.dart';
import 'package:dcomic/database/databaseCommon.dart';
import 'package:dcomic/model/baseModel.dart';
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
      if(DatabaseCommon.databases[element].dropVersion==null||DatabaseCommon.databases[element].dropVersion>version){
        data[element]=await _database.query(element);
      }
    }
    notifyListeners();
  }

  List<Tab> getTabs(context){
    return tabs.map<Tab>((e) => Tab(text: '$e',)).toList();
  }

  Future<String> backupDatabase(String path)async{
    try{
      var file=File(this.path);
      var directory = new Directory('$path');
      directory.createSync(recursive: true);
      String save='${directory.path}/dmzj.db';
      await file.copy(save);
      return save;
    }catch(e,s){
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'backupDatabaseFailed');
      logger.e('class: DatabaseDetailModel, action: moveFileFailed, exception: $e');
    }
    return null;
  }

  Future<bool> recoverDatabase(String path)async{
    try{
      var file=File(path);
      if(await file.exists()){
        await file.copy(this.path);
        return true;
      }
    }catch(e,s){
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'recoverDatabaseFailed');
      logger.e('class: DatabaseDetailModel, action: moveFileFailed, exception: $e');
    }
    return false;
  }

  List<Widget> getTabViews(context){
    return tabs.map<Widget>((e) =>DatabaseCommon.databases[e].dropVersion==null||DatabaseCommon.databases[e].dropVersion>version?DataBaseTable(headers:DatabaseCommon.databases[e].tables.keys.toList(),data: data[e],table: e,):EmptyView(message: '该表已弃用，不做显示',)).toList();
  }

  Widget getDatabaseDefine(context,index){
    var e=tabs[index];
    return DatabaseDefineTile(model: DatabaseCommon.databases[e],table: e,);
  }

  List get tabs=>DatabaseCommon.databases.keys.toList();
}