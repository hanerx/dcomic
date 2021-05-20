import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:dcomic/database/configDatabaseProvider.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:package_info/package_info.dart';

class VersionModel extends BaseModel {
  // 更新通道
  int _updateChannel = 0;

  static const List<String> channels = ['release', 'beta'];

  String _latestVersion = '0.0.1';
  String _currentVersion = '0.0.1';
  String _localLatestVersion = '0.0.1';

  VersionModel() {
    init();
  }

  Future<void> init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;
    SystemConfigDatabaseProvider databaseProvider =
        SystemConfigDatabaseProvider();
    _localLatestVersion = await databaseProvider.latestVersion;
    _updateChannel = await databaseProvider.updateChannel;
    if (_localLatestVersion == '' ||
        ToolMethods.checkVersionSemver(_localLatestVersion, _currentVersion)) {
      _localLatestVersion = _currentVersion;
    }
    await checkUpdate();
    logger.i(
        'class: VersionModel, action: init, latestVersion: $latestVersion, currentVersion: $currentVersion, localLatestVersion: $localLatestVersion');
    notifyListeners();
  }

  Future<void> checkUpdate() async {
    try {
      switch (_updateChannel) {
        case 0:
          var response = await UniversalRequestModel.githubRequestHandler.getLatestRelease();
          if (response.statusCode == 200||response.statusCode==304) {
            _latestVersion = response.data['tag_name'].substring(1);
          }
          break;
        case 1:
          var response = await UniversalRequestModel.githubRequestHandler.getReleases();
          if (response.statusCode == 200||response.statusCode==304) {
            _latestVersion = response.data.first['tag_name'].substring(1);
          }
          break;
      }
      notifyListeners();
    } catch (e,s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'checkUpdateFailed');
      logger.e('class: VersionModel, action: checkUpdateFailed, exception: $e');
    }
  }

  void showUpdateDialog(context) async {
    String tagName;
    String body;
    String htmlUrl;
    String downloadUrl;
    switch (_updateChannel) {
      case 0:
        var response = await UniversalRequestModel.githubRequestHandler.getLatestRelease();
        tagName = response.data['tag_name'];
        body = response.data['body'];
        htmlUrl = response.data['html_url'];
        if (response.data['assets'].length > 0) {
          downloadUrl = response.data['assets'][0]['browser_download_url'];
        }
        break;
      case 1:
        var response = await UniversalRequestModel.githubRequestHandler.getReleases();
        tagName = response.data.first['tag_name'];
        body = response.data.first['body'];
        htmlUrl = response.data.first['html_url'];
        if (response.data.first['assets'].length > 0) {
          downloadUrl =
              response.data.first['assets'][0]['browser_download_url'];
        }
        break;
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('版本点亮：$tagName'),
            content: Container(
              width: 300,
              height: 300,
              child: MarkdownWidget(data: body),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('打开网页'),
                onPressed: () {
                  ToolMethods.callWeb('$htmlUrl', context);
                },
              ),
              FlatButton(
                child: Text('更新'),
                onPressed: () async {
                  if (downloadUrl != null) {
                    var downloadPath =
                        await SystemConfigDatabaseProvider().downloadPath;
                    FlutterDownloader.enqueue(
                        url: downloadUrl, savedDir: '$downloadPath');
                    Navigator.pop(context);
                  } else {
                    ToolMethods.callWeb('$htmlUrl', context);
                  }
                },
              ),
              FlatButton(
                child: Text('镜像更新'),
                onPressed: () async {
                  if (downloadUrl != null) {
                    var downloadPath =
                        await SystemConfigDatabaseProvider().downloadPath;
                    FlutterDownloader.enqueue(
                        url:
                            'https://divine-boat-417a.hanerx.workers.dev/$downloadUrl',
                        savedDir: '$downloadPath');
                    Navigator.pop(context);
                  } else {
                    ToolMethods.callWeb('$htmlUrl', context);
                  }
                },
              ),
              FlatButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  int get updateChannel => _updateChannel;

  String get updateChannelName =>
      _updateChannel < channels.length ? channels[_updateChannel] : '未知通道';

  set updateChannel(int channel) {
    if (0 <= channel && channel < channels.length) {
      _updateChannel = channel;
    } else {
      _updateChannel = 0;
    }
    SystemConfigDatabaseProvider().updateChannel = Future.value(_updateChannel);
    notifyListeners();
  }

  String get localLatestVersion => _localLatestVersion;

  set localLatestVersion(String version) {
    SystemConfigDatabaseProvider().latestVersion = Future.value(version);
    _localLatestVersion = version;
    notifyListeners();
  }

  String get currentVersion => _currentVersion;

  String get latestVersion => _latestVersion;
}
