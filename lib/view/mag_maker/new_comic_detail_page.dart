import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:dcomic/model/mag_model/MangaComicDetailModel.dart';
import 'package:dcomic/model/mag_model/baseMangaModel.dart';
import 'package:dcomic/view/server_controllers/server_group_detail_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';

import 'new_group_detail_page.dart';

class MangaComicDetailPage extends StatefulWidget {
  final EditMode mode;
  final MangaObject mangaObject;
  final String outputPath;

  const MangaComicDetailPage(
      {Key key, this.mode, this.mangaObject, this.outputPath})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MangaComicDetailPage();
  }
}

class _MangaComicDetailPage extends State<MangaComicDetailPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => MangaComicDetailModel(
          widget.mode, widget.mangaObject, widget.outputPath),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text('编辑漫画'),
          actions: [
            IconButton(
                icon: Icon(Icons.check),
                onPressed: () async {
                  bool result = await Provider.of<MangaComicDetailModel>(
                          context,
                          listen: false)
                      .updateComic();
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
          emptyWidget: Provider.of<MangaComicDetailModel>(context).error == null
              ? null
              : EmptyView(
                  message: Provider.of<MangaComicDetailModel>(context).error,
                ),
          firstRefresh: true,
          firstRefreshWidget: LoadingCube(),
          onRefresh: () async {
            Provider.of<MangaComicDetailModel>(context, listen: false).init();
          },
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              ListTile(
                title: TextField(
                  controller: Provider.of<MangaComicDetailModel>(context)
                      .comicIdController,
                  enabled: widget.mode == EditMode.create,
                  decoration: InputDecoration(
                      labelText: '漫画ID',
                      icon: Icon(Icons.book),
                      helperText: '输入漫画ID，推荐使用纯英文'),
                ),
              ),
              ListTile(
                title: TextField(
                  controller: Provider.of<MangaComicDetailModel>(context)
                      .titleController,
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
                controller: Provider.of<MangaComicDetailModel>(context)
                    .descriptionController,
                decoration: InputDecoration(
                    labelText: '漫画简介',
                    icon: Icon(Icons.description),
                    helperText: '输入漫画简介'),
              )),
              ListTile(
                title: TextField(
                    controller: Provider.of<MangaComicDetailModel>(context)
                        .statusController,
                    decoration: InputDecoration(
                        labelText: '漫画状态',
                        icon: Icon(Icons.cached),
                        helperText: '输入漫画状态，如：连载中')),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('漫画作者'),
                subtitle: Wrap(
                  children: Provider.of<MangaComicDetailModel>(context)
                      .authors
                      .map<Widget>((e) => Chip(
                            label: Text('${e.name}'),
                            deleteIcon: Icon(Icons.delete),
                            onDeleted: () {
                              Provider.of<MangaComicDetailModel>(context,
                                      listen: false)
                                  .deleteAuthor(e);
                            },
                          ))
                      .toList(),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    TextEditingController titleController =
                        TextEditingController();
                    TextEditingController idController =
                        TextEditingController();
                    bool state = await showDialog<bool>(
                        context: context,
                        builder: (context) => buildTagDialog(
                            context, titleController, idController));
                    if (state != null && state) {
                      Provider.of<MangaComicDetailModel>(context, listen: false)
                          .addAuthor(TagObject(
                              titleController.text, idController.text));
                    }
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.category),
                title: Text('漫画标签'),
                subtitle: Wrap(
                  children: Provider.of<MangaComicDetailModel>(context)
                      .tags
                      .map<Widget>((e) => Chip(
                            label: Text('${e.name}'),
                            deleteIcon: Icon(Icons.delete),
                            onDeleted: () {
                              Provider.of<MangaComicDetailModel>(context,
                                      listen: false)
                                  .deleteTag(e);
                            },
                          ))
                      .toList(),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    TextEditingController titleController =
                        TextEditingController();
                    TextEditingController idController =
                        TextEditingController();
                    bool state = await showDialog<bool>(
                        context: context,
                        builder: (context) => buildTagDialog(
                            context, titleController, idController));
                    if (state != null && state) {
                      Provider.of<MangaComicDetailModel>(context, listen: false)
                          .addTag(TagObject(
                              titleController.text, idController.text));
                    }
                  },
                ),
              ),
              Divider(),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      child: Provider.of<MangaComicDetailModel>(context)
                              .hasCover
                          ? TextButton(
                              onPressed: () async {
                                await Provider.of<MangaComicDetailModel>(
                                        context,
                                        listen: false)
                                    .uploadCover();
                              },
                              child: Image.file(
                                File(Provider.of<MangaComicDetailModel>(context)
                                    .cover),
                              ))
                          : TextButton.icon(
                              onPressed: () async {
                                await Provider.of<MangaComicDetailModel>(
                                        context,
                                        listen: false)
                                    .uploadCover();
                              },
                              label: Text('点击上传'),
                              icon: Icon(Icons.upload_file),
                            ),
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: TextField(
                          controller:
                              Provider.of<MangaComicDetailModel>(context)
                                  .coverController,
                          maxLines: 2,
                          decoration: InputDecoration(
                              labelText: '封皮CID',
                              icon: Icon(Icons.upload_file),
                              helperText: '封面CID，通过按钮或点击图片上传')))
                ],
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.book),
                title: Text('章节编辑'),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    var result = await Navigator.of(context).push<GroupObject>(
                        MaterialPageRoute(
                            builder: (context) => MangaGroupDetailPage(
                                  mode: EditMode.create,
                                  outputPath: widget.outputPath,
                                ),
                            settings:
                                RouteSettings(name: 'group_detail_page')));
                    if (result != null) {
                      Provider.of<MangaComicDetailModel>(context, listen: false)
                          .addGroup(result);
                    }
                  },
                ),
              ),
              Container(
                height: 300,
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      Provider.of<MangaComicDetailModel>(context).data.length,
                  itemBuilder: (context, index) {
                    var item =
                        Provider.of<MangaComicDetailModel>(context).data[index];
                    return ListTile(
                      key: Key(item.groupId),
                      title: Text('${item.title}'),
                      subtitle: Text('组ID: ${item.groupId}'),
                      trailing: Icon(Icons.unfold_more),
                      onTap: () async {
                        var result = await Navigator.of(context)
                            .push<GroupObject>(MaterialPageRoute(
                                builder: (context) => MangaGroupDetailPage(
                                      mode: EditMode.edit,
                                      group: item,
                                      outputPath: widget.outputPath,
                                    ),
                                settings:
                                    RouteSettings(name: 'group_detail_page')));
                        if (result != null && result.delete) {
                          Provider.of<MangaComicDetailModel>(context,
                                  listen: false)
                              .deleteGroup(index);
                        } else if (result != null) {
                          Provider.of<MangaComicDetailModel>(context,
                                  listen: false)
                              .updateGroup(index, result);
                        }
                      },
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    Provider.of<MangaComicDetailModel>(context, listen: false)
                        .reOrderGroup(oldIndex, newIndex);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTagDialog(context, titleController, idController) {
    return AlertDialog(
      title: Text('新建tag'),
      content: Wrap(
        children: [
          ListTile(
            title: TextField(
              controller: titleController,
              decoration: InputDecoration(
                  labelText: '标签标题',
                  icon: Icon(Icons.title),
                  helperText: '输入标签标题'),
            ),
          ),
          ListTile(
            title: TextField(
              controller: idController,
              decoration: InputDecoration(
                  labelText: '标签ID',
                  icon: Icon(FontAwesome5.id_card),
                  helperText: '输入标签ID'),
            ),
          ),
          // ListTile(
          //   title: TextField(
          //     controller:
          //     Provider.of<NewComicDetailModel>(context).titleController,
          //     decoration: InputDecoration(
          //         labelText: '标签封面CID',
          //         icon: Icon(Icons.title),
          //         helperText: '输入标签封面CID'),
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
