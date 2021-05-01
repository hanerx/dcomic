import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:dcomic/model/server_controller/NewComicChapterModel.dart';
import 'package:dcomic/model/server_controller/NewComicDetailModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class ServerChapterDetailPage extends StatefulWidget {
  final IPFSSourceModel node;
  final Chapter chapter;
  final EditMode mode;

  const ServerChapterDetailPage({Key key, this.node, this.chapter, this.mode})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ServerChapterDetailPage();
  }
}

class _ServerChapterDetailPage extends State<ServerChapterDetailPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
        create: (_) =>
            NewComicChapterModel(widget.node, widget.chapter, widget.mode),
        builder: (context, child) => DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: Text('编辑章节组'),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: widget.mode == EditMode.edit
                            ? () {
                                Navigator.of(context).pop(
                                    Provider.of<NewComicChapterModel>(context,
                                            listen: false)
                                        .delete());
                              }
                            : null),
                    IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          Navigator.of(context).pop(
                              Provider.of<NewComicChapterModel>(context,
                                      listen: false)
                                  .getChapter());
                        })
                  ],
                  bottom: TabBar(
                    tabs: [
                      Tab(
                        child: Text('基础信息'),
                      ),
                      Tab(
                        child: Text('漫画章节'),
                      )
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    EasyRefresh(
                      onRefresh: () async {
                        await Provider.of<NewComicChapterModel>(context,
                                listen: false)
                            .init();
                      },
                      firstRefreshWidget: LoadingCube(),
                      firstRefresh: true,
                      child: ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          ListTile(
                            title: TextField(
                              controller:
                                  Provider.of<NewComicChapterModel>(context)
                                      .chapterIdController,
                              enabled: widget.mode == EditMode.create,
                              decoration: InputDecoration(
                                  labelText: '章节ID',
                                  icon: Icon(Icons.book),
                                  helperText: '输入章节ID，推荐使用纯英文'),
                            ),
                          ),
                          ListTile(
                            title: TextField(
                              controller:
                                  Provider.of<NewComicChapterModel>(context)
                                      .titleController,
                              decoration: InputDecoration(
                                  labelText: '章节组标题',
                                  icon: Icon(Icons.title),
                                  helperText: '输入章节组标题'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        ListTile(
                          title: Text('章节列表'),
                          trailing: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () async {
                              await Provider.of<NewComicChapterModel>(context,
                                      listen: false)
                                  .addPage();
                            },
                          ),
                        ),
                        Expanded(
                            child: ReorderableListView.builder(
                                itemBuilder: (context, index) {
                                  var item =
                                      Provider.of<NewComicChapterModel>(context)
                                          .data[index];
                                  return ListTile(
                                    key: Key(item),
                                    title: Text("$item"),
                                    leading: CachedNetworkImage(
                                        imageUrl:
                                            '${widget.node.address}/upload/ipfs/$item',
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            Center(
                                              child: Icon(Icons.warning),
                                            )),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        bool state = await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  title: Text('确认删除'),
                                                  content: Text('确认删除该页漫画吗？'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(false);
                                                        },
                                                        child: Text(S
                                                            .of(context)
                                                            .Cancel)),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(true);
                                                        },
                                                        child: Text(S
                                                            .of(context)
                                                            .Confirm)),
                                                  ],
                                                ));
                                        if (state != null && state) {
                                          Provider.of<NewComicChapterModel>(
                                                  context,
                                                  listen: false)
                                              .delete();
                                        }
                                      },
                                    ),
                                  );
                                },
                                itemCount:
                                    Provider.of<NewComicChapterModel>(context)
                                        .data
                                        .length,
                                onReorder: (oldIndex, newIndex) {
                                  Provider.of<NewComicChapterModel>(context,
                                          listen: false)
                                      .reOrderGroup(oldIndex, newIndex);
                                }))
                      ],
                    )
                  ],
                ),
              ),
            ));
  }
}
