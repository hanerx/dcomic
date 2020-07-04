import 'package:sqflite/sqflite.dart';

class DataBase {
  Database _database;

  DataBase();

  initDataBase() async {
    _database = await openDatabase("dmzj_2.db", version: 5,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE cookies (id INTEGER PRIMARY KEY, key TEXT, value TEXT)");
      await db.execute(
          "CREATE TABLE configures (id INTEGER PRIMARY KEY, key TEXT, value TEXT)");
      await db.execute(
          "CREATE TABLE history (id INTEGER PRIMARY KEY, name TEXT, value TEXT)");
      await db.execute(
          "CREATE TABLE unread (id INTEGER PRIMARY KEY, comicId TEXT, timestamp INTEGER)");
    }, onUpgrade: (Database db, int version, int x) async {

    });
  }

  resetDataBase() async {
    await deleteDatabase("dmzj_2.db");
  }

  insertCookies(String key, String value) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("cookies", where: "key='$key'");
    batch.insert("cookies", {"key": key, "value": value});
    await batch.commit();
  }

  getCookies() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("cookies");
    return await batch.commit();
  }

  insertHistory(String comicId, String chapterId) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("history", where: "name='$comicId'");
    batch.insert("history", {"name": comicId, "value": chapterId});
    await batch.commit();
  }


  getHistory(String comicId) async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("history", where: "name='$comicId'");
    return batch.commit();
  }

  insertUnread(String comicId, int timestamp) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("unread", where: "comicId='$comicId'");
    batch.insert('unread', {'comicId': comicId, 'timestamp': timestamp});
    await batch.commit();
  }

  getUnread(String comicId) async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("unread", where: "comicId='$comicId'");
    var data = await batch.commit();
    return data.first;
  }

  getAllUnread() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("unread");
    var data = await batch.commit();
    var map = <String, int>{};
    for (var item in data.first) {
      map[item['comicId']] = item['timestamp'];
    }
    return map;
  }

  getMy() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("cookies", where: "key=my");
    var result = await batch.commit();
    return result.first;
  }

  setLoginState(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='login'");
    batch.insert("configures", {'key': 'login', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  setUid(String uid) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='uid'");
    batch.insert("configures", {'key': 'uid', 'value': uid});
    await batch.commit();
  }

  getUid() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='uid'");
    var result = await batch.commit();
    try {
      return result.first[0]['value'];
    } catch (e) {
      print(e);
    }
    return '';
  }

  getLoginState() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='login'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  setReadDirection(bool d) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='read_direction'");
    batch.insert("configures", {'key': 'read_direction', 'value': d ? '1' : '0'});
    await batch.commit();
  }

  getReadDirection() async{
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='read_direction'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      print('!');
      print(e);
    }
    return false;
  }

  setCoverType(bool d) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='cover_type'");
    batch.insert("configures", {'key': 'cover_type', 'value': d ? '1' : '0'});
    await batch.commit();
  }

  getCoverType() async{
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='cover_type'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      print('!');
      print(e);
    }
    return false;
  }

  setVersion(String version) async{
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='latest_version'");
    batch.insert("configures", {'key': 'latest_version', 'value': version});
    await batch.commit();
  }

  getVersion() async{
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='latest_version'");
    var result = await batch.commit();
    try {
      return result.first[0]['value'];
    } catch (e) {
      print('!');
      print(e);
    }
    return '';
  }

  setClickToRead(bool click) async{
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='read_click'");
    batch.insert("configures", {'key': 'read_click', 'value': click ? '1' : '0'});
    await batch.commit();
  }

  getClickToRead() async{
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='read_click'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      print('!');
      print(e);
    }
    return false;
  }

  setControlSize(double size) async{
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='control_size'");
    batch.insert("configures", {'key': 'control_size', 'value': size.toString()});
    await batch.commit();
  }

  getControlSize() async{
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='control_size'");
    var result = await batch.commit();
    try {
      return double.parse(result.first[0]['value']);
    } catch (e) {
      print('!');
      print(e);
    }
    return 100.0.toDouble();
  }

  setViewFraction(double viewFraction)async{
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='view_fraction'");
    batch.insert("configures", {'key': 'view_fraction', 'value': viewFraction.toString()});
    await batch.commit();
  }

  getViewFraction() async{
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='view_fraction'");
    var result = await batch.commit();
    try {
      return double.parse(result.first[0]['value']);
    } catch (e) {
      print('!');
      print(e);
    }
    return 0.9.toDouble();
  }
}
