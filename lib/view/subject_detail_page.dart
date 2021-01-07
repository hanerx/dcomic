import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parallax/flutter_parallax.dart';
import 'package:flutterdmzj/http/http.dart';

import 'comic_detail_page.dart';

class SubjectDetailPage extends StatefulWidget {
  String subjectId;

  SubjectDetailPage(this.subjectId);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SubjectDetailPage(subjectId);
  }
}

class _SubjectDetailPage extends State<SubjectDetailPage> {
  String title = '加载中';
  String cover = 'http://manhua.dmzj.com/css/img/mh_logo_dmzj.png?t=20131122';
  String description = '加载中';
  String subjectId;
  List list = <Widget>[];

  _SubjectDetailPage(this.subjectId);

  void getSubjectDetail() async {
    CustomHttp http = CustomHttp();
    var response = await http.getSubjectDetail(subjectId);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        cover = response.data['mobile_header_pic'];
        title = response.data['title'];
        description = response.data['description'];
        for (var item in response.data['comics']) {
          list.add(CustomListTile(
              item['cover'],
              item['name'],
              item['recommend_brief'],
              item['recommend_reason'],
              item['id'].toString()));
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSubjectDetail();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('$title'),
        ),
        body: Scrollbar(
            child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.fromLTRB(3, 0, 0, 10),
            child: Column(
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
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Text('$description'),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return list[index];
                    })
              ],
            ),
          ),
        )));
  }
}

class CustomListTile extends StatelessWidget {
  final String cover;
  final String title;
  final String recommendBrief;
  final String recommendReason;
  final String comicId;

  CustomListTile(this.cover, this.title, this.recommendBrief,
      this.recommendReason, this.comicId);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
        child: FlatButton(
      padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ComicDetailPage(comicId);
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
                  Text(
                    title,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    recommendBrief,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        recommendReason,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
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
