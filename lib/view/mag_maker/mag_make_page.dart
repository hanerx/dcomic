
import 'package:dcomic/model/mag_model/MangaComicDetailModel.dart';
import 'package:dcomic/view/mag_maker/import_mag_page.dart';
import 'package:dcomic/view/mag_maker/output_mag_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dcomic/view/mag_maker/mag_example_page.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

import 'new_comic_detail_page.dart';

class MagMakePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MagMakePage();
  }
}

class _MagMakePage extends State<MagMakePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('.manga制作器'),
      ),
      body: ListView(
        children: [
          FlatButton(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                title: Text('制作新漫画文件'),
                subtitle: Text('从零开始制作.manga文件，需先选择目标输出路径'),
                leading: Icon(Icons.add_photo_alternate),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
            onPressed: () async {
              var outputPath = await FilePicker.platform.getDirectoryPath();
              if (outputPath != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MangaComicDetailPage(
                          mode: EditMode.create,
                          outputPath: outputPath,
                        ),
                    settings: RouteSettings(name: 'new_mag_page')));
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("请选择有效目录")));
              }
            },
          ),
          // FlatButton(
          //   padding: EdgeInsets.all(5),
          //   child: Card(
          //     child: ListTile(
          //       title: Text('编辑已有漫画文件'),
          //       subtitle: Text('编辑已存在的漫画文件目录'),
          //       leading: Icon(Icons.edit),
          //       trailing: Icon(Icons.chevron_right),
          //     ),
          //   ),
          //   onPressed: () {
          //     Navigator.of(context).push(MaterialPageRoute(
          //         builder: (context) => EditMangaPage(),
          //         settings: RouteSettings(name: 'edit_mag_page')));
          //   },
          // ),
          FlatButton(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                title: Text('导出.manga文件'),
                subtitle: Text('从已有书架中导出.manga文件'),
                leading: Icon(Icons.unarchive),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OutputMangaPage(),
                  settings: RouteSettings(name: 'output_mag_page')));
            },
          ),
          FlatButton(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                title: Text('导入.manga文件'),
                subtitle: Text('导入manga文件到书架中'),
                leading: Icon(Icons.archive),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ImportMagPage(),
                  settings: RouteSettings(name: 'import_mag_page')));
            },
          ),
          // FlatButton(
          //   padding: EdgeInsets.all(5),
          //   child: Card(
          //     child: ListTile(
          //       title: Text('合并.manga文件'),
          //       subtitle: Text('合并两个同名的.manga文件，将会自动合并包括作者在内的各种信息'),
          //       leading: Icon(FontAwesome5.git_alt),
          //       trailing: Icon(Icons.chevron_right),
          //     ),
          //   ),
          //   onPressed: () {},
          // ),
          FlatButton(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                title: Text('查看标准实例'),
                subtitle: Text('查看一个标准的.manga文件实例'),
                leading: Icon(FontAwesome5.archive),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
            onPressed: () async {
              String example =
                  await rootBundle.loadString('assets/guide/example.json');
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MagExamplePage(
                        example: example,
                      ),
                  settings: RouteSettings(name: 'mag_example_page')));
            },
          ),
          // FlatButton(
          //   padding: EdgeInsets.all(5),
          //   child: Card(
          //     child: ListTile(
          //       title: Text('Wiki'),
          //       subtitle: Text('.manga文件开发文档'),
          //       leading: Icon(FontAwesome5.wikipedia_w),
          //       trailing: Icon(Icons.open_in_browser),
          //     ),
          //   ),
          //   onPressed: () {
          //     ToolMethods.callWeb(
          //         'https://github.com/hanerx/flutter_dmzj/wiki', context);
          //   },
          // ),
        ],
      ),
    );
  }
}
