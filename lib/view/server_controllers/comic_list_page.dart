import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/component/comic/SearchListTile.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:dcomic/model/server_controller/ComicListModel.dart';
import 'package:dcomic/model/server_controller/NewComicDetailModel.dart';
import 'package:dcomic/view/server_controllers/server_comic_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class ComicListPage extends StatefulWidget {
  final IPFSSourceModel node;

  const ComicListPage({Key key, this.node}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicListPage();
  }
}

class _ComicListPage extends State<ComicListPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => ComicListModel(widget.node),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text("漫画列表"),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                controller: Provider.of<ComicListModel>(context).controller,
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  labelText: '搜索关键词',
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (val) async {
                  await Provider.of<ComicListModel>(context, listen: false)
                      .init();
                },
              ),
            ),
            Expanded(
                child: EasyRefresh(
              firstRefresh: true,
              firstRefreshWidget: LoadingCube(),
              onRefresh: () async {
                await Provider.of<ComicListModel>(context, listen: false)
                    .init();
              },
              emptyWidget: Provider.of<ComicListModel>(context).data.length == 0
                  ? EmptyView()
                  : null,
              child: ListView.builder(
                  itemCount: Provider.of<ComicListModel>(context).data.length,
                  itemBuilder: (context, index) {
                    var comic =
                        Provider.of<ComicListModel>(context, listen: false)
                            .data[index];
                    return SearchListTile(
                      cover: comic.cover,
                      title: comic.title,
                      authors: comic.author,
                      tag: comic.tag,
                      latest: comic.latestChapter,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ServerComicDetailPage(
                                  mode: EditMode.edit,
                                  node: widget.node,
                                  comicId: comic.comicId,
                                )));
                      },
                    );
                  }),
            ))
          ],
        ),
      ),
    );
  }
}
