import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/EmptyView.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/component/comic/comicListTile.dart';
import 'package:flutterdmzj/model/comicCategoryDetailModel.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';
import 'package:provider/provider.dart';

class CategoryDetailPage extends StatefulWidget {
  final int categoryId;
  final String title;

  CategoryDetailPage(this.categoryId, this.title);

  @override
  State<StatefulWidget> createState() {
    return _CategoryDetailPage();
  }
}

class _CategoryDetailPage extends State<CategoryDetailPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('分类浏览-${widget.title}'),
        ),
        body: ChangeNotifierProvider(
            create: (_) =>
                ComicCategoryDetailModel(widget.categoryId, widget.title),
            builder: (context, child) => DirectSelectContainer(
                  child: Column(
                    children: <Widget>[
                      _buildFilter(context),
                      Expanded(
                        child: EasyRefresh(
                          firstRefreshWidget: LoadingCube(),
                          firstRefresh: true,
                          onRefresh: () async {
                            await Provider.of<ComicCategoryDetailModel>(context,
                                    listen: false)
                                .refresh();
                            return;
                          },
                          onLoad: () async {
                            await Provider.of<ComicCategoryDetailModel>(context,
                                    listen: false)
                                .next();
                          },
                          emptyWidget: Provider.of<ComicCategoryDetailModel>(context).length == 0 ? EmptyView() : null,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                Provider.of<ComicCategoryDetailModel>(context)
                                    .length,
                            itemBuilder: (context, index) {
                              var item = Provider.of<ComicCategoryDetailModel>(
                                      context,
                                      listen: false)
                                  .data[index];
                              return ComicListTile(
                                cover: item['cover'],
                                title: item['title'],
                                date: item['last_updatetime'],
                                authors: item['authors'],
                                tag: item['types'],
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ComicDetailPage(
                                            id: item['id'].toString(),
                                            title: item['title'],
                                          )));
                                },
                                headers: {'referer': 'https://m.dmzj.com'},
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                )));
  }

  Widget _buildFilter(context) {
    return Container(
      height: 45,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
              child: DirectSelectList<int>(
                values: Provider.of<ComicCategoryDetailModel>(context)
                    .dateTypeList
                    .keys
                    .toList(),
                defaultItemIndex: Provider.of<ComicCategoryDetailModel>(context)
                    .dateTypeList
                    .keys
                    .toList()
                    .indexOf(Provider.of<ComicCategoryDetailModel>(context)
                    .filterDate),
                itemBuilder: (int value) => DirectSelectItem<int>(
                    itemHeight: 56,
                    value: value,
                    itemBuilder: (context, value) {
                      return Container(
                        child: Text(
                          Provider.of<ComicCategoryDetailModel>(context)
                              .dateTypeList[value],
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                onItemSelectedListener: (item, index, context) {
                  Provider.of<ComicCategoryDetailModel>(context, listen: false)
                      .filterDate = item;
                  Provider.of<ComicCategoryDetailModel>(context, listen: false)
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
            ),
          ),
          Expanded(
            child: Icon(
              Icons.unfold_more,
              color: Theme.of(context).disabledColor,
            ),
          ),
          Expanded(
              flex: 2,
              child: Padding(
                child: DirectSelectList<int>(
                  values: Provider.of<ComicCategoryDetailModel>(context)
                      .tagTypeList
                      .keys
                      .toList(),
                  defaultItemIndex: Provider.of<ComicCategoryDetailModel>(context)
                      .tagTypeList
                      .keys
                      .toList()
                      .indexOf(Provider.of<ComicCategoryDetailModel>(context)
                      .filterTag),
                  itemBuilder: (int value) => DirectSelectItem<int>(
                      itemHeight: 56,
                      value: value,
                      itemBuilder: (context, value) {
                        return Container(
                          child: Text(
                            Provider.of<ComicCategoryDetailModel>(context,
                                listen: false)
                                .tagTypeList[value],
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                  onItemSelectedListener: (item, index, context) {
                    Provider.of<ComicCategoryDetailModel>(context, listen: false)
                        .filterTag = item;
                    Provider.of<ComicCategoryDetailModel>(context, listen: false)
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
          Expanded(
              flex: 2,
              child: Padding(
                child: DirectSelectList<String>(
                  values:
                  Provider.of<ComicCategoryDetailModel>(context).typeTypeList,
                  defaultItemIndex:
                  Provider.of<ComicCategoryDetailModel>(context).filterType,
                  itemBuilder: (String value) => DirectSelectItem<String>(
                      itemHeight: 56,
                      value: value,
                      itemBuilder: (context, value) {
                        return Container(
                          child: Text(
                            value,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                  onItemSelectedListener: (item, index, context) {
                    Provider.of<ComicCategoryDetailModel>(context, listen: false)
                        .filterType = index;
                    Provider.of<ComicCategoryDetailModel>(context, listen: false)
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
