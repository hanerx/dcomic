import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:dcomic/view/server_controllers/server_main_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';

class ServerSelectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ServerSelectPage();
  }
}

class _ServerSelectPage extends State<ServerSelectPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('选择操作服务器'),
      ),
      body: EasyRefresh(
        child: ListView.builder(
            itemCount: Provider.of<SourceProvider>(context)
                .ipfsSourceProvider
                .nodes
                .length,
            itemBuilder: (context, index) {
              var node = Provider.of<SourceProvider>(context)
                  .ipfsSourceProvider
                  .nodes[index];
              return ListTile(
                leading: Icon(FontAwesome5.server),
                title: Text('${node['title']}'),
                subtitle:
                    Text('服务器地址：${node['address']} 简介：${node['description']}'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ServerMainPage(
                            node: node,
                          ),
                      settings: RouteSettings(name: 'server_main_page')));
                },
              );
            }),
      ),
    );
  }
}
