import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/comic_viewer.dart';
import 'package:provider/provider.dart';

import 'comic_detail_page.dart';

class DarkSidePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DarkSidePage();
  }
}

class _DarkSidePage extends State<DarkSidePage> {
  List list = <Widget>[];
  bool refreshState = true;
  bool search = false;
  var data;

  getDarkInfo() async {
    CustomHttp http = CustomHttp();
    var response = await http.getDarkInfo();
    if (response.statusCode == 200 && mounted) {
      setState(() {
        list.clear();
        data = jsonDecode(response.data);
        for (var item in data) {
          var authors = item['authors'].join('/');
          var types = item['types'].join('/');
          bool live = item['last_update_chapter_id'] != 0;
          list.add(DarkCustomListTile(
              item['cover'],
              item['title'],
              types,
              item['last_updatetime'],
              item['id'].toString(),
              authors,
              live,
              item['last_update_chapter_id'].toString()));
        }
        refreshState = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getDarkInfo();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.grey[800],
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: search
              ? TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '输入关键词',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (val) {
                    setState(() {
                      refreshState = true;
                      list.clear();
                      for (var item in data) {
                        if (item['title'].indexOf(val) >= 0) {
                          var authors = item['authors'].join('/');
                          var types = item['types'].join('/');
                          bool live = item['last_update_chapter_id'] != 0;
                          list.add(DarkCustomListTile(
                              item['cover'],
                              item['title'],
                              types,
                              item['last_updatetime'],
                              item['id'].toString(),
                              authors,
                              live,
                              item['last_update_chapter_id'].toString()));
                        }
                      }
                      refreshState = false;
                      search = false;
                    });
                  },
                )
              : FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Text(
                    '黑暗面',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    setState(() {
                      search = true;
                    });
                  },
                ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.help_outline,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text('帮助'),
                        children: <Widget>[
                          SimpleDialogOption(
                            child: Text(
                                '这里是大妈之家黑暗面，这里存储了在光明面消失的部分漫画。点击黑暗面标题可以进入搜索模式。经过调整，我们将漫画分为三个档次，第一个是能看到详情页，那会直接跳转，第二个是有最后一章节的数据，那会跳转到浏览页，第三种是完全失败。注：本功能是通过调用别人的接口实现的，不知道什么时候就会消失，并且不一定在这里能看到详情的漫画就一定能看(有一些还是被阉割了的'),
                          )
                        ],
                      );
                    });
              },
            )
          ],
        ),
        body: EasyRefresh(
          firstRefresh: true,
          firstRefreshWidget: LoadingCube(backgroundColor: Colors.black,textColor: Colors.white,cubeColor: Colors.teal,),
          child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return list[index];
              }),
          header: ClassicalHeader(
              refreshedText: '刷新完成',
              refreshFailedText: '刷新失败',
              refreshingText: '刷新中',
              refreshText: '下拉刷新',
              refreshReadyText: '释放刷新',
              textColor: Colors.white),
          footer: ClassicalFooter(
              loadReadyText: '下拉加载更多',
              loadFailedText: '加载失败',
              loadingText: '加载中',
              loadedText: '加载完成',
              noMoreText: '没有更多内容了',
              textColor: Colors.white),
          onRefresh: () async {
            setState(() {
              refreshState = true;
              list.clear();
            });
            await getDarkInfo();
            return;
          },
        ));
  }
}

class DarkCustomListTile extends StatelessWidget {
  final String cover;
  final String title;
  final String types;
  final int date;
  final String authors;
  final bool live;
  final String lastChapterId;
  String formatDate = '';
  final String comicId;

  DarkCustomListTile(this.cover, this.title, this.types, this.date,
      this.comicId, this.authors, this.live, this.lastChapterId) {
    formatDate = ToolMethods.formatTimestamp(date);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
        child: FlatButton(
      padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
      onPressed: () async {
        if(Provider.of<SystemSettingModel>(context,listen: false).backupApi){
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ComicDetailPage(comicId);
          }));
        }else{
          CustomHttp http = CustomHttp();
          var response = await http.getComicDetail(comicId);
          if (response.statusCode == 200 &&
              response.data['chapters'].length > 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ComicDetailPage(comicId);
            }));
          } else if (live) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ComicViewPage(
                  comicId: comicId,
                  chapterId: lastChapterId,
                  chapterList: [lastChapterId]);
            }));
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  '这本漫画是真的没有了，RIP',
                  style: TextStyle(color: Colors.red),
                )));
          }
        }
      },
      child: Card(
        color: Colors.grey[600],
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
              errorWidget: (context, url, error) => Icon(
                Icons.error,
                color: Colors.white,
              ),
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
                        style: TextStyle(
                            fontSize: 16,
                            color: live ? Colors.white : Colors.red),
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
                              color: Colors.white,
                            ),
                            Text(
                              authors,
                              style: TextStyle(color: Colors.white),
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
                              color: Colors.white,
                            ),
                            Text(
                              types,
                              style: TextStyle(color: Colors.white),
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
                              color: Colors.white,
                            ),
                            Text(
                              formatDate,
                              style: TextStyle(color: Colors.white),
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
