import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:dcomic/model/server_controller/NewComicGroupModel.dart';
import 'package:dcomic/model/server_controller/NewComicDetailModel.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:dcomic/view/server_controllers/server_chapter_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class ServerGroupDetailPage extends StatefulWidget {
  final EditMode mode;
  final IPFSSourceModel node;
  final GroupObject group;

  const ServerGroupDetailPage({Key key, this.mode, this.node, this.group})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ServerGroupDetailPage();
  }
}

class _ServerGroupDetailPage extends State<ServerGroupDetailPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
        create: (_) =>
            NewComicGroupModel(widget.node, widget.group, widget.mode),
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
                                    Provider.of<NewComicGroupModel>(context,
                                            listen: false)
                                        .delete());
                              }
                            : null),
                    IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          Navigator.of(context).pop(
                              Provider.of<NewComicGroupModel>(context,
                                      listen: false)
                                  .getGroup());
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
                        await Provider.of<NewComicGroupModel>(context,
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
                                  Provider.of<NewComicGroupModel>(context)
                                      .groupIdController,
                              enabled: widget.mode == EditMode.create,
                              decoration: InputDecoration(
                                  labelText: '章节组ID',
                                  icon: Icon(Icons.book),
                                  helperText: '输入章节组ID，推荐使用纯英文'),
                            ),
                          ),
                          ListTile(
                            title: TextField(
                              controller:
                                  Provider.of<NewComicGroupModel>(context)
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
                              var result = await Navigator.of(context)
                                  .push<Chapter>(MaterialPageRoute(
                                      builder: (context) =>
                                          ServerChapterDetailPage(
                                            node: widget.node,
                                            mode: EditMode.create,
                                          ),
                                      settings: RouteSettings(
                                          name: 'group_detail_page')));
                              if (result != null) {
                                Provider.of<NewComicGroupModel>(context,
                                        listen: false)
                                    .addChapter(result);
                              }
                            },
                          ),
                        ),
                        Expanded(
                            child: ReorderableListView.builder(
                                itemBuilder: (context, index) {
                                  var item =
                                      Provider.of<NewComicGroupModel>(context)
                                          .data[index];
                                  return ListTile(
                                    key: Key(item.chapterId),
                                    title: Text("${item.title}"),
                                    subtitle: Text(
                                        '章节ID: ${item.chapterId} 修改日期: ${ToolMethods.formatTimestamp(item.timestamp)}'),
                                    onTap: () async {
                                      var result = await Navigator.of(context)
                                          .push<Chapter>(MaterialPageRoute(
                                              builder: (context) =>
                                                  ServerChapterDetailPage(
                                                    node: widget.node,
                                                    mode: EditMode.edit,
                                                    chapter: item,
                                                  ),
                                              settings: RouteSettings(
                                                  name: 'group_detail_page')));
                                      if (result != null && result.delete) {
                                        Provider.of<NewComicGroupModel>(context,
                                                listen: false)
                                            .deleteChapter(index);
                                      } else if (result != null) {
                                        Provider.of<NewComicGroupModel>(context,
                                                listen: false)
                                            .updateChapter(index, result);
                                      }
                                    },
                                  );
                                },
                                itemCount:
                                    Provider.of<NewComicGroupModel>(context)
                                        .data
                                        .length,
                                onReorder: (oldIndex, newIndex) {
                                  Provider.of<NewComicGroupModel>(context,
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
