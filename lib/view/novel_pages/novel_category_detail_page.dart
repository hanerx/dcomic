import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/view/novel_pages/novel_detail_page.dart';

class NovelCategoryDetailPage extends StatefulWidget {
  final int categoryId;
  final String title;

  const NovelCategoryDetailPage({Key key, this.categoryId, this.title})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelCategoryDetailPage();
  }
}

class _NovelCategoryDetailPage extends State<NovelCategoryDetailPage> {
  int filterType = 0;
  int filterTag = 0;
  int page = 0;
  bool refreshState = false;
  List list = <Widget>[];
  List typeTypeList = <String>['按人气', '按更新'];
  List tagTypeList = <String>['全部', '连载中', '已完结'];

  getCategoryDetail() async {
    CustomHttp http = CustomHttp();
    var response = await http.getNovelCategoryDetail(
        widget.categoryId, filterTag, filterType, page);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        for (var item in response.data) {
          list.add(_CustomListTile(
              cover: item['cover'],
              name: item['name'],
              id: item['id'],
              authors: item['authors']));
        }
        refreshState = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('分类浏览-${widget.title}'),
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                        height: 140,
                        child: ListView(
                          children: <Widget>[
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
                                  tagTypeList.forEach((item) {
                                    data.add(PopupMenuItem(
                                      child: Text(item),
                                      value: tagTypeList.indexOf(item),
                                    ));
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
                    '当前:${tagTypeList[filterTag]}-${typeTypeList[filterType]}'),
              ),
            ],
          ),
          Expanded(
            child: EasyRefresh(
              firstRefresh: true,
              firstRefreshWidget: LoadingCube(),
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

class _CustomListTile extends StatelessWidget {
  final String cover;
  final String name;
  final int id;
  final String authors;

  const _CustomListTile({Key key, this.cover, this.name, this.id, this.authors})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
        child: FlatButton(
      padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return NovelDetailPage(
            id: id,
          );
        },settings: RouteSettings(name: 'novel_detail_page')));
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
                        name,
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
                ],
              ),
            ))
          ],
        ),
      ),
    ));
  }
}
