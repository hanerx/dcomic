import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:dcomic/model/server_controller/ServerMainPageModel.dart';
import 'package:dcomic/view/server_controllers/server_comic_detail_page.dart';
import 'package:dcomic/view/server_controllers/server_list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';

class ServerMainPage extends StatefulWidget {
  final IPFSSourceModel node;

  const ServerMainPage({Key key, this.node}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ServerMainPage();
  }
}

class _ServerMainPage extends State<ServerMainPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => ServerMainPageModel(widget.node),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text('${Provider.of<ServerMainPageModel>(context).title}'),
        ),
        body: EasyRefresh(
          firstRefreshWidget: LoadingCube(),
          firstRefresh: true,
          onRefresh: () async {
            await Provider.of<ServerMainPageModel>(context, listen: false)
                .init();
          },
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: Icon(FontAwesome5.server),
                  title: Text(
                      '${Provider.of<ServerMainPageModel>(context).title}'),
                  subtitle: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      ListTile(
                        dense: true,
                        title: Text('服务器地址'),
                        subtitle: Text(
                            '${Provider.of<ServerMainPageModel>(context).address}'),
                      ),
                      Divider(
                        height: 1,
                      ),
                      ListTile(
                        dense: true,
                        title: Text('服务器辨识符'),
                        subtitle: Text(
                            '${Provider.of<ServerMainPageModel>(context).name}'),
                      ),
                      Divider(
                        height: 1,
                      ),
                      ListTile(
                        dense: true,
                        title: Text('服务器版本'),
                        subtitle: Text(
                            '${Provider.of<ServerMainPageModel>(context).version}'),
                      ),
                      Divider(
                        height: 1,
                      ),
                      ListTile(
                        dense: true,
                        title: Text('服务器当前模式'),
                        subtitle: Text(
                            '${Provider.of<ServerMainPageModel>(context).mode}'),
                      ),
                      Divider(
                        height: 1,
                      ),
                      ListTile(
                        dense: true,
                        title: Text('服务器简介'),
                        subtitle: Text(
                            '${Provider.of<ServerMainPageModel>(context).description}'),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('当前账号信息'),
                  subtitle: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      ListTile(
                        dense: true,
                        title: Text('昵称'),
                        subtitle: Text(
                            '${Provider.of<ServerMainPageModel>(context).nickname}'),
                      ),
                      Divider(
                        height: 1,
                      ),
                      ListTile(
                        dense: true,
                        title: Text('用户名'),
                        subtitle: Text(
                            '${Provider.of<ServerMainPageModel>(context).username}'),
                      ),
                      Divider(
                        height: 1,
                      ),
                      ListTile(
                        dense: true,
                        title: Text('头像CID'),
                        subtitle: Text(
                            '${Provider.of<ServerMainPageModel>(context).avatar}'),
                      ),
                      Divider(
                        height: 1,
                      ),
                      ListTile(
                        dense: true,
                        title: Text('当前权限'),
                        subtitle: Text(
                          '${Provider.of<ServerMainPageModel>(context).admin ? "管理员" : "非管理员"}',
                          style: TextStyle(
                              color: Provider.of<ServerMainPageModel>(context)
                                      .admin
                                  ? Colors.lightGreen
                                  : Colors.deepOrange),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Wrap(
                      children: [
                        Text(
                          '分布式管理',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Divider()
                      ],
                    ),
                    subtitle: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        ListTile(
                          enabled:
                              Provider.of<ServerMainPageModel>(context).admin,
                          leading: Icon(Icons.list),
                          title: Text('节点列表'),
                          subtitle: Text('管理节点列表'),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ServerListPage(
                                      node: widget.node,
                                    ),
                                settings:
                                    RouteSettings(name: "server_list_page")));
                          },
                        ),
                        ListTile(
                          enabled:
                              Provider.of<ServerMainPageModel>(context).admin,
                          leading: Icon(Icons.add),
                          title: Text('添加节点'),
                          subtitle: Text('添加新节点'),
                          onTap: () async {
                            var urlController = TextEditingController();
                            var tokenController = TextEditingController();
                            bool data = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('新增节点'),
                                      content: Wrap(
                                        children: [
                                          TextField(
                                            controller: urlController,
                                            decoration: InputDecoration(
                                                labelText: '网址',
                                                helperText:
                                                    '服务器地址，除默认80端口外需要提供端口号如: localhost:8080'),
                                          ),
                                          TextField(
                                            controller: tokenController,
                                            decoration: InputDecoration(
                                                labelText: '服务器交流Token',
                                                helperText:
                                                    '从服务器模式可以不添加token，主服务器模式需要在双方添加Token'),
                                          )
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text(S.of(context).Cancel)),
                                        TextButton(
                                            onPressed: () {},
                                            child: Text(S.of(context).Confirm))
                                      ],
                                    ));
                            if (data != null && data) {}
                          },
                        )
                      ],
                    ),
                  )),
              Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Wrap(
                      children: [
                        Text(
                          '漫画管理',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Divider()
                      ],
                    ),
                    subtitle: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        ListTile(
                          enabled:
                              Provider.of<ServerMainPageModel>(context).admin,
                          leading: Icon(Icons.collections_bookmark),
                          title: Text('漫画列表'),
                          subtitle: Text('管理漫画列表'),
                          onTap: () {},
                        ),
                        ListTile(
                          enabled:
                              Provider.of<ServerMainPageModel>(context).admin,
                          leading: Icon(Icons.note_add),
                          title: Text('添加漫画'),
                          subtitle: Text('添加新漫画'),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ServerComicDetailPage(),
                                settings: RouteSettings(
                                    name: 'server_comic_detail_page')));
                          },
                        )
                      ],
                    ),
                  )),
              Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Wrap(
                      children: [
                        Text(
                          '用户管理',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Divider()
                      ],
                    ),
                    subtitle: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        ListTile(
                          enabled:
                              Provider.of<ServerMainPageModel>(context).admin,
                          leading: Icon(Icons.supervisor_account_rounded),
                          title: Text('用户列表'),
                          subtitle: Text('管理用户列表'),
                          onTap: () {},
                        ),
                        ListTile(
                          enabled:
                              Provider.of<ServerMainPageModel>(context).admin,
                          leading: Icon(Icons.group_add),
                          title: Text('添加用户'),
                          subtitle: Text('添加新用户'),
                          onTap: () {},
                        )
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
