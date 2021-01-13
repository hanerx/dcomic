import 'package:sqflite/sqflite.dart';

class DatabaseCommon{
  static Future<Database> initDatabase()async{
    return await openDatabase("dmzj_2.db", version: 12,
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE cookies (id INTEGER PRIMARY KEY, key TEXT, value TEXT)");
          await db.execute(
              "CREATE TABLE configures (id INTEGER PRIMARY KEY, key TEXT, value TEXT)");
          await db.execute(
              "CREATE TABLE history (id INTEGER PRIMARY KEY, name TEXT, value TEXT)");
          await db.execute(
              "CREATE TABLE unread (id INTEGER PRIMARY KEY, comicId TEXT, timestamp INTEGER)");
          await db.execute(
              "CREATE TABLE local_history (id INTEGER PRIMARY KEY, comicId TEXT, timestamp INTEGER,cover TEXT,title TEXT,last_chapter TEXT,last_chapter_id TEXT)");
          await db.execute(
              "CREATE TABLE download_comic_info (id INTEGER PRIMARY KEY, comicId TEXT, cover TEXT, title TEXT)");
          await db.execute(
              "CREATE TABLE download_chapter_info (id INTEGER PRIMARY KEY, comicId TEXT, chapterId TEXT, tasks TEXT, title TEXT, data TEXT)");
          await db.execute('CREATE TABLE tracking_comic_info (id INTEGER PRIMARY KEY, comicId TEXT, title TEXT, cover TEXT)');
        }, onUpgrade: (Database db, int version, int x) async {
          print('class: DataBase, action: upgrade, version: $version');
          await db.execute('CREATE TABLE tracking_comic_info (id INTEGER PRIMARY KEY, comicId TEXT, title TEXT, cover TEXT, data TEXT)');
        });
  }
}