import 'package:flutterdmzj/database/databaseCommon.dart';
import 'package:flutterdmzj/utils/log_output.dart';
import 'package:logger/logger.dart';
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
