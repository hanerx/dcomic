import 'package:cached_network_image/cached_network_image.dart';
import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/EmptyView.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';

class RankingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RankingPage();
  }
}

class _RankingPage extends State<RankingPage> {
  int filterDate = 0;
  int filterType = 0;
  int filterTag = 0;
  int page = 0;
  bool refreshState = false;
  List list = <Widget>[];
  List dateTypeList = <String>['日排行', '周排行', '月排行', '总排行'];
  List typeTypeList = <String>['按人气', '按吐槽', '按订阅'];
  Map tagTypeList = <int, String>{0: '全部'};

  loadRankingList() async {
    CustomHttp http = CustomHttp();
    var response =
        await http.getRankList(filterDate, filterType, filterTag, page);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        if (response.data.length == 0) {
          refreshState = true;
          return;
        }
        for (var item in response.data) {
          list.add(CustomListTile(
              item['cover'],
              item['title'],
              item['types'],
              int.parse(item['last_updatetime']),
              item['comic_id'],
              item['authors']));
        }
        refreshState = false;
      });
    }
  }

  loadRankingTag() async {
    CustomHttp http = CustomHttp();
    var response = await http.getFilterTags();
    if (response.statusCode == 200 && mounted) {
      setState(() {
        response.data.forEach(
            (item) => {tagTypeList[item['tag_id']] = item['tag_name']});
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRankingTag();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DirectSelectContainer(
        child: Column(
      children: [
        _buildFilter(context),
        Expanded(
          child: EasyRefresh(
            firstRefreshWidget: LoadingCube(),
            firstRefresh: true,
            onRefresh: () async {
              setState(() {
                refreshState = true;
                page = 0;
                list.clear();
              });
              await loadRankingList();
              return;
            },
            onLoad: () async {
              if (!refreshState) {
                setState(() {
                  refreshState = true;
                  page++;
                });
                await loadRankingList();
              }
              return;
            },
            emptyWidget: list.length == 0 ? EmptyView() : null,
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return list[index];
              },
            ),
          ),
        )
      ],
    ));
  }

  Widget _buildFilter(context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Padding(
            child: DirectSelectList<String>(
              values: dateTypeList,
              defaultItemIndex: filterDate,
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
                setState(() {
                  filterDate = index;
                  list.clear();
                  page = 0;
                });
                loadRankingList();
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
                values: tagTypeList.keys.toList(),
                defaultItemIndex: tagTypeList.keys.toList().indexOf(filterTag),
                itemBuilder: (int value) => DirectSelectItem<int>(
                    itemHeight: 56,
                    value: value,
                    itemBuilder: (context, value) {
                      return Container(
                        child: Text(
                          tagTypeList[value],
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                onItemSelectedListener: (item, index, context) {
                  setState(() {
                    filterTag = item;
                    list.clear();
                    page = 0;
                  });
                  loadRankingList();
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
                values: typeTypeList,
                defaultItemIndex: filterType,
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
                  setState(() {
                    filterType = index;
                    list.clear();
                    page = 0;
                  });
                  loadRankingList();
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
        // Expanded(
        //   child: Text(
        //       '当前:${dateTypeList[filterDate]}-${tagTypeList[filterTag]}-${typeTypeList[filterType]}'),
        // ),
        // FlatButton(
        //   child: Icon(Icons.filter_list),
        //   onPressed: () {
        //     if (tagTypeList.length == 0) {
        //       loadRankingTag();
        //       return;
        //     }
        //     showModalBottomSheet(
        //         context: context,
        //         builder: (context) {
        //           return Container(
        //               height: 220,
        //               child: ListView(
        //                 children: <Widget>[
        //                   ListTile(
        //                     leading: Icon(Icons.date_range),
        //                     title: Text('按日期'),
        //                     subtitle: Text(dateTypeList[filterDate]),
        //                     trailing: PopupMenuButton(
        //                         child: Icon(Icons.arrow_drop_down),
        //                         onSelected: (int value) {
        //                           setState(() {
        //                             filterDate = value;
        //                             setState(() {
        //                               list.clear();
        //                               page = 0;
        //                             });
        //                             loadRankingList();
        //                             Navigator.pop(context);
        //                           });
        //                         },
        //                         itemBuilder: (BuildContext context) {
        //                           var data = <PopupMenuItem<int>>[];
        //                           dateTypeList.forEach((item) {
        //                             data.add(PopupMenuItem(
        //                               child: Text(item),
        //                               value: dateTypeList.indexOf(item),
        //                             ));
        //                           });
        //                           return data;
        //                         }),
        //                   ),
        //                   ListTile(
        //                     leading: Icon(Icons.category),
        //                     title: Text('按分类'),
        //                     subtitle: Text(tagTypeList[filterTag]),
        //                     trailing: PopupMenuButton(
        //                       child: Icon(Icons.arrow_drop_down),
        //                       onSelected: (int value) {
        //                         setState(() {
        //                           filterTag = value;
        //                           setState(() {
        //                             list.clear();
        //                             page = 0;
        //                           });
        //                           loadRankingList();
        //                           Navigator.pop(context);
        //                         });
        //                       },
        //                       itemBuilder: (context) {
        //                         var data = <PopupMenuItem<int>>[];
        //                         tagTypeList.forEach((key, value) {
        //                           data.add(PopupMenuItem(
        //                               child: Text(value), value: key));
        //                         });
        //                         return data;
        //                       },
        //                     ),
        //                   ),
        //                   ListTile(
        //                     leading: Icon(Icons.list),
        //                     title: Text('按种类'),
        //                     subtitle: Text(typeTypeList[filterType]),
        //                     trailing: PopupMenuButton(
        //                         child: Icon(Icons.arrow_drop_down),
        //                         onSelected: (int value) {
        //                           setState(() {
        //                             filterType = value;
        //                             setState(() {
        //                               list.clear();
        //                               page = 0;
        //                             });
        //                             loadRankingList();
        //                             Navigator.pop(context);
        //                           });
        //                         },
        //                         itemBuilder: (BuildContext context) {
        //                           var data = <PopupMenuItem<int>>[];
        //                           typeTypeList.forEach((item) {
        //                             data.add(PopupMenuItem(
        //                               child: Text(item),
        //                               value: typeTypeList.indexOf(item),
        //                             ));
        //                           });
        //                           return data;
        //                         }),
        //                   )
        //                 ],
        //               ));
        //         });
        //   },
        // )
      ],
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String cover;
  final String title;
  final String types;
  final int date;
  final String authors;
  String formatDate = '';
  final String comicId;

  CustomListTile(this.cover, this.title, this.types, this.date, this.comicId,
      this.authors) {
    formatDate = ToolMethods.formatTimestamp(date);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
        child: FlatButton(
      padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ComicDetailPage(
            id: comicId,
            title: title,
          );
        }));
      },
      child: Card(
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: '$cover',
              httpHeaders: {'referer': 'http://images.dmzj.com'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                child:
                    CircularProgressIndicator(value: downloadProgress.progress),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: 100,
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.fromLTRB(10, 2, 0, 0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.supervisor_account,
                              color: Colors.grey[500],
                            ),
                            Text(
                              authors,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.category,
                              color: Colors.grey[500],
                            ),
                            Text(
                              types,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.history,
                              color: Colors.grey[500],
                            ),
                            Text(
                              formatDate,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        )),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    ));
  }
}
