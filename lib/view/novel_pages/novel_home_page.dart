import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutterdmzj/component/CardView.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/view/novel_pages/novel_detail_page.dart';

class NovelHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelHomePage();
  }
}

class _NovelHomePage extends State<NovelHomePage> {
  List list = <Widget>[];
  bool refreshState = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getMainPage() async {
    CustomHttp http = CustomHttp();
    var response = await http.getNovelMainPageRecommend();
    if (response.statusCode == 200) {
      List data = response.data;
      if (this.mounted) {
        setState(() {
          data.forEach((item) {
            if (item['category_id'] == 57) {
              list.add(Container(
                  height: 230,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Swiper.children(
                      children: item['data']
                          .map<Widget>((e) => _CustomPage(
                              imageUrl: e['cover'],
                              title: e['title'],
                              author: e['sub_title'],
                              id: e['obj_id']))
                          .toList(),
                      autoplay: true,
                      pagination:
                          SwiperPagination(alignment: Alignment.bottomRight),
                    ),
                  )));
            } else if (item['data'].length % 3 == 0) {
              list.add(new _CardView(
                  item['title'], item['data'], 3, item['category_id']));
            } else {
              list.add(new _CardView(
                  item['title'], item['data'], 2, item['category_id']));
            }
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return EasyRefresh(
      scrollController: ScrollController(),
      child: new Scrollbar(
        child: new SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
          child: Column(
            children: list,
          ),
        )),
      ),
      firstRefreshWidget: LoadingCube(),
      firstRefresh: true,
      onRefresh: () async {
        setState(() {
          refreshState = true;
          list.clear();
        });
        await getMainPage();
        return;
      },
      header: ClassicalHeader(
          refreshedText: '刷新完成',
          refreshFailedText: '刷新失败',
          refreshingText: '刷新中',
          refreshText: '下拉刷新',
          refreshReadyText: '释放刷新'),
    );
  }
}

class _CardView extends StatelessWidget {
  String title = '';
  List list;
  int row = 2;
  List mainList = <Widget>[];
  Widget action = Container();

  _CardView(title, list, row, categoryId) {
    this.title = title;
    this.list = list;
    this.row = row;
    mainList = <Widget>[
      Padding(
        padding: EdgeInsets.fromLTRB(5, 4, 0, 4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '$title',
                style: TextStyle(fontSize: 20),
              ),
            ),
            action
          ],
        ),
      ),
    ];
    var cardList = <Widget>[];
    int position = 0;
    for (var item in list) {
      if (position >= row) {
        mainList.add(Row(
          children: cardList,
        ));
        cardList = <Widget>[];
        position = 0;
      }
      cardList.add(_CustomCard(
          item['cover'], item['title'], item['sub_title'], item['obj_id']));
      position++;
    }
    if (position > 0) {
      mainList.add(Row(
        children: cardList,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Card(
      elevation: 0,
      margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
      shape: BeveledRectangleBorder(),
      child: Column(
        children: mainList,
      ),
    );
  }
}

class _CustomCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final int id;

  _CustomCard(this.imageUrl, this.title, this.author, this.id);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Expanded(
        child: FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => NovelDetailPage(id: id)));
      },
      child: Card(
        elevation: 0,
          child: new Container(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            ClipRRect(
              child: CachedNetworkImage(
                imageUrl: '$imageUrl',
                httpHeaders: {'referer': 'http://images.dmzj.com'},
                progressIndicatorBuilder:
                    (context, url, downloadProgress) =>
                    CircularProgressIndicator(
                        value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$title',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            Text(
              '${author != null ? author : ''}',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      )),
    ));
  }
}

class _CustomPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final int id;

  const _CustomPage({Key key, this.imageUrl, this.title, this.author, this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ClipRRect(
      child: FlatButton(
        padding: EdgeInsets.zero,
        child: Container(
          child: Stack(
            children: [
              ClipRRect(
                child: CachedNetworkImage(
                  imageUrl: '$imageUrl',
                  httpHeaders: {'referer': 'http://images.dmzj.com'},
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 30,
                child: Container(
                  padding: EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5))),
                  child: Text(
                    '$title',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => NovelDetailPage(id: id)));
        },
      ),
      borderRadius: BorderRadius.circular(5),
    );
  }
}
