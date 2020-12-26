import 'dart:isolate';
import 'dart:ui';

import 'package:flutterdmzj/utils/log_output.dart';
import 'package:logger/logger.dart';

class ToolMethods {
  static String formatTimestamp(int timestamp) {
    var dateTime = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000000);
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  static bool checkVersion(String version, String lastVersion) {
    var list1 = version.split(".");
    List list2 = lastVersion.split(".");
    if (list1.length == list2.length) {
      for(var i =0;i<list1.length;i++){
        if(int.parse(list1[i])==int.parse(list2[i])){
          continue;
        }else if(int.parse(list1[i])>int.parse(list2[i])){
          return true;
        }else{
          return false;
        }
      }
    }
    return false;
  }

  static void downloadCallback(id, status, progress) {
    var logger=Logger(
      printer: PrettyPrinter(),
      output: ConsoleLogOutput(),
    );
    logger.i("action: downloadCallback, taskId: $id, status: $status, progress: $progress");
    try {
      final SendPort send =
          IsolateNameServer.lookupPortByName('downloader_send_port');
      send.send([id, status, progress]);
    } catch (e) {
      logger.w('action: downloadCallbackFailed, exception: $e');
    }
  }
}
