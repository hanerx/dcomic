import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:dcomic/model/server_controller/NewComicDetailModel.dart';
import 'package:dcomic/model/server_controller/UserListModel.dart';
import 'package:dcomic/view/server_controllers/server_user_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class UserListPage extends StatefulWidget {
  final IPFSSourceModel node;

  const UserListPage({Key key, this.node}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UserListPage();
  }
}

class _UserListPage extends State<UserListPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => UserListModel(widget.node),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text('用户列表'),
        ),
        body: EasyRefresh(
          firstRefreshWidget: LoadingCube(),
          firstRefresh: true,
          onRefresh: () async {
            await Provider.of<UserListModel>(context, listen: false).init();
          },
          emptyWidget: Provider.of<UserListModel>(context).data.length == 0
              ? EmptyView()
              : null,
          child: ListView.builder(
              itemCount: Provider.of<UserListModel>(context).data.length,
              itemBuilder: (context, index) {
                var item = Provider.of<UserListModel>(context).data[index];
                return ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('${item.nickname}'),
                  subtitle: Text(
                      '用户名：${item.username} 权限：${item.admin ? '管理员' : "一般用户"}\n头像CID：${item.avatar}'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ServerUserDetailPage(
                              node: widget.node,
                              userId: item.username,
                              mode: EditMode.edit,
                            ),
                        settings:
                            RouteSettings(name: 'server_user_detail_page')));
                  },
                );
              }),
        ),
      ),
    );
  }
}
