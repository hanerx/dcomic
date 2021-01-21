import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/novel_pages/novel_detail_page.dart';


class NovelLatestUpdatePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelLatestUpdatePage();
  }
  
}

class _NovelLatestUpdatePage extends State<NovelLatestUpdatePage>{
  int page = 0;
  bool refreshState = false;
  List list = <Widget>[];

  getLatestList() async {
      CustomHttp http = CustomHttp();
      var response = await http.getNovelLatestList(page);
      if (response.statusCode == 200 && mounted) {
        setState(() {
          if (response.data.length == 0) {
            refreshState = true;
            return;
          }
          for (var item in response.data) {
            list.add(_CustomListTile(item['cover'], item['name'], item['types'].join('/'),
                item['last_update_time'], item['id'], item['authors']));
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
    return EasyRefresh(
      scrollController: ScrollController(),
      onRefresh: ()async{
        setState(() {
          refreshState = true;
          page = 0;
          list.clear();
        });
        await getLatestList();
      },
      onLoad: ()async{
        setState(() {
          refreshState = true;
          page++;
        });
        await getLatestList();
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
      firstRefresh: true,
      firstRefreshWidget: LoadingCube(),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return list[index];
        },
      ),
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