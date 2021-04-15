import 'package:dcomic/database/databaseCommon.dart';
import 'package:dcomic/utils/log_output.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

class HistoryDatabaseProvider {
  final String name;

  Database _database;
  Logger logger = Logger(
      filter: ReleaseFilter(),
      printer: PrettyPrinter(),
      output: ConsoleLogOutput());

  HistoryDatabaseProvider(this.name);

  Future<Database> get db async {
    if (_database == null) {
      _database = await DatabaseCommon.initDatabase();
    }
    return _database;
  }

  Future<void> addReadHistory(String comicId, String title, String cover,
      String lastChapter, String lastChapterId, int timestamp) async {
    var batch = (await db).batch();
    batch.delete('local_history',
        where: "comicId = ? AND provider = ?", whereArgs: [comicId, name]);
    batch.insert("local_history", {
      'comicId': comicId,
      'title': title,
      'cover': cover,
      'last_chapter': lastChapter,
      'last_chapter_id': lastChapterId,
      'timestamp': timestamp,
      'provider': name
    });
    await batch.commit();
  }

  Future<List> getReadHistories() async {
    var batch = (await db).batch();
    batch.query("local_history", where: 'provider = ?', whereArgs: [name]);
    return await batch.commit();
  }

  Future<Map> getReadHistory(String comicId) async {
    try{
      var batch = (await db).batch();
      batch.query("local_history",
          where: 'comicId = ? AND provider = ?', whereArgs: [comicId, name]);
      var data=(await batch.commit()).first;
      return data[0];
    }catch(e){

    }
    return null;
  }

  Future<void> addUnread(String comicId, int timestamp) async {
    var batch = (await db).batch();
    batch.delete("unread",
        where: "comicId = ? AND provider = ?", whereArgs: [comicId, name]);
    batch.insert('unread',
        {'comicId': comicId, 'timestamp': timestamp, 'provider': name});
    await batch.commit();
  }

  Future<Map> getUnread(String comicId) async {
    var batch = (await db).batch();
    batch.query('unread',
        where: 'comicId = ? AND provider = ?', whereArgs: [comicId, name]);
    return (await batch.commit()).first;
  }

  Future<List> getAllUnread() async {
    var batch = (await db).batch();
    batch.query('unread', where: 'provider = ?', whereArgs: [name]);
    return await batch.commit();
  }
}
