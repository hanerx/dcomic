import 'dart:convert';

import 'package:dcomic/database/databaseCommon.dart';
import 'package:sqflite/sqflite.dart';

class TracingComic {
  int id;
  String comicId;
  String title;
  String cover;
  Map data;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'comicId': comicId,
      'cover': cover,
      'data': jsonEncode(data),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  TracingComic();

  TracingComic.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    comicId = map['comicId'];
    cover = map['cover'];
    data = jsonDecode(map['data']);
  }

  @override
  String toString() {
    return 'Comic{id: $id, title: $title, comicId: $comicId, cover: $cover, data: $data}';
  }
}

class TrackerProvider {
  Database _database;

  initDataBase() async {
    _database = await DatabaseCommon.initDatabase();
  }

  Future<TracingComic> insertComic(TracingComic comic) async {
    await initDataBase();
    comic.id = await _database.insert('tracking_comic_info', comic.toMap());
    return comic;
  }

  Future<TracingComic> getComic(String comicId) async {
    await initDataBase();
    List<Map> maps = await _database.query('tracking_comic_info',
        where: 'comicId = ?', whereArgs: [comicId]);
    if (maps.length > 0) {
      _database.close();
      return TracingComic.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TracingComic>> getAllComic() async {
    await initDataBase();
    List<Map> maps = await _database.query('tracking_comic_info');
    List<TracingComic> data = [];
    for (var item in maps) {
      data.add(TracingComic.fromMap(item));
    }
    return data;
  }

  Future<int> deleteComic(String comicId)async{
    await initDataBase();
    return await _database.delete('tracking_comic_info',where: 'comicId=?',whereArgs: [comicId]);
  }
}
