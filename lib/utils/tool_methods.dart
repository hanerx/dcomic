import 'dart:isolate';
import 'dart:ui';

class ToolMethods {
  static String formatTimestamp(int timestamp) {
    var dateTime = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000000);
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  static bool checkVersion(String version, String lastVersion) {
    var list1 = version.split(".");
    List list2 = lastVersion.split(".");
    int i = 0;
    if (list1.length == list2.length) {
      for (var item in list1) {
        if (int.parse(item) < int.parse(list2[i])) {
          return true;
        }
        i++;
      }
    }
    return false;
  }

  static void downloadCallback(id, status, progress) {
    print(
        "class: ToolMethod, action: downloadCallback, taskId: $id, status: $status, progress: $progress");
    try {
      final SendPort send =
          IsolateNameServer.lookupPortByName('downloader_send_port');
      send.send([id, status, progress]);
    } catch (e) {
      print('class: ToolMethod, action: downloadCallbackFailed, exception: $e');
    }
  }
}
