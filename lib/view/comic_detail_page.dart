import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parallax/flutter_parallax.dart';
import 'package:flutterdmzj/component/Authors.dart';
import 'package:flutterdmzj/component/CustomDrawer.dart';
import 'package:flutterdmzj/component/FancyFab.dart';
import 'package:flutterdmzj/component/TypeTags.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/comment_page.dart';
import 'package:flutterdmzj/view/login_page.dart';
import 'package:markdown_widget/markdown_widget.dart';

import 'comic_viewer.dart';
import 'comic_viewer.dart';

class ComicDetailPage extends StatefulWidget {
  String id = '';

  ComicDetailPage(this.id);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicDetailPage(id);
  }
}

class _ComicDetailPage extends State<ComicDetailPage> {
  String title = '加载中';
  String id = '';
  String cover = 'http://manhua.dmzj.com/css/img/mh_logo_dmzj.png?t=20131122';
  List author = [];
  List types = [];
  int hotNum = 0;
  int subscribeNum = 0;
  String description = '加载中...';
  bool error = false;
  String updateDate = '';
  String status = '加载中';
  List chapters = <Widget>[];
  bool login = false;
  bool sub = false;
  bool loading = false;
  String uid = '';
  String lastChapterId = '';
  List lastChapterList = <Widget>[];
  bool reverse = false;

  _ComicDetailPage(this.id);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadComic();
    getIfSubscribe();
    addReadHistory();
  }

  @override
  void deactivate() {
    super.deactivate();
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        loadComic();
        getIfSubscribe();
        addReadHistory();
      });
    }
  }

  addReadHistory() async {
    DataBase dataBase = DataBase();
    bool loginState = await dataBase.getLoginState();
    if (loginState) {
      var uid = await dataBase.getUid();
      CustomHttp http = CustomHttp();
      http.addReadHistory(id, uid);
      http.addReadHistory0(id, uid);
      http.addReadHistory1(id);
      dataBase.insertUnread(id, DateTime.now().millisecondsSinceEpoch);
    }
  }

  void loadComic() async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getComicDetail(id);
      DataBase dataBase = DataBase();
      var last = await dataBase.getHistory(id);
      if (response.statusCode == 200 && mounted) {
        setState(() {
          title = response.data['title'];
          cover = response.data['cover'];
          List temp = <String>[];
          author = response.data['authors'];
          types = response.data['types'];
          hotNum = response.data['hot_num'];
          subscribeNum = response.data['subscribe_num'];
          description = response.data['description'];
          updateDate =
              ToolMethods.formatTimestamp(response.data['last_updatetime']);
          response.data['status'].forEach((value) {
            temp.add(value['tag_name']);
          });
          status = temp.join('/');
          chapters.clear();
          List chapterData = response.data['chapters'];
          print(
              "class: ComicDetailPage, action: chapterLoading, chapterData: $chapterData");
          for (var item in chapterData) {
            var chapterList = <Widget>[];

            //获取chapterId列表
            var chapterIdList = item['data'].map((map) {
              return map['chapter_id'].toString();
            }).toList();

            var length = chapterIdList.length;
            chapterIdList = List.generate(
                length, (index) => chapterIdList[length - 1 - index]);

            print(
                "class: ComicDetailPage, action: chapterIdListLoading, chapterList: $chapterIdList");

            //记录上次阅读ID
            if (lastChapterId == '' && item['data'].length > 0) {
              lastChapterId = item['data'][item['data'].length - 1]
                      ['chapter_id']
                  .toString();
              lastChapterList = chapterList;
            }

            for (var chapter in item['data']) {
              if (last.first.length > 0 &&
                  chapter['chapter_id'].toString() == last.first[0]['value']) {
                lastChapterId = chapter['chapter_id'].toString();
                lastChapterList = chapterIdList;
                chapterList.add(Container(
                  width: 120,
                  margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
                  child: OutlineButton(
                    child: Text(
                      chapter['chapter_title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () {
                      DataBase dataBase = DataBase();
                      dataBase.addReadHistory(
                          id,
                          title,
                          cover,
                          chapter['chapter_title'],
                          chapter['chapter_id'].toString(),
                          DateTime.now().millisecondsSinceEpoch ~/ 1000);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ComicViewPage(
                            comicId: id,
                            chapterId: chapter['chapter_id'].toString(),
                            chapterList: chapterIdList);
                      }));
                    },
                  ),
                ));
              } else {
                chapterList.add(Container(
                  width: 120,
                  margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
                  child: OutlineButton(
                    child: Text(
                      chapter['chapter_title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () {
                      DataBase dataBase = DataBase();
                      dataBase.addReadHistory(
                          id,
                          title,
                          cover,
                          chapter['chapter_title'],
                          chapter['chapter_id'].toString(),
                          DateTime.now().millisecondsSinceEpoch ~/ 1000);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ComicViewPage(
                            comicId: id,
                            chapterId: chapter['chapter_id'].toString(),
                            chapterList: chapterIdList);
                      }));
                    },
                  ),
                ));
              }
            }
            if (reverse) {
              var length = chapterList.length;
              var tempList = List.generate(
                  length, (index) => chapterList[length - 1 - index]);
              chapterList = tempList;
            }
            chapters.add(Column(
              children: <Widget>[
                Divider(),
                Text(item['title']),
                Divider(),
                Wrap(
                  children: chapterList,
                )
              ],
            ));
          }
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        error = true;
      });
    }
  }

  getIfSubscribe() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    DataBase dataBase = DataBase();
    bool loginState = await dataBase.getLoginState();
    if (mounted) {
      setState(() {
        login = loginState;
      });
    }
    if (login) {
      uid = await dataBase.getUid();
      CustomHttp http = CustomHttp();
      var response = await http.getIfSubscribe(id, uid);
      if (response.statusCode == 200 && mounted && response.data['code'] == 0) {
        setState(() {
          sub = true;
        });
      }
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error) {
      return Scaffold(
        appBar: AppBar(
          title: Text('好像出了点问题！'),
        ),
        body: Center(
          child: Text('漫画找不到了！'),
        ),
      );
    }
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(
                  sub ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (loading) {
                    Scaffold.of(context).showSnackBar(
                        new SnackBar(content: Text('订阅信息还在加载中!')));
                  } else if (!login) {
                    Scaffold.of(context).showSnackBar(new SnackBar(
                      content: Text('请先登录!'),
                      action: SnackBarAction(
                        label: '去登录',
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return LoginPage();
                          }));
                        },
                      ),
                    ));
                  } else {
                    CustomHttp http = CustomHttp();
                    if (sub) {
                      http.cancelSubscribe(id, uid).then((response) {
                        if (response.statusCode == 200 &&
                            response.data['code'] == 0 &&
                            mounted) {
                          setState(() {
                            sub = false;
                          });
                        }
                      });
                    } else {
                      http.addSubscribe(id, uid).then((response) {
                        if (response.statusCode == 200 &&
                            response.data['code'] == 0 &&
                            mounted) {
                          setState(() {
                            sub = true;
                          });
                        }
                      });
                    }
                  }
                },
              );
            },
          ),
//            IconButton(
//              icon: Icon(Icons.forum),
//              onPressed: () {
//                Navigator.push(context, MaterialPageRoute(builder: (context) {
//                  return CommentPage(id);
//                }));
//              },
//            )
        ],
      ),
      endDrawer: CustomDrawer(
        child: CommentPage(id),
        widthPercent: 0.9,
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FancyFab(
            reverse: reverse,
            onSort: () {
              setState(() {
                reverse = !reverse;
              });
              loadComic();
            },
            onPlay: () {
              if (lastChapterId != '') {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ComicViewPage(
                      comicId: id,
                      chapterId: lastChapterId,
                      chapterList: lastChapterList);
                }));
              } else {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('好像没得记录，没法继续阅读'),
                ));
              }
            },
            onBlackBox: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      children: [
                        SimpleDialogOption(
                          child: Text("Ops! 你遇到了一个没有用的按钮"),
                        )
                      ],
                    );
                  });
            },
          );
        },
      ),
      body: SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Parallax.inside(
                    child: Image(
                        image: CachedNetworkImageProvider(cover,
                            headers: {'referer': 'http://images.dmzj.com'}),
                        fit: BoxFit.cover),
                    mainAxisExtent: 200.0,
                  ),
                )
              ],
            ),
            DetailCard(title, updateDate, status, author, types, hotNum,
                subscribeNum, description),
            Card(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Column(children: chapters),
            )
          ],
        ),
      ),
    );
  }
}

class DetailCard extends StatelessWidget {
  final String title;
  final String updateDate;
  final String status;
  final List author;
  final List types;
  final int hotNum;
  final int subscribeNum;
  final String description;

  DetailCard(this.title, this.updateDate, this.status, this.author, this.types,
      this.hotNum, this.subscribeNum, this.description);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Padding(
          padding: EdgeInsets.fromLTRB(4, 2, 4, 10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    '最后更新：$updateDate  $status',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
              Divider(
                color: Colors.black,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.supervisor_account,
                          color: Colors.grey,
                        ),
                        Expanded(
                          child: Authors(author),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.category,
                          color: Colors.grey,
                        ),
                        Expanded(child: TypeTags(types))
                      ],
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.whatshot,
                          color: Colors.grey,
                        ),
                        Expanded(
                          child: Center(
                            child: Text('$hotNum'),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.favorite,
                          color: Colors.grey,
                        ),
                        Expanded(
                          child: Center(
                            child: Text('$subscribeNum'),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(description),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
