import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:dcomic/model/localHistoryModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/database/database.dart';
import 'package:provider/provider.dart';

import 'HistoryListTile.dart';

class LocalHistoryTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LocalHistoryTab();
  }
}

class _LocalHistoryTab extends State<LocalHistoryTab> {
  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => LocalHistoryModel(Provider.of<SourceProvider>(context)),
      builder: (context, child) {
        return EasyRefresh(
          scrollController: ScrollController(),
          child: ListView.builder(
              itemCount: Provider.of<LocalHistoryModel>(context).list.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                HistoryComic comic =
                    Provider.of<LocalHistoryModel>(context).list[index];
                return HistoryListTile(comic.cover, comic.title,
                    comic.latestChapter, comic.timestamp, comic.comicId);
              }),
          onRefresh: () async {
            await Provider.of<LocalHistoryModel>(context, listen: false)
                .refresh();
          },
          firstRefreshWidget: LoadingCube(),
          firstRefresh: true,
          emptyWidget: Provider.of<LocalHistoryModel>(context).list.length == 0
              ? EmptyView()
              : null,
        );
      },
    );
  }
}
