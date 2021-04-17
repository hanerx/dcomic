import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/component/comic/HistoryListTile.dart';
import 'package:dcomic/model/cloudHistoryModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:dcomic/view/comic_detail_page.dart';
import 'package:dcomic/view/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:provider/provider.dart';

class CloudHistoryTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CloudHistoryTab();
  }
}

class _CloudHistoryTab extends State<CloudHistoryTab> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => CloudHistoryModel(),
      builder: (context, child) => EasyRefresh(
        scrollController: ScrollController(),
        firstRefresh: true,
        firstRefreshWidget: LoadingCube(),
        child: ListView.builder(
            itemCount: Provider.of<CloudHistoryModel>(context).length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var item = Provider.of<CloudHistoryModel>(context).data[index];
              return HistoryListTile(
                cover: item['cover'],
                title: item['comic_name'],
                chapterName: item['chapter_name'],
                date: item['viewing_time'],
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ComicDetailPage(
                            title: item['comic_name'],
                            id: item['comic_id'].toString(),
                            model: Provider.of<SourceProvider>(context)
                                .activeSources
                                .first,
                          )));
                },
              );
            }),
        onRefresh: () async {
          await Provider.of<CloudHistoryModel>(context, listen: false)
              .refresh();
        },
        emptyWidget: Provider.of<CloudHistoryModel>(context).login
            ? Provider.of<CloudHistoryModel>(context).length == 0
                ? EmptyView()
                : null
            : EmptyView(
                message: '请先登录',
                child: TextButton(
                  child: Text('跳转登录'),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                ),
              ),
      ),
    );
  }
}
