import 'package:dcomic/database/databaseCommon.dart';
import 'package:dcomic/utils/log_output.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';


class DataBase {
  Database _database;
  Logger _logger;

  DataBase() {
    _logger = Logger(printer: PrettyPrinter(), output: ConsoleLogOutput());
  }

  initDataBase() async {
    _database = await DatabaseCommon.initDatabase();
  }

  resetDataBase() async {
    await deleteDatabase("dmzj_2.db");
  }

  @Deprecated('用新实现方案')
  insertCookies(String key, String value) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("cookies", where: "key='$key'");
    batch.insert("cookies", {"key": key, "value": value});
    await batch.commit();
  }

  @Deprecated('用新实现方案')
  getCookies() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("cookies");
    return await batch.commit();
  }

  @Deprecated('和local_history冲突，应该废弃')
  insertHistory(String comicId, String chapterId) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("history", where: "name='$comicId'");
    batch.insert("history", {"name": comicId, "value": chapterId});
    await batch.commit();
  }

  @Deprecated('改为新模式')
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

  @Deprecated('改为新模式')
  getReadHistory() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("local_history");
    return batch.commit();
  }

  @Deprecated('和local_history冲突，应该废弃')
  getHistory(String comicId) async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("history", where: "name='$comicId'");
    var data = await batch.commit();
    try {
      return data.first[0]['value'];
    } catch (e) {
      return '';
    }
  }

  @Deprecated('改为新模式')
  insertUnread(String comicId, int timestamp) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("unread", where: "comicId='$comicId'");
    batch.insert('unread', {'comicId': comicId, 'timestamp': timestamp});
    await batch.commit();
  }

  @Deprecated('改为新模式')
  getUnread(String comicId) async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("unread", where: "comicId='$comicId'");
    var data = await batch.commit();
    return data.first;
  }

  @Deprecated('改为新模式')
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

  @Deprecated('没用的接口')
  getMy() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("cookies", where: "key=my");
    var result = await batch.commit();
    return result.first;
  }

  @Deprecated('改用其他设计')
  setLoginState(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='login'");
    batch.insert("configures", {'key': 'login', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  @Deprecated('改用其他设计')
  setUid(String uid) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='uid'");
    batch.insert("configures", {'key': 'uid', 'value': uid});
    await batch.commit();
  }

  @Deprecated('改用其他设计')
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

  @Deprecated('改用其他设计')
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

  @Deprecated('')
  setReadDirection(bool d) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='read_direction'");
    batch.insert(
        "configures", {'key': 'read_direction', 'value': d ? '1' : '0'});
    await batch.commit();
  }

  @Deprecated('')
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

  @Deprecated('修改viewer实现，已弃用')
  setCoverType(bool d) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='cover_type'");
    batch.insert("configures", {'key': 'cover_type', 'value': d ? '1' : '0'});
    await batch.commit();
  }

  @Deprecated('修改viewer实现，已弃用')
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

  @Deprecated('使用新实现方案，已弃用')
  setVersion(String version) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='latest_version'");
    batch.insert("configures", {'key': 'latest_version', 'value': version});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
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

  @Deprecated('修改viewer实现，已弃用')
  setClickToRead(bool click) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='read_click'");
    batch.insert(
        "configures", {'key': 'read_click', 'value': click ? '1' : '0'});
    await batch.commit();
  }

  @Deprecated('修改viewer实现，已弃用')
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

  @Deprecated('使用新实现方案，已弃用')
  setControlSize(double size) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='control_size'");
    batch.insert(
        "configures", {'key': 'control_size', 'value': size.toString()});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
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

  @Deprecated('使用新实现方案，已弃用')
  setRange(double range) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='range'");
    batch.insert("configures", {'key': 'range', 'value': range.toString()});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
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

  @Deprecated('使用新实现方案，已弃用')
  setLabState(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='lab_state'");
    batch
        .insert("configures", {'key': 'lab_state', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
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

  @Deprecated('使用新实现方案，已弃用')
  setDeepSearch(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='deep_search'");
    batch.insert(
        "configures", {'key': 'deep_search', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
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

  @Deprecated('使用新实现方案，已弃用')
  setDarkSide(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='dark_side'");
    batch
        .insert("configures", {'key': 'dark_side', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
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

  @Deprecated('使用新实现方案，已弃用')
  setBlackBox(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='black_box'");
    batch
        .insert("configures", {'key': 'black_box', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
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

  @Deprecated('使用新实现方案，已弃用')
  setDownloadPath(String path) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='download_path'");
    batch.insert("configures", {'key': 'download_path', 'value': path});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
  getDownloadPath() async {
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

  @Deprecated('使用新实现方案，已弃用')
  setDarkMode(int mode) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='dark_mode'");
    batch.insert("configures", {'key': 'dark_mode', 'value': mode.toString()});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
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
  @Deprecated('使用新实现方案，已弃用')
  setBackground(int mode) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='background_color'");
    batch.insert("configures", {'key': 'background_color', 'value': mode.toString()});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
  Future<int> getBackground() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='background_color'");
    var result = await batch.commit();
    try {
      return int.parse(result.first[0]['value']);
    } catch (e) {
      _logger.w('action: darkModeNotFound, exception: $e');
    }
    return 0;
  }

  @Deprecated('使用新实现方案，已弃用')
  setHorizontalDirection(bool direction) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='horizontal_direction'");
    batch.insert("configures",
        {'key': 'horizontal_direction', 'value': direction ? '1' : '0'});
    await batch.commit();
  }
  @Deprecated('使用新实现方案，已弃用')
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

  @Deprecated('使用新实现方案，已弃用')
  Future<bool> getNovelState() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='novel_state'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      _logger.w('action: NovelStateNotFound, exception: $e');
    }
    return false;
  }

  @Deprecated('使用新实现方案，已弃用')
  Future<void> setNovelState(bool novel) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='novel_state'");
    batch.insert(
        "configures", {'key': 'novel_state', 'value': novel ? '1' : '0'});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
  Future<bool> getBackupApi() async{
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='backup_api'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      _logger.w('action: BackupApiNotFound, exception: $e');
    }
    return false;
  }

  @Deprecated('使用新实现方案，已弃用')
  Future<void> setBackupApi(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='backup_api'");
    batch.insert(
        "configures", {'key': 'backup_api', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  Future<bool> getWebApi()async{
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='web_api'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      _logger.w('action: WebApiNotFound, exception: $e');
    }
    return false;
  }

  Future<void> setWebApi(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='web_api'");
    batch.insert(
        "configures", {'key': 'web_api', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
  Future<int> getUpdateChannel()async{
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='update_channel'");
    var result = await batch.commit();
    try {
      return int.parse(result.first[0]['value']);
    } catch (e) {
      _logger.w('action: updateChannelNotFound, exception: $e');
    }
    return 0;
  }

  @Deprecated('使用新实现方案，已弃用')
  setUpdateChannel(int channel) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='update_channel'");
    batch.insert("configures", {'key': 'update_channel', 'value': channel.toString()});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
  setAnimation(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='animation'");
    batch.insert(
        "configures", {'key': 'animation', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
  getAnimation() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='animation'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '0') {
        return false;
      }
    } catch (e) {
      _logger.w('action: deepSearchNotFound, exception: $e');
    }
    return true;
  }

  @Deprecated('使用新实现方案，已弃用')
  setAutoDark(bool state) async {
    await initDataBase();
    var batch = _database.batch();
    batch.delete("configures", where: "key='auto_dark'");
    batch.insert(
        "configures", {'key': 'auto_dark', 'value': state ? '1' : '0'});
    await batch.commit();
  }

  @Deprecated('使用新实现方案，已弃用')
  getAutoDark() async {
    await initDataBase();
    var batch = _database.batch();
    batch.query("configures", where: "key='auto_dark'");
    var result = await batch.commit();
    try {
      if (result.first[0]['value'] == '1') {
        return true;
      }
    } catch (e) {
      _logger.w('action: autoDarkNotFound, exception: $e');
    }
    return false;
  }

}
