import 'package:dcomic/model/mag_model/baseMangaModel.dart';
import 'package:dcomic/utils/log_output.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import 'databaseCommon.dart';

class LocalMangaDatabaseProvider {
  Database _database;
  Logger logger = Logger(
      filter: ReleaseFilter(),
      printer: PrettyPrinter(),
      output: ConsoleLogOutput());

  Future<Database> get db async {
    if (_database == null) {
      _database = await DatabaseCommon.initDatabase();
    }
    return _database;
  }

  Future<MangaObject> get(String name) async {
    try {
      var batch = (await db).batch();
      batch.query('local_manga', where: 'name = ?', whereArgs: [name]);
      var data = await batch.commit() as List<dynamic>;
      return await BaseMangaModel().decodeFromDirectory(data.first[0]['path']);
    } catch (e,s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'getMangaFailed');
      logger.e(
          'class: ${this.runtimeType} action: getMangaFailed, exception: $e');
      throw e;
    }
  }

  Future<List<MangaObject>> search(String name) async {
    try {
      var batch = (await db).batch();
      batch.query('local_manga', where: 'name LIKE ?', whereArgs: ['%$name%']);
      var data = await batch.commit();
      var model = BaseMangaModel();
      List<MangaObject> list = [];
      for (var e in data.first) {
        list.add(await model.decodeFromDirectory(e['path']));
      }
      return list;
    } catch (e,s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'getMangaFailed');
      logger.e(
          'class: ${this.runtimeType} action: getMangaFailed, exception: $e');
      throw e;
    }
  }

  Future<List<MangaObject>> getAll() async {
    try {
      var batch = (await db).batch();
      batch.query('local_manga');
      var data = await batch.commit();
      var model = BaseMangaModel();
      List<MangaObject> list = [];
      for (var e in data.first) {
        list.add(await model.decodeFromDirectory(e['path']));
      }
      return list;
    } catch (e) {
      logger.e(
          'class: ${this.runtimeType} action: getMangaFailed, exception: $e');
      throw e;
    }
  }

  Future<void> insert(MangaObject mangaObject) async {
    try {
      var batch = (await db).batch();
      batch.delete('local_manga',
          where: 'name = ?', whereArgs: [mangaObject.name]);
      batch.insert('local_manga', {
        'name': mangaObject.name,
        'title': mangaObject.title,
        'path': mangaObject.basePath
      });
      await batch.commit();
    } catch (e) {
      logger.e(
          'class: ${this.runtimeType} action: getMangaFailed, exception: $e');
      throw e;
    }
  }

  Future<void> delete(MangaObject mangaObject) async {
    try {
      var batch = (await db).batch();
      batch.delete('local_manga',
          where: 'name = ?', whereArgs: [mangaObject.name]);
      await batch.commit();
    } catch (e) {
      logger.e(
          'class: ${this.runtimeType} action: deleteMangaFailed, exception: $e');
      throw e;
    }
  }
}
