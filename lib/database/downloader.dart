import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:sqflite/sqflite.dart';

class Chapter {
  int id;
  String title;
  String comicId;
  String chapterId;
  List<String> tasks;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'comicId': comicId,
      'chapterId': chapterId,
      'tasks': tasks.join(',')
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Chapter();

  Chapter.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    chapterId = map['chapterId'];
    comicId = map['comicId'];
    tasks = map['tasks'].split(',');
  }

  Future<int> get progress async {
    int progress=0;
    for(var item in tasks){
      var task=await FlutterDownloader.loadTasksWithRawQuery(query: 'SELECT * FROM task WHERE task_id="$item"');
      if(task.length>0){
        progress+=task[0].progress;
      }
    }
    return progress;
  }

  Future<List<String>> get paths async{
    List<String> paths=[];
    for(var item in tasks){
      var task=await FlutterDownloader.loadTasksWithRawQuery(query: 'SELECT * FROM task WHERE task_id="$item"');
      if(task.length>0){
        paths.add('${task[0].savedDir}/${task[0].filename}');
      }
    }
    return paths;
  }

  int get total => tasks == null ? 100 : tasks.length * 100;
}

class Comic {
  int id;
  String title;
  String comicId;
  String cover;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'comicId': comicId,
      'cover': cover
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Comic();

  Comic.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    comicId = map['comicId'];
    cover = map['cover'];
  }

  @override
  String toString() {
    return 'Comic{id: $id, title: $title, comicId: $comicId, cover: $cover}';
  }
}

class DownloadProvider {
  Database _database;

  initDataBase() async {
    _database = await openDatabase("dmzj_2.db", version: 11,
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
          "CREATE TABLE download_chapter_info (id INTEGER PRIMARY KEY, comicId TEXT, chapterId TEXT, tasks TEXT, title TEXT)");
    }, onUpgrade: (Database db, int version, int x) async {
      print('class: DataBase, action: upgrade, version: $version');
      await db.execute(
          "CREATE TABLE download_comic_info (id INTEGER PRIMARY KEY, comicId TEXT, cover TEXT, title TEXT)");
      await db.execute(
          "CREATE TABLE download_chapter_info (id INTEGER PRIMARY KEY, comicId TEXT, chapterId TEXT, tasks TEXT, title TEXT)");
    });
  }

  Future<Chapter> insertChapter(Chapter chapter) async {
    await initDataBase();
    chapter.id =
        await _database.insert('download_chapter_info', chapter.toMap());
    return chapter;
  }

  Future<Chapter> getChapter(String chapterId) async {
    await initDataBase();
    List<Map> maps = await _database.query('download_chapter_info',
        where: 'chapterId = ?', whereArgs: [chapterId]);
    if (maps.length > 0) {
      _database.close();
      return Chapter.fromMap(maps.first);
    }
    return null;
  }

  Future<Comic> insertComic(Comic comic) async {
    await initDataBase();
    comic.id = await _database.insert('download_comic_info', comic.toMap());
    return comic;
  }

  Future<Comic> getComic(String comicId) async {
    await initDataBase();
    List<Map> maps = await _database.query('download_comic_info',
        where: 'comicId = ?', whereArgs: [comicId]);
    if (maps.length > 0) {
      _database.close();
      return Comic.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Comic>> getAllComic() async {
    await initDataBase();
    List<Map> maps = await _database.query('download_comic_info');
    List<Comic> data = [];
    for (var item in maps) {
      data.add(Comic.fromMap(item));
    }
    return data;
  }

  Future<List<Chapter>> getAllChapter(String comicId) async {
    await initDataBase();
    List<Map> maps = await _database.query('download_chapter_info',
        where: 'comicId = ?', whereArgs: [comicId]);
    List<Chapter> data = [];
    for (var item in maps) {
      data.add(Chapter.fromMap(item));
    }
    return data;
  }
}
