import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/LoadingRow.dart';
import 'package:flutterdmzj/component/LoadingTile.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/view/ranking_page.dart';

class LatestUpdatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LatestUpdatePage();
  }
}

class _LatestUpdatePage extends State<LatestUpdatePage> {
  int filterTag = 100;
  int page = 0;
  bool refreshState = false;
  List list = <Widget>[];
  Map tagTypeList = <int, String>{100: '全部漫画', 1: '原创漫画', 0: '译制漫画'};

  getLatestList() async {
    CustomHttp http = CustomHttp();
    var response = await http.getLatestList(filterTag, page);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        if (response.data.length == 0) {
          refreshState = true;
          return;
        }
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
    // TODO: implement initState
    super.initState();
    getLatestList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: Text('当前:${tagTypeList[filterTag]}'),
            ),
            FlatButton(
              child: Icon(Icons.filter_list),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                          height: 80,
                          child: ListView(
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.list),
                                title: Text('按分类'),
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
                                      getLatestList();
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
                            ],
                          ));
                    });
              },
            )
          ],
        ),
        Expanded(
          child: EasyRefresh(
            onRefresh: () async {
              setState(() {
                refreshState = true;
                page = 0;
                list.clear();
              });
              await getLatestList();
              return;
            },
            onLoad: () async {
              setState(() {
                refreshState = true;
                page++;
              });
              await getLatestList();
              return;
            },
            header: ClassicalHeader(
                refreshedText: '刷新完成',
                refreshFailedText: '刷新失败',
                refreshingText: '刷新中',
                refreshText: '下拉刷新',
                refreshReadyText: '释放刷新'),
            footer: ClassicalFooter(
                loadReadyText: '下拉加载更多',
                loadFailedText: '加载失败',
                loadingText: '加载中',
                loadedText: '加载完成',
                noMoreText: '没有更多内容了'
            ),
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
