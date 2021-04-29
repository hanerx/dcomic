import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class ServerComicDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ServerComicDetailPage();
  }
}

class _ServerComicDetailPage extends State<ServerComicDetailPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('编辑漫画'),
        actions: [
          IconButton(icon: Icon(Icons.delete), onPressed: () {}),
          IconButton(icon: Icon(Icons.check), onPressed: () {})
        ],
      ),
      body: EasyRefresh(
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ListTile(
              title: TextField(
                decoration: InputDecoration(
                    labelText: '漫画ID',
                    icon: Icon(Icons.book),
                    helperText: '输入漫画ID，推荐使用纯英文'),
              ),
            ),
            ListTile(
              title: TextField(
                decoration: InputDecoration(
                    labelText: '漫画标题',
                    icon: Icon(Icons.title),
                    helperText: '输入漫画标题'),
              ),
            ),
            Divider(),
            ListTile(
                title: TextField(
              maxLines: 8,
              decoration: InputDecoration(
                  labelText: '漫画简介',
                  icon: Icon(Icons.description),
                  helperText: '输入漫画简介'),
            )),
            ListTile(
              title: TextField(
                  decoration: InputDecoration(
                      labelText: '漫画状态',
                      icon: Icon(Icons.cached),
                      helperText: '输入漫画状态，如：连载中')),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('漫画作者'),
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('漫画标签'),
            ),
            Divider(),
            
          ],
        ),
      ),
    );
  }
}
