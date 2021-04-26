import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/utils/log_output.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

class ToolMethods {
  static String formatTimestamp(int timestamp) {
    try {
      var dateTime = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000000);
      return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
    } catch (e) {
      return '1970-01-01';
    }
  }

  static int formatTimeString(String time) {
    return DateTime.parse(time).millisecondsSinceEpoch;
  }

  static int formatTimeStringForMangabz(String time) {
    if (time.contains('今天')) {
      return DateTime.now().millisecondsSinceEpoch;
    }
    if (time.contains('昨天')) {
      var dateTime = DateTime.now().add(Duration(days: -1));
      return dateTime.millisecondsSinceEpoch;
    }
    if (time.contains('前天')) {
      var dateTime = DateTime.now().add(Duration(days: -1));
      return dateTime.millisecondsSinceEpoch;
    }
    time = time.replaceAll(' 更新', '').replaceAll('月', '-').replaceAll('号', '');
    if (time.indexOf('-') != 4) {
      time = '${DateTime.now().year}-$time';
    }
    return formatTimeString(time);
  }

  static bool checkVersion(String version, String lastVersion) {
    var list1 = version.split(".");
    List list2 = lastVersion.split(".");
    if (list1.length == list2.length) {
      for (var i = 0; i < list1.length; i++) {
        if (int.parse(list1[i]) == int.parse(list2[i])) {
          continue;
        } else if (int.parse(list1[i]) > int.parse(list2[i])) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  static bool checkVersionSemver(
      String currentVersionString, String latestVersionString) {
    Version currentVersion = Version.parse(currentVersionString);
    Version latestVersion = Version.parse(latestVersionString);
    return latestVersion > currentVersion;
  }

  static Future<void> callWeb(String url, context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).CannotOpenWeb),
      ));
    }
  }

  static void downloadCallback(id, status, progress) {
    var logger = Logger(
      printer: PrettyPrinter(),
      output: ConsoleLogOutput(),
    );
    logger.i(
        "action: downloadCallback, taskId: $id, status: $status, progress: $progress");
    try {
      final SendPort send =
          IsolateNameServer.lookupPortByName('downloader_send_port');
      send.send([id, status, progress]);
    } catch (e) {
      logger.w('action: downloadCallbackFailed, exception: $e');
    }
  }

  static Future<String> eval(String eval,
      {String url: 'http://www.mangabz.com/'}) async {
    FlutterWebviewPlugin webView = FlutterWebviewPlugin();
    String data;
    webView.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        webView.evalJavascript(eval).then((value) {
          data = value;
        });
      }
    });
    await webView.launch(url, hidden: true);
    while (data == null) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    await webView.close();
    return data;
  }

  static Future<List<String>> evalList(List<String> codes,
      {String url: 'http://www.mangabz.com/'}) async {
    FlutterWebviewPlugin webView = FlutterWebviewPlugin();
    List<String> data = [];
    webView.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        for (var item in codes) {
          webView.evalJavascript(item).then((value) {
            data.add(value);
          });
        }
      }
    });
    await webView.launch(url, hidden: true);
    while (data.length < codes.length) {
      await Future.delayed(Duration(seconds: 1));
    }
    await webView.close();
    return data;
  }
}
