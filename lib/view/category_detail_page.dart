import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/EmptyView.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/view/ranking_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final int categoryId;
  final String title;

  CategoryDetailPage(this.categoryId, this.title);

  @override
  State<StatefulWidget> createState() {
    return _CategoryDetailPage(categoryId, title);
  }
}

class _CategoryDetailPage extends State<CategoryDetailPage> {
  int categoryId;
  String title = '加载中';
  int filterDate = 0;
  int filterType = 0;
  int filterTag = 0;
  int page = 0;
  bool refreshState = false;
  List list = <Widget>[];
  Map dateTypeList = <int, String>{};
  List typeTypeList = <String>['按人气', '按更新'];
  Map tagTypeList = <int, String>{};

  _CategoryDetailPage(this.categoryId, this.title);

  void getCategoryFilter() async {
    CustomHttp http = CustomHttp();
    var response = await http.getCategoryFilter();
    if (response.statusCode == 200 && mounted) {
      setState(() {
        response.data[2]['items'].forEach(
            (item) => {dateTypeList[item['tag_id']] = item['tag_name']});
        response.data[3]['items'].forEach(
            (item) => {tagTypeList[item['tag_id']] = item['tag_name']});
      });
    }
  }

  getCategoryDetail() async {
    CustomHttp http = CustomHttp();
    var response = await http.getCategoryDetail(
        categoryId, filterDate, filterTag, filterType, page);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        for (var item in response.data) {
          list.add(CustomListTile(item['cover'], item['title'], item['types'],
              item['last_updatetime'], item['id'].toString(), item['authors']));
        }
        refreshState = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCategoryFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('分类浏览-$title'),
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              if (dateTypeList.length == 0 || tagTypeList.length == 0) {
                getCategoryFilter();
                return;
              }
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                        height: 220,
                        child: ListView(
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.date_range),
                              title: Text('按进度'),
                              subtitle: Text(dateTypeList[filterDate]),
                              trailing: PopupMenuButton(
                                  child: Icon(Icons.arrow_drop_down),
                                  onSelected: (int value) {
                                    setState(() {
                                      filterDate = value;
                                      setState(() {
                                        list.clear();
                                        page = 0;
                                      });
                                      getCategoryDetail();
                                      Navigator.pop(context);
                                    });
                                  },
                                  itemBuilder: (BuildContext context) {
                                    var data = <PopupMenuItem<int>>[];
                                    dateTypeList.forEach((key, value) {
                                      data.add(PopupMenuItem(
                                        child: Text(value),
                                        value: key,
                                      ));
                                    });
                                    return data;
                                  }),
                            ),
                            ListTile(
                              leading: Icon(Icons.category),
                              title: Text('按地域'),
                              subtitle: Text(tagTypeList[filterTag]),
                              trailing: PopupMenuButton(
                                child: Icon(Icons.arrow_drop_down),
                                onSelected: (int value) {
                                  setState(() {
                                    filterTag = value;
                                    setState(() {
                                      list.clear();
                                      page = 0;
                                    });
                                    getCategoryDetail();
                                    Navigator.pop(context);
                                  });
                                },
                                itemBuilder: (context) {
                                  var data = <PopupMenuItem<int>>[];
                                  tagTypeList.forEach((key, value) {
                                    data.add(PopupMenuItem(
                                        child: Text(value), value: key));
                                  });
                                  return data;
                                },
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.list),
                              title: Text('按种类'),
                              subtitle: Text(typeTypeList[filterType]),
                              trailing: PopupMenuButton(
                                  child: Icon(Icons.arrow_drop_down),
                                  onSelected: (int value) {
                                    setState(() {
                                      filterType = value;
                                      setState(() {
                                        list.clear();
                                        page = 0;
                                      });
                                      getCategoryDetail();
                                      Navigator.pop(context);
                                    });
                                  },
                                  itemBuilder: (BuildContext context) {
                                    var data = <PopupMenuItem<int>>[];
                                    typeTypeList.forEach((item) {
                                      data.add(PopupMenuItem(
                                        child: Text(item),
                                        value: typeTypeList.indexOf(item),
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
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(7),
                  child: Text(
                        '当前:${dateTypeList[filterDate]}-${tagTypeList[filterTag]}-${typeTypeList[filterType]}'),
                  )
            ],
          ),
          Expanded(
            child: EasyRefresh(
              scrollController: ScrollController(),
              firstRefreshWidget: LoadingCube(),
              firstRefresh: true,
              onRefresh: () async {
                setState(() {
                  refreshState = true;
                  page = 0;
                  list.clear();
                });
                await getCategoryDetail();
              },
              onLoad: () async {
                setState(() {
                  refreshState = true;
                  page++;
                });
                await getCategoryDetail();
              },
              emptyWidget: list.length==0?EmptyView():null,
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return list[index];
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
