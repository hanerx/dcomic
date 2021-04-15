import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/utils/tool_methods.dart';

import 'novel_detail_page.dart';

class NovelRankingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelRankingPage();
  }
}

class _NovelRankingPage extends State<NovelRankingPage> {
  int filterType = 0;
  int filterTag = 0;
  int page = 0;
  bool refreshState = false;
  List list = <Widget>[];
  List typeTypeList = <String>['按人气','按订阅'];
  Map tagTypeList = <int, String>{};

  loadRankingList() async {
    CustomHttp http = CustomHttp();
    var response =
    await http.getNovelRankList(filterType, filterTag, page);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        if (response.data.length == 0) {
          refreshState = true;
          return;
        }
        for (var item in response.data) {
          list.add(_CustomListTile(
              item['cover'],
              item['name'],
              item['types'].join('/'),
              item['last_update_time'],
              item['id'],
              item['authors']));
        }
        refreshState = false;
      });
    }
  }

  loadRankingTag() async {
    CustomHttp http = CustomHttp();
    var response = await http.getNovelFilterTags();
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
    return Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                  '当前:${tagTypeList[filterTag]}-${typeTypeList[filterType]}'),
            ),
            FlatButton(
              child: Icon(Icons.filter_list),
              onPressed: () {
                if (tagTypeList.length == 0) {
                  loadRankingTag();
                  return;
                }
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                          height: 140,
                          child: ListView(
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.category),
                                title: Text('按分类'),
                                subtitle:
                                Text(tagTypeList[filterTag]),
                                trailing: PopupMenuButton(
                                  child: Icon(Icons.arrow_drop_down),
                                  onSelected: (int value) {
                                    setState(() {
                                      filterTag = value;
                                      setState(() {
                                        list.clear();
                                        page = 0;
                                      });
                                      loadRankingList();
                                      Navigator.pop(context);
                                    });
                                  },
                                  itemBuilder: (context) {
                                    var data = <PopupMenuItem<int>>[];
                                    tagTypeList.forEach((key, value) {
                                      data.add(PopupMenuItem(
                                          child: Text(value),
                                          value: key));
                                    });
                                    return data;
                                  },
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.list),
                                title: Text('按种类'),
                                subtitle:
                                Text(typeTypeList[filterType]),
                                trailing: PopupMenuButton(
                                    child:
                                    Icon(Icons.arrow_drop_down),
                                    onSelected: (int value) {
                                      setState(() {
                                        filterType = value;
                                        setState(() {
                                          list.clear();
                                          page = 0;
                                        });
                                        loadRankingList();
                                        Navigator.pop(context);
                                      });
                                    },
                                    itemBuilder:
                                        (BuildContext context) {
                                      var data =
                                      <PopupMenuItem<int>>[];
                                      typeTypeList.forEach((item) {
                                        data.add(PopupMenuItem(
                                          child: Text(item),
                                          value: typeTypeList
                                              .indexOf(item),
                                        ));
                                      });
                                      return data;
                                    }),
                              )
                            ],
                          ));
                    });
              },
            )
          ],
        ),
        Expanded(
          child: EasyRefresh(
            firstRefreshWidget: LoadingCube(),
            firstRefresh: true,
            scrollController: ScrollController(),
            emptyWidget: list.length==0?EmptyView():null,
            onRefresh: ()async{
              setState(() {
                refreshState = true;
                page = 0;
                list.clear();
              });
              await loadRankingList();
            },
            onLoad: ()async{
              setState(() {
                refreshState = true;
                page++;
              });
              await loadRankingList();
            },
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return list[index];
              },
            ),
          ),
        )
      ],
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String cover;
  final String title;
  final String types;
  final int date;
  final String authors;
  String formatDate = '';
  final int novelID;

  _CustomListTile(this.cover, this.title, this.types, this.date, this.novelID,
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
              return NovelDetailPage(id: novelID,);
            }));
          },
          child: Card(
            child: Row(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: '$cover',
                  httpHeaders: {'referer': 'http://images.dmzj.com'},
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
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