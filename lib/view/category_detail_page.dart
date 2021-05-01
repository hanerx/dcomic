import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/component/comic/ComicListTile.dart';
import 'package:dcomic/model/comicCategoryDetailModel.dart';
import 'package:dcomic/view/comic_detail_page.dart';
import 'package:provider/provider.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryId;
  final String title;
  final BaseSourceModel model;

  CategoryDetailPage({this.categoryId, this.title, this.model});

  @override
  State<StatefulWidget> createState() {
    return _CategoryDetailPage();
  }
}

class _CategoryDetailPage extends State<CategoryDetailPage> {
  @override
  Widget build(BuildContext context) {
    return DirectSelectContainer(
        child: Scaffold(
            appBar: AppBar(
              title: Text('分类浏览-${widget.title}'),
            ),
            body: ChangeNotifierProvider(
              create: (_) => ComicCategoryDetailModel(
                  widget.categoryId, widget.title, widget.model),
              builder: (context, child) => Column(
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
                      emptyWidget:
                          Provider.of<ComicCategoryDetailModel>(context)
                                      .length ==
                                  0
                              ? EmptyView()
                              : null,
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
                            cover: item.cover,
                            title: item.title,
                            date: item.timestamp,
                            authors: item.authors,
                            tag: item.types,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ComicDetailPage(
                                        id: item.comicId,
                                        title: item.title,
                                        model: item.model,
                                      ),
                                  settings: RouteSettings(
                                      name: 'comic_detail_page')));
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
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text('过滤选项:'),
          ),
          Expanded(
              flex: 2,
              child: Padding(
                child: DirectSelectList<String>(
                  values: Provider.of<ComicCategoryDetailModel>(context)
                      .typeTypeList,
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
                    Provider.of<ComicCategoryDetailModel>(context,
                            listen: false)
                        .filterType = index;
                    Provider.of<ComicCategoryDetailModel>(context,
                            listen: false)
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
          Icon(
            Icons.unfold_more,
            color: Theme.of(context).disabledColor,
          ),
        ],
      ),
    );
  }
}
