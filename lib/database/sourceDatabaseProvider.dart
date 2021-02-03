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
}
