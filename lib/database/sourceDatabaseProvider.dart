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

  static Future<void> insertSourceOption(
      String name, String key, dynamic value) async {
    Database database = await initDataBase();
    await database.delete('source_options',
        where: 'source_name = ? and key= ?', whereArgs: [name, key]);
    await database.insert('source_options',
        {'source_name': name, 'key': key, 'value': value.toString()});
  }

  static Future<void> boundComic(
      String name, String comicId, String boundId) async {
    if(comicId!=null&&boundId!=null){
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
