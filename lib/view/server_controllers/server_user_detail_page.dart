import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:dcomic/model/server_controller/NewComicDetailModel.dart';
import 'package:dcomic/model/server_controller/NewUserDetailModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';

class ServerUserDetailPage extends StatefulWidget {
  final EditMode mode;
  final IPFSSourceModel node;
  final String userId;

  const ServerUserDetailPage({Key key, this.mode, this.node, this.userId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ServerUserDetailPage();
  }
}

class _ServerUserDetailPage extends State<ServerUserDetailPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) =>
          NewUserDetailModel(widget.mode, widget.node, widget.userId),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text('编辑用户'),
          actions: [
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: widget.mode == EditMode.edit
                    ? () async {
                        bool state = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('确认删除'),
                                  content: Text('确认删除该账户吗？'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text(S.of(context).Cancel)),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text(S.of(context).Confirm)),
                                  ],
                                ));
                        if (state != null && state) {
                          bool result = await Provider.of<NewUserDetailModel>(
                                  context,
                                  listen: false)
                              .deleteUser();
                          if (result) {
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('出现未知错误')));
                          }
                        }
                      }
                    : null),
            IconButton(
                icon: Icon(Icons.check),
                onPressed: () async {
                  bool result = await Provider.of<NewUserDetailModel>(context,
                          listen: false)
                      .updateUser();
                  if (result) {
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('出现未知错误')));
                  }
                })
          ],
        ),
        body: EasyRefresh(
          onRefresh: () async {
            await Provider.of<NewUserDetailModel>(context, listen: false)
                .init();
          },
          firstRefresh: true,
          firstRefreshWidget: LoadingCube(),
          emptyWidget: Provider.of<NewUserDetailModel>(context).error == null
              ? null
              : EmptyView(
                  message: Provider.of<NewUserDetailModel>(context).error,
                ),
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              ListTile(
                title: TextField(
                  controller: Provider.of<NewUserDetailModel>(context)
                      .usernameController,
                  enabled: widget.mode == EditMode.create,
                  decoration: InputDecoration(
                      labelText: '用户名',
                      icon: Icon(Icons.account_circle),
                      helperText: '输入用户名，一旦注册不可更改'),
                ),
              ),
              ListTile(
                title: TextField(
                  controller: Provider.of<NewUserDetailModel>(context)
                      .nicknameController,
                  decoration: InputDecoration(
                      labelText: '昵称',
                      icon: Icon(Icons.message),
                      helperText: '用于显示的昵称'),
                ),
              ),
              ListTile(
                title: TextField(
                  controller: Provider.of<NewUserDetailModel>(context)
                      .passwordController,
                  decoration: InputDecoration(
                      labelText: '密码',
                      icon: Icon(Icons.lock),
                      helperText: '修改用户时可不填，填写即修改密码'),
                ),
              ),
              Divider(),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      child: Provider.of<NewUserDetailModel>(context).hasAvatar
                          ? TextButton(
                              onPressed: () async {
                                await Provider.of<NewUserDetailModel>(context,
                                        listen: false)
                                    .uploadAvatar();
                              },
                              child: CachedNetworkImage(
                                imageUrl:
                                    Provider.of<NewUserDetailModel>(context)
                                        .avatar,
                              ))
                          : TextButton.icon(
                              onPressed: () async {
                                await Provider.of<NewUserDetailModel>(context,
                                        listen: false)
                                    .uploadAvatar();
                              },
                              label: Text('点击上传'),
                              icon: Icon(Icons.upload_file),
                            ),
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: TextField(
                          controller: Provider.of<NewUserDetailModel>(context)
                              .avatarController,
                          maxLines: 2,
                          decoration: InputDecoration(
                              labelText: '头像CID',
                              icon: Icon(Icons.upload_file),
                              helperText: '头像CID，通过按钮或点击图片上传')))
                ],
              ),
              Divider(),
              ListTile(
                dense: true,
                title: Text('用户权限'),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    TextEditingController nameController =
                        TextEditingController();
                    TextEditingController idController =
                        TextEditingController();
                    bool state = await showDialog<bool>(
                        context: context,
                        builder: (context) => buildRightDialog(
                            context, nameController, idController));
                    if (state != null && state) {
                      Provider.of<NewUserDetailModel>(context, listen: false)
                          .addRight(UserRight(int.parse(idController.text),
                              nameController.text, null));
                    }
                  },
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount:
                      Provider.of<NewUserDetailModel>(context).rights.length,
                  itemBuilder: (context, index) {
                    var item =
                        Provider.of<NewUserDetailModel>(context).rights[index];
                    return ListTile(
                      title: Text('${item.rightDescription}'),
                      subtitle: Text(
                          '权限编号：${item.rightNum} 权限目标：${item.rightTarget}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          Provider.of<NewUserDetailModel>(context,
                                  listen: false)
                              .deleteRight(item);
                        },
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRightDialog(context, titleController, idController) {
    return AlertDialog(
      title: Text('添加权限'),
      content: Wrap(
        children: [
          ListTile(
            title: TextField(
              controller: titleController,
              decoration: InputDecoration(
                  labelText: '权限备注',
                  icon: Icon(Icons.title),
                  helperText: '输入权限备注'),
            ),
          ),
          ListTile(
            title: TextField(
              controller: idController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: '权限ID',
                  icon: Icon(FontAwesome5.id_card),
                  helperText: '输入权限ID'),
            ),
          ),
          // ListTile(
          //   title: TextField(
          //     controller:
          //     Provider.of<NewComicDetailModel>(context).titleController,
          //     decoration: InputDecoration(
          //         labelText: '权限目标',
          //         icon: Icon(Icons.title),
          //         helperText: '权限作用目标，无目标则空置'),
          //   ),
          // ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(S.of(context).Cancel)),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(S.of(context).Confirm)),
      ],
    );
  }
}
