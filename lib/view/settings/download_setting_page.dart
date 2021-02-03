import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class DownloadSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DownloadSettingPage();
  }
}

class _DownloadSettingPage extends State<DownloadSettingPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).SettingPageMainDownloadTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(S.of(context).SettingPageSavePath),
            subtitle:
                Text('${Provider.of<SystemSettingModel>(context).savePath}'),
            onTap: () async {
              String result = await FilePicker.platform.getDirectoryPath();
              if (result != null) {
                Provider.of<SystemSettingModel>(context, listen: false)
                    .savePath = result;
              }
            },
          ),
          ListTile(
            title: Text(S.of(context).SettingPageNoMediaTitle),
            subtitle: Text(S.of(context).SettingPageNoMediaSubtitle),
            trailing: Switch(
              value: Provider.of<SystemSettingModel>(context).noMedia,
              onChanged: (value) async {
                Provider.of<SystemSettingModel>(context, listen: false)
                    .noMedia = value;
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text(S.of(context).SettingPageDownloadTaskListTitle),
            subtitle: Text(S.of(context).SettingPageDownloadTaskListSubtitle),
            onTap: () async {
              final tasks = await FlutterDownloader.loadTasks();
              showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text(
                          S.of(context).SettingPageDownloadTaskListDetailTitle),
                      titlePadding: EdgeInsets.all(10),
                      children: tasks
                          .map<Widget>((e) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          child: Text('${e.status.value}'),
                        ),
                        title: Text('${e.taskId}'),
                        subtitle: Text('${e.url}'),
                        trailing: Text('${e.progress}%'),
                        onTap: () async {
                          if (!await FlutterDownloader.open(
                              taskId: e.taskId)) {
                            Toast.show(
                                S
                                    .of(context)
                                    .SettingPageDownloadTaskListOpenFailed,
                                context,
                                duration: Toast.LENGTH_LONG);
                          }
                        },
                        onLongPress: () {},
                      ))
                          .toList(),
                    );
                  });
            },
          ),
          ListTile(
            title: Text(S.of(context).SettingPageCancelDownloadTasksTitle),
            subtitle:
                Text(S.of(context).SettingPageCancelDownloadTasksSubtitle),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(S
                          .of(context)
                          .SettingPageCancelDownloadTasksConfirmTitle),
                      content: Text(S
                          .of(context)
                          .SettingPageCancelDownloadTasksConfirmDescription),
                      actions: [
                        FlatButton(
                          child: Text(S.of(context).Cancel),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text(S.of(context).Confirm),
                          onPressed: () {
                            print('class: SettingPage, action: cancelTasks');
                            FlutterDownloader.cancelAll();
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}
