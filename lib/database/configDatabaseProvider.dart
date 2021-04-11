import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/database/databaseCommon.dart';
import 'package:flutterdmzj/utils/log_output.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

abstract class ConfigDatabaseProvider {
  String get name;

  Database _database;
  Logger logger = Logger(
      filter: ReleaseFilter(),
      printer: PrettyPrinter(),
      output: ConsoleLogOutput());

  Future<Database> get db async {
    if (_database == null) {
      _database = await DatabaseCommon.initDatabase();
    }
    return _database;
  }

  Future<void> insert<T>(String configName, dynamic configValue) async {
    var batch = (await db).batch();
    batch.delete("configures", where: "key='$name.$configName'");
    switch (T) {
      case String:
        batch.insert(
            "configures", {'key': '$name.$configName', 'value': configValue});
        break;
      case bool:
        batch.insert("configures",
            {'key': '$name.$configName', 'value': configValue ? '1' : '0'});
        break;
      default:
        batch.insert("configures",
            {'key': '$name.$configName', 'value': configValue.toString()});
        break;
    }
    await batch.commit();
  }

  Future get<T>(String configName, {dynamic defaultValue}) async {
    var batch = (await db).batch();
    batch.query("configures", where: "key='$name.$configName'");
    var result = await batch.commit();
    try {
      switch (T) {
        case String:
          return result.first[0]['value'].toString();
        case bool:
          return result.first[0]['value'] == '1';
        case int:
          return int.parse(result.first[0]['value']);
        case double:
          return double.parse(result.first[0]['value']);
        default:
          return result.first[0]['value'];
      }
    } catch (e) {
      logger.w(
          'action: configGetFailed, name: $name, configName: $configName, exception: $e');
    }
    return defaultValue;
  }
}

class IPFSConfigDatabaseProvider extends ConfigDatabaseProvider {
  @override
  // TODO: implement name
  String get name => 'ipfs';

  Future<int> get mode async => await get<int>('mode', defaultValue: 0);

  set mode(Future<int> mode) {
    mode.then((value) => insert('mode', value));
  }

  Future<String> get server async =>
      await get<String>('server', defaultValue: '127.0.0.1');

  set server(Future<String> server) {
    server.then((value) => insert('server', value));
  }

  Future<int> get port async => await get<int>('port', defaultValue: 5001);

  set port(Future<int> port) {
    port.then((value) => insert('port', value));
  }

  Future<bool> get enableProxy async =>
      await get<bool>('enable_proxy', defaultValue: false);

  set enableProxy(Future<bool> enableProxy) {
    enableProxy.then((value) => insert<bool>('enable_proxy', value));
  }

  Future<String> get proxyServer async =>
      await get<String>('proxy_server', defaultValue: '127.0.0.1');

  set proxyServer(Future<String> proxyServer) {
    proxyServer.then((value) => insert('proxy_server', value));
  }

  Future<int> get proxyPort async =>
      await get<int>('proxy_port', defaultValue: 0);

  set proxyPort(Future<int> proxyPort) {
    proxyPort.then((value) => insert('proxy_port', value));
  }
}

class ViewerConfigDatabaseProvider extends ConfigDatabaseProvider {
  @override
  // TODO: implement name
  String get name => 'viewer';

  Future<bool> get readDirection async =>
      await get<bool>('read_direction', defaultValue: false);

  set readDirection(Future<bool> readDirection) {
    readDirection.then((value) => insert<bool>('read_direction', value));
  }

  Future<double> get hitBox async =>
      await get<double>('hit_box', defaultValue: 100.toDouble());

  set hitBox(Future<double> hitBox) {
    hitBox.then((value) => insert<double>('hit_box', value));
  }

  Future<double> get range async =>
      await get<double>('range', defaultValue: 500.toDouble());

  set range(Future<double> range) {
    range.then((value) => insert<double>('range', value));
  }

  Future<int> get backgroundColor async =>
      await get<int>('background_color', defaultValue: 0);

  set backgroundColor(Future<int> backgroundColor) {
    backgroundColor.then((value) => insert<int>('background_color', value));
  }

  Future<bool> get readHorizontalDirection async =>
      await get('horizontal_direction', defaultValue: false);

  set readHorizontalDirection(Future<bool> readHorizontalDirection) {
    readHorizontalDirection
        .then((value) => insert<bool>('horizontal_direction', value));
  }

  Future<bool> get enableAnimation async =>
      await get<bool>('enable_animation', defaultValue: true);

  set enableAnimation(Future<bool> enableAnimation) {
    enableAnimation.then((value) => insert<bool>('enable_animation', value));
  }

  Future<bool> get autoDark async =>
      await get<bool>('auto_dark', defaultValue: false);

  set autoDark(Future<bool> autoDark) {
    autoDark.then((value) => insert<bool>('auto_dark', value));
  }
}

class SystemConfigDatabaseProvider extends ConfigDatabaseProvider {
  @override
  // TODO: implement name
  String get name => 'system';

  Future<bool> get labState async =>
      await get<bool>('lab_state', defaultValue: false);

  set labState(Future<bool> labState) {
    labState.then((value) => insert<bool>('lab_state', value));
  }

  Future<bool> get deepSearch async =>
      await get<bool>('deep_search', defaultValue: false);

  set deepSearch(Future<bool> deepSearch) {
    deepSearch.then((value) => insert<bool>('deep_search', value));
  }

  Future<bool> get darkSide async =>
      await get<bool>('dark_side', defaultValue: false);

  set darkSide(Future<bool> darkSide) {
    darkSide.then((value) => insert<bool>('dark_side', value));
  }

  Future<bool> get blackBox async =>
      await get<bool>('black_box', defaultValue: false);

  set blackBox(Future<bool> blackBox) {
    blackBox.then((value) => insert('black_box', value));
  }

  Future<int> get darkMode async =>
      await get<int>('dark_mode', defaultValue: 0);

  set darkMode(Future<int> darkMode) {
    darkMode.then((value) => insert<int>('dark_mode', value));
  }

  Future<int> get updateChannel async =>await get<int>('update_channel',defaultValue: 0);

  set updateChannel(Future<int> updateChannel){
    updateChannel.then((value) => insert<int>('update_channel', value));
  }

  Future<String> get latestVersion async =>
      await get<String>('latest_version', defaultValue: '');

  set latestVersion(Future<String> latestVersion) {
    latestVersion.then((value) => insert('latest_version', value));
  }

  Future<bool> get backupApi async=> await get<bool>('backup_api',defaultValue: false);

  set backupApi(Future<bool> backupApi){
    backupApi.then((value) => insert<bool>('backup_api', value));
  }

  Future<bool> get novelState async =>await get<bool>('novel_state',defaultValue: false);

  set novelState(Future<bool> novelState){
    novelState.then((value) => insert<bool>('novel_state', value));
  }

  Future<String> get downloadPath async => await get<String>('download_path',defaultValue: (await getExternalStorageDirectory()).path);

  set downloadPath(Future<String> downloadPath){
    downloadPath.then((value) => insert<String>('download_path', value));
  }
}
