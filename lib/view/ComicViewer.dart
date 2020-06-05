import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';

class ComicViewer extends StatefulWidget {
  final String comicId;
  final String chapterId;
  final List chapterList;

  ComicViewer(this.comicId, this.chapterId, this.chapterList);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicViewer(comicId, chapterId, chapterList);
  }
}

class _ComicViewer extends State<ComicViewer> {
  final String comicId;
  String chapterId;
  String title = '加载中';
  List list = <Widget>[];
  final List chapterList;
  bool refreshState = false;
  ScrollController _controller = ScrollController();

  _ComicViewer(this.comicId, this.chapterId, this.chapterList);

  void getComic(comicId, chapterId, above) async {
    CustomHttp http = CustomHttp();
    var response = await http.getComic(comicId, chapterId);
    if (response.statusCode == 200 && mounted) {
      if (response.data == '章节不存在') {
        setState(() {
          list.add(Text('章节不存在！'));
        });
        return;
      }
      setState(() {
        var tempList = <Widget>[];
        title = response.data['title'];
        for (var item in response.data['page_url']) {
          tempList.add(CachedNetworkImage(
            imageUrl: item,
            httpHeaders: {'referer': 'http://images.dmzj.com'},
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress)),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ));
        }
        if (above) {
          list = tempList + list;
        } else {
          list += tempList;
        }
        refreshState = false;
      });
    }
  }

  addReadHistory() async{
    DataBase dataBase = DataBase();
    bool loginState = await dataBase.getLoginState();
    if(loginState){
      var uid=await dataBase.getUid();
      CustomHttp http= CustomHttp();
      http.addReadHistory(comicId,uid);
    }
    dataBase.insertHistory(comicId, chapterId);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComic(comicId, chapterId, false);
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          !refreshState) {
        var nextId = chapterList.indexOf(chapterId) - 1;
        if (nextId < 0) {
          return;
        }
        setState(() {
          chapterId = chapterList[nextId];
          refreshState = true;
        });
        getComic(comicId, chapterList[nextId], false);
      }
    });
    addReadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
            controller: _controller,
            headerSliverBuilder: _sliverBuilder,
            body: RefreshIndicator(
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return list[index];
                  }),
              onRefresh: () async {
                if (refreshState == false) {
                  var nextId = chapterList.indexOf(chapterId) + 1;
                  if (nextId >= chapterList.length) {
                    return;
                  }
                  setState(() {
                    chapterId = chapterList[nextId];
                    refreshState = true;
                  });
                  getComic(comicId, chapterList[nextId], true);
                  return;
                }
              },
            )));
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        title: Text('$title'),
        snap: true,
        floating: true,
        actions: <Widget>[
//          FlatButton(
//            child: Icon(
//              Icons.chat,
//              color: Colors.white,
//            ),
//            onPressed: () {
//              showModalBottomSheet(
//                  context: context,
//                  builder: (context) {
//                    return Container(
//                      height: 200,
//                      child: Center(
//                        child: Text(''),
//                      ),
//                    );
//                  });
//            },
//          )
        ],
      )
    ];
  }
}
