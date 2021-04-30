import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:dcomic/model/server_controller/ServerListModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';

class ServerListPage extends StatefulWidget {
  final IPFSSourceModel node;

  const ServerListPage({Key key, this.node}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ServerListPage();
  }
}

class _ServerListPage extends State<ServerListPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => ServerListModel(widget.node),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text('服务器节点列表'),
        ),
        body: EasyRefresh(
          onRefresh: () async {
            await Provider.of<ServerListModel>(context, listen: false).init();
          },
          firstRefresh: true,
          firstRefreshWidget: LoadingCube(),
          emptyWidget: Provider.of<ServerListModel>(context).data.length == 0
              ? EmptyView()
              : null,
          child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: Provider.of<ServerListModel>(context).data.length,
              itemBuilder: (context, index) {
                var item = Provider.of<ServerListModel>(context).data[index];
                return Card(
                  child: ListTile(
                      leading: Icon(FontAwesome5.server),
                      title: Text(
                        '${item.title}',
                        style: TextStyle(fontSize: 20),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          var model = Provider.of<ServerListModel>(context,
                              listen: false);
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text("确认删除"),
                                    content: Text('确认删除 ${item.address} 的节点吗'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(S.of(context).Cancel)),
                                      TextButton(
                                          onPressed: () async {
                                            await model.delete(item.address);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(S.of(context).Confirm))
                                    ],
                                  ));
                        },
                      ),
                      subtitle: ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Divider(
                            height: 1,
                          ),
                          ListTile(
                            dense: true,
                            title: Text('服务器地址'),
                            subtitle: Text('${item.address}'),
                          ),
                          Divider(
                            height: 1,
                          ),
                          ListTile(
                            dense: true,
                            title: Text('服务器代号'),
                            subtitle: Text('${item.name}'),
                          ),
                          Divider(
                            height: 1,
                          ),
                          ListTile(
                            dense: true,
                            title: Text('服务器简介'),
                            subtitle: Text('${item.description}'),
                          ),
                          Divider(
                            height: 1,
                          ),
                          ListTile(
                            dense: true,
                            title: Text('服务器运行模式'),
                            subtitle: Text('${item.mode}'),
                          ),
                          Divider(
                            height: 1,
                          ),
                          ListTile(
                            dense: true,
                            title: Text('服务器版本'),
                            subtitle: Text('${item.version}'),
                          ),
                        ],
                      )),
                );
              }),
        ),
      ),
    );
  }
}
