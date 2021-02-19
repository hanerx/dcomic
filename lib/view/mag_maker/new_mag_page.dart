import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdmzj/view/mag_maker/mag_guide_page.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class NewMagPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NewMagPage();
  }
}

class _NewMagPage extends State<NewMagPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('新建漫画'),
      ),
      body: ListView(
        children: [
          FlatButton(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                leading: Icon(FontAwesome5.code),
                trailing: Icon(Icons.chevron_right),
                title: Text('内置编辑器'),
                subtitle: Text(
                    '使用内置编辑器直接对code进行编程，功能齐全且不受encoder或decoder限制，但需要有一定的json编辑能力'),
              ),
            ),
            onPressed: () {},
          ),
          FlatButton(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                leading: Icon(FontAwesome5.tasks),
                trailing: Icon(Icons.chevron_right),
                title: Text('构建向导'),
                subtitle: Text(
                    '使用构建向导进行构建，使用简单，但功能需要等待软件更新，且不能支持软件不支持的encoder或decoder'),
              ),
            ),
            onPressed: () {},
          ),
          FlatButton(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                leading: Icon(FontAwesome5.folder_open),
                trailing: Icon(Icons.chevron_right),
                title: Text('从文件中打开'),
                subtitle: Text('打开一个已存在的.manga文件并使用该文件进行编辑'),
              ),
            ),
            onPressed: () {},
          ),
          FlatButton(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                leading: Icon(FontAwesome5.flag),
                trailing: Icon(Icons.chevron_right),
                title: Text('新手教程'),
                subtitle: Text('打开一次新手教程，用最不清晰的流程带你看一遍怎么新建一个.manga文件'),
              ),
            ),
            onPressed: ()async {
              var chapter=GuideChapter();
              await chapter.initFromString(await rootBundle.loadString('assets/guide/chapter0/main.json'));
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MagGuidePage(
                        guide: chapter
                      )));
            },
          ),
        ],
      ),
    );
  }
}
