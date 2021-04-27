import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/component/comic/ComicListTile.dart';
import 'package:dcomic/model/comicLatestUpdateModel.dart';
import 'package:provider/provider.dart';

import 'comic_detail_page.dart';

class LatestUpdatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LatestUpdatePage();
  }
}

class _LatestUpdatePage extends State<LatestUpdatePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
        create: (_) => ComicLatestUpdateModel(Provider.of<SourceProvider>(context).activeHomeModel),
        builder: (context, child) => DirectSelectContainer(
                child: Column(
              children: [
                Expanded(
                  child: EasyRefresh(
                    firstRefreshWidget: LoadingCube(),
                    firstRefresh: true,
                    onRefresh: () async {
                      await Provider.of<ComicLatestUpdateModel>(context,
                              listen: false)
                          .refresh();
                      return;
                    },
                    onLoad: () async {
                      await Provider.of<ComicLatestUpdateModel>(context,
                              listen: false)
                          .next();
                      return;
                    },
                    emptyWidget:
                        Provider.of<ComicLatestUpdateModel>(context).length == 0
                            ? EmptyView()
                            : null,
                    child: ListView.builder(
                      itemCount:
                          Provider.of<ComicLatestUpdateModel>(context).length,
                      itemBuilder: (context, index) {
                        var item = Provider.of<ComicLatestUpdateModel>(context,
                                listen: false)
                            .data[index];
                        return ComicListTile(
                          title: item.title,
                          cover: item.cover,
                          tag: item.types,
                          authors: item.authors,
                          date: item.timestamp,
                          headers: item.headers,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ComicDetailPage(
                                  id: item.comicId,
                                  title: item.title,
                                  model: item.model,
                                ),
                                settings: RouteSettings(name: 'comic_detail_page')));
                          },
                        );
                        // return list[index];
                      },
                    ),
                  ),
                )
              ],
            )));
  }

}
