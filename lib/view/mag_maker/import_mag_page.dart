import 'package:dcomic/database/localMangaDatabaseProvider.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/model/ipfsSettingProvider.dart';
import 'package:dcomic/model/mag_model/baseMangaModel.dart';
import 'package:dcomic/model/systemSettingModel.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class ImportMagPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ImportMagPage();
  }
}

class _ImportMagPage extends State<ImportMagPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlutterEasyLoading(
        child: Scaffold(
      appBar: AppBar(
        title: Text('导入漫画'),
      ),
      body: Builder(
        builder: (context) => ListView(
          children: [
            TextButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.all(5))),
              child: Card(
                child: ListTile(
                  title: Text('本地导入'),
                  subtitle: Text('通过本地文件导入文件'),
                  leading: Icon(Icons.folder_open),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
              onPressed: () async {
                try {
                  EasyLoading.instance..maskType = EasyLoadingMaskType.black;
                  EasyLoading.showProgress(0, status: '开始导入');
                  var result = await FilePicker.platform
                      .pickFiles(type: FileType.any, withData: false);
                  String savePath =
                      Provider.of<SystemSettingModel>(context, listen: false)
                              .savePath +
                          "/manga/" +
                          result.files.single.name.split('.')[0];
                  MangaObject data = await BaseMangaModel().decodeFromPath(
                      result.files.single.path,
                      outputPath: savePath, callBack: (value, message) {
                    print(value);
                    print(message);
                    EasyLoading.showProgress(value, status: message);
                  });
                  await LocalMangaDatabaseProvider().insert(data);
                  EasyLoading.dismiss();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('导入成功'),
                  ));
                } catch (e) {
                  EasyLoading.dismiss();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('导入失败，错误：$e'),
                  ));
                }
              },
            ),
            TextButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.all(5))),
              child: Card(
                child: ListTile(
                  title: Text('网址下载'),
                  subtitle: Text('通过url下载导入'),
                  leading: Icon(Icons.http),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
              onPressed: () async {
                TextEditingController controller = TextEditingController();
                TextEditingController filenameController =
                    TextEditingController();
                var data = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Wrap(
                          children: [
                            TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: '网址',
                                  helperText: '下载文件的网址'),
                            ),
                            TextField(
                              controller: filenameController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: '文件名',
                                  helperText: '下载后的文件名'),
                            )
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text(S.of(context).Cancel),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: Text(S.of(context).Confirm),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          )
                        ],
                      );
                    });
                if (data != null && data) {
                  EasyLoading.instance..maskType = EasyLoadingMaskType.black;
                  EasyLoading.showProgress(0, status: '开始导入');
                  try {
                    var response = await Dio().get(controller.text,
                        options: Options(responseType: ResponseType.bytes),
                        onReceiveProgress: (value, value2) {
                      EasyLoading.showProgress(value / value2 / 10,
                          status: '正在下载');
                    });
                    if (response.statusCode == 200) {
                      String savePath = Provider.of<SystemSettingModel>(context,
                                  listen: false)
                              .savePath +
                          "/manga/" +
                          filenameController.text;
                      MangaObject data = await BaseMangaModel()
                          .decodeFromBytes(response.data, outputPath: savePath,
                              callBack: (value, message) {
                        print(value);
                        print(message);
                        EasyLoading.showProgress(value, status: message);
                      });
                      await LocalMangaDatabaseProvider().insert(data);
                      EasyLoading.dismiss();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('导入成功'),
                      ));
                    }
                  } catch (e) {
                    EasyLoading.dismiss();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('导入失败，错误：$e'),
                    ));
                  }
                }
              },
            ),
            TextButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.all(5))),
              child: Card(
                child: ListTile(
                  title: Text('IPFS导入'),
                  subtitle: Text('通过IPFS网络导入漫画（须在设置配置IPFS客户端设置）'),
                  leading: Icon(Icons.network_check),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
              onPressed: () async {
                TextEditingController controller = TextEditingController(
                    text: 'https://hanerx.top/test/kyuso379_fanbox.manga');
                TextEditingController filenameController =
                    TextEditingController(text: 'kyuso379_fanbox');
                var data = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Wrap(
                          children: [
                            TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'CID',
                                  helperText: 'IPFS网络文件标识值'),
                            ),
                            TextField(
                              controller: filenameController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: '目录名称',
                                  helperText: '下载后的目录名称'),
                            )
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text(S.of(context).Cancel),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: Text(S.of(context).Confirm),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          )
                        ],
                      );
                    });
                if (data != null && data) {
                  EasyLoading.instance..maskType = EasyLoadingMaskType.black;
                  EasyLoading.showProgress(0, status: '开始导入');
                  try {
                    String savePath =
                        Provider.of<SystemSettingModel>(context, listen: false)
                                .savePath +
                            "/manga/" +
                            filenameController.text;
                    MangaObject data = await BaseMangaModel().decodeFromBytes(
                        await Provider.of<IPFSSettingProvider>(context,
                                listen: false)
                            .catBytes(controller.text),
                        outputPath: savePath, callBack: (value, message) {
                      print(value);
                      print(message);
                      EasyLoading.showProgress(value, status: message);
                    });
                    await LocalMangaDatabaseProvider().insert(data);
                    EasyLoading.dismiss();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('导入成功'),
                    ));
                  } catch (e) {
                    EasyLoading.dismiss();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('导入失败，错误：$e'),
                    ));
                  }
                }
              },
            ),
            TextButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.all(5))),
              child: Card(
                child: ListTile(
                  title: Text('文件夹导入'),
                  subtitle: Text('导入一个文件夹实现解析操作，主要是用来针对过大的文件没法解析的bug'),
                  leading: Icon(Icons.file_copy),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
              onPressed: () async {
                try {
                  EasyLoading.instance..maskType = EasyLoadingMaskType.black;
                  EasyLoading.showProgress(0, status: '开始导入');
                  var result = await FilePicker.platform
                      .getDirectoryPath();
                  MangaObject data = await BaseMangaModel().decodeFromDirectory(
                      result, callBack: (value, message) {
                    print(value);
                    print(message);
                    EasyLoading.showProgress(value, status: message);
                  });
                  await LocalMangaDatabaseProvider().insert(data);
                  EasyLoading.dismiss();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('导入成功'),
                  ));
                } catch (e) {
                  EasyLoading.dismiss();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('导入失败，错误：$e'),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    ));
  }
}
