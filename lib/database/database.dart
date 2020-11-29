import 'package:flutterdmzj/utils/log_output.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataBase {
  Database _database;
  Logger _logger;

  DataBase(){
    _logger=Logger(
      printer: PrettyPrinter(),
      output: ConsoleLogOutput()
    );
  }

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
      await db.execute("CREATE TABLE download_comic_info (id INTEGER PRIMARY KEY, comicId TEXT, cover TEXT, title TEXT)");
      await db.execute("CREATE TABLE download_chapter_info (id INTEGER PRIMARY KEY, comicId TEXT, chapterId TEXT, tasks TEXT, title TEXT)");
    }, onUpgrade: (Database db, int version, int x) async {
      print('class: DataBase, action: upgrade, version: $version');
      await db.execute("CREATE TABLE download_comic_info (id INTEGER PRIMARY KEY, comicId TEXT, cover TEXT, title TEXT)");
      await db.execute("CREATE TABLE download_chapter_info (id INTEGER PRIMARY KEY, comicId TEXT, chapterId TEXT, tasks TEXT, title TEXT)");
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

  addReadHistory(String comicId, String title, String cover, String lastChapter,
      String lastChapterId, int timestamp) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete('local_history', where: "comicId='$comicId'");
    batch.insert("local_history", {
      'comicId': comicId,
      'title': title,
      'cover': cover,
      'last_chapter': lastChapter,
      'last_chapter_id': lastChapterId,
      'timestamp': timestamp
    });
    await batch.commit();
  }

  getReadHistory() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("local_history");
    return batch.commit();
  }

  getHistory(String comicId) async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("history", where: "name='$comicId'");
    var data=await batch.commit();
    try{
      return data.first[0]['value'];
    }catch(e){
      return '';
    }
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
      _logger.w('action: uidNotFound, exception: $e');
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
      _logger.w('action: loginStateNotFound, exception: $e');
    }
    return false;
  }

  setReadDirection(bool d) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='read_direction'");
    batch.insert(
        "configures", {'key': 'read_direction', 'value': d ? '1' : '0'});
    await batch.commit();
  }

  getReadDirection() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='read_direction'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      _logger.w('action: readDirectionNotFound, exception: $e');
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

  getCoverType() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='cover_type'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      _logger.w('action: coverTypeNotFound, exception: $e');
    }
    return false;
  }

  setVersion(String version) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='latest_version'");
    batch.insert("configures", {'key': 'latest_version', 'value': version});
    await batch.commit();
  }

  getVersion() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='latest_version'");
    var result = await batch.commit();
    try {
      return result.first[0]['value'];
    } catch (e) {
      _logger.w('action: versionNotFound, exception: $e');
    }
    return '';
  }

  setClickToRead(bool click) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='read_click'");
    batch.insert(
        "configures", {'key': 'read_click', 'value': click ? '1' : '0'});
    await batch.commit();
  }

  getClickToRead() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='read_click'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      _logger.w('action: clickToReadNotFound, exception: $e');
    }
    return false;
  }

  setControlSize(double size) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='control_size'");
    batch.insert(
        "configures", {'key': 'control_size', 'value': size.toString()});
    await batch.commit();
  }

  getControlSize() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='control_size'");
    var result = await batch.commit();
    try {
      return double.parse(result.first[0]['value']);
    } catch (e) {
      _logger.w('action: controlSizeNotFound, exception: $e');
    }
    return 100.0.toDouble();
  }

  setRange(double range) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='range'");
    batch.insert("configures", {'key': 'range', 'value': range.toString()});
    await batch.commit();
  }

  getRange() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='range'");
    var result = await batch.commit();
    try {
      return double.parse(result.first[0]['value']);
    } catch (e) {
        _logger.w('action: rangeNotFound, exception: $e');
    }
    return 500.toDouble();
  }

  setLabState(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='lab_state'");
    batch
        .insert("configures", {'key': 'lab_state', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  getLabState() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='lab_state'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      _logger.w('action: labStateNotFound, exception: $e');
    }
    return false;
  }

  setDeepSearch(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='deep_search'");
    batch.insert(
        "configures", {'key': 'deep_search', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  getDeepSearch() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='deep_search'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      _logger.w('action: deepSearchNotFound, exception: $e');
    }
    return false;
  }

  setDarkSide(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='dark_side'");
    batch
        .insert("configures", {'key': 'dark_side', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  getDarkSide() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='dark_side'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      _logger.w('action: darkSideNotFound, exception: $e');
    }
    return false;
  }

  setBlackBox(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='black_box'");
    batch
        .insert("configures", {'key': 'black_box', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  getBlackBox() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='black_box'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      _logger.w('action: blackBoxNotFound, exception: $e');
    }
    return false;
  }

  setDownloadPath(String path) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='download_path'");
    batch
        .insert("configures", {'key': 'download_path', 'value': path});
    await batch.commit();
  }

  getDownloadPath() async{
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='download_path'");
    var result = await batch.commit();
    try {
      return result.first[0]['value'];
    } catch (e) {
      _logger.w('action: downloadPathNotFound, exception: $e');
    }
    return (await getExternalStorageDirectory()).path;
  }

  setDarkMode(int mode) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='dark_mode'");
    batch.insert("configures", {'key': 'dark_mode', 'value': mode.toString()});
    await batch.commit();
  }

  Future<int> getDarkMode() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='dark_mode'");
    var result = await batch.commit();
    try {
      return int.parse(result.first[0]['value']);
    } catch (e) {
      _logger.w('action: darkModeNotFound, exception: $e');
    }
    return 0;
  }

  setHorizontalDirection(bool direction) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='horizontal_direction'");
    batch.insert("configures",
        {'key': 'horizontal_direction', 'value': direction ? '1' : '0'});
    await batch.commit();
  }

  Future<bool> getHorizontalDirection() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='horizontal_direction'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      _logger.w('action: horizontalDirectionNotFound, exception: $e');
    }
    return false;
  }
}
