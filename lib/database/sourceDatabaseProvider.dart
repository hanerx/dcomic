import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sqflite/sqflite.dart';

import 'databaseCommon.dart';

class SourceDatabaseProvider {
  static Future<Database> initDataBase() async {
    return await DatabaseCommon.initDatabase();
  }

  static Future<Map> getSourceOptions(String name) async {
    Database database = await initDataBase();
    List<Map> maps = await database
        .query('source_options', where: 'source_name = ?', whereArgs: [name]);
    Map data = {};
    for (var item in maps) {
      data[item['key']] = item['value'];
    }
    return data;
  }

  static Future getSourceOption<T>(String name, String key,
      {T defaultValue}) async {
    Database database = await initDataBase();
    try {
      List<Map> maps = await database.query('source_options',
          where: 'source_name = ? AND key = ?', whereArgs: [name, key]);
      switch (T) {
        case String:
          return maps.first['value'];
        case int:
          return int.parse(maps.first['value']);
        case bool:
          return maps.first['value'] == '1';
        case double:
          return double.parse(maps.first['value']);
        case List:
          return maps.first['value'].toString().split(',');
        default:
          return maps.first['value'];
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'getSourceOptionFailed: $name, key: $key');
    }
    return defaultValue;
  }

  static Future<void> insertSourceOption<T>(
      String name, String key, dynamic value) async {
    Database database = await initDataBase();
    await database.delete('source_options',
        where: 'source_name = ? and key= ?', whereArgs: [name, key]);
    switch (T) {
      case bool:
        await database.insert('source_options',
            {'source_name': name, 'key': key, 'value': value ? '1' : '0'});
        break;
      default:
        await database.insert('source_options',
            {'source_name': name, 'key': key, 'value': value.toString()});
    }
  }

  static Future<void> boundComic(
      String name, String comicId, String boundId) async {
    if (comicId != null && boundId != null) {
      Database database = await initDataBase();
      await database.delete('comic_bounding',
          where: 'source_name = ? and comic_id= ?', whereArgs: [name, comicId]);
      await database.insert('comic_bounding',
          {'comic_id': comicId, 'bound_id': boundId, 'source_name': name});
    }
  }

  static Future<Map> getBoundComic(String name, String comicId) async {
    Database database = await initDataBase();
    try {
      List<Map> maps = await database.query('comic_bounding',
          where: 'source_name = ? and comic_id=?', whereArgs: [name, comicId]);
      return maps.first;
    } catch (e) {
      return null;
    }
  }
}
