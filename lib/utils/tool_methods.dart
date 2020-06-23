

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

}
