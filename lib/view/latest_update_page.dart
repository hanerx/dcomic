import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/component/comic/comicListTile.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/comicLatestUpdateModel.dart';
import 'package:dcomic/view/ranking_page.dart';
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
        create: (_) => ComicLatestUpdateModel(),
        builder: (context, child) => DirectSelectContainer(
                child: Column(
              children: [
                _buildFilter(context),
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
                          title: item['title'],
                          cover: item['cover'],
                          tag: item['types'],
                          authors: item['authors'],
                          date: item['latest_updatetime'],
                          headers: {'referer': 'https://m.dmzj.com'},
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ComicDetailPage(
                                      id: item['id'].toString(),
                                      title: item['title'],
                                    )));
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

  Widget _buildFilter(context) {
    return Container(
      height: 45,
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 10,
              child: Padding(
                child: DirectSelectList<int>(
                  values: Provider.of<ComicLatestUpdateModel>(context)
                      .tagTypeList
                      .keys
                      .toList(),
                  defaultItemIndex: Provider.of<ComicLatestUpdateModel>(context)
                      .tagTypeList
                      .keys
                      .toList()
                      .indexOf(
                      Provider.of<ComicLatestUpdateModel>(context).filterTag),
                  itemBuilder: (int value) => DirectSelectItem<int>(
                      itemHeight: 56,
                      value: value,
                      itemBuilder: (context, value) {
                        return Container(
                          child: Text(
                            Provider.of<ComicLatestUpdateModel>(context,
                                listen: false)
                                .tagTypeList[value],
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                  onItemSelectedListener: (item, index, context) {
                    Provider.of<ComicLatestUpdateModel>(context, listen: false)
                        .filterTag = item;
                    Provider.of<ComicLatestUpdateModel>(context, listen: false)
                        .refresh();
                  },
                  focusedItemDecoration: BoxDecoration(
                    border: BorderDirectional(
                      bottom: BorderSide(width: 1, color: Colors.black12),
                      top: BorderSide(width: 1, color: Colors.black12),
                    ),
                  ),
                ),
                padding: EdgeInsets.only(left: 15),
              )),
          Expanded(
            child: Icon(
              Icons.unfold_more,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
