import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/component/comic/SubjectListTile.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:dcomic/model/subjectDetailModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_parallax/flutter_parallax.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/view/comic_detail_page.dart';
import 'package:provider/provider.dart';

class SubjectDetailPage extends StatefulWidget {
  final String subjectId;
  final BaseSourceModel model;

  SubjectDetailPage({this.subjectId, this.model});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SubjectDetailPage();
  }
}

class _SubjectDetailPage extends State<SubjectDetailPage> {
  List list = <Widget>[];

  _SubjectDetailPage();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => SubjectDetailModel(widget.subjectId, widget.model),
      builder: (context, child) => Scaffold(
          appBar: AppBar(
            title: Text('${Provider.of<SubjectDetailModel>(context).title}'),
          ),
          body: EasyRefresh(
            firstRefreshWidget: LoadingCube(),
            firstRefresh: true,
            onRefresh: () async {
              await Provider.of<SubjectDetailModel>(context, listen: false)
                  .getSubjectDetail();
            },
            emptyWidget: Provider.of<SubjectDetailModel>(context).error == null
                ? null
                : EmptyView(
                    message: Provider.of<SubjectDetailModel>(context).error,
                  ),
            child: Container(
              margin: EdgeInsets.fromLTRB(3, 0, 0, 10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Parallax.inside(
                          child: Image(
                              image: CachedNetworkImageProvider(
                                  Provider.of<SubjectDetailModel>(context)
                                      .cover,
                                  headers:
                                      Provider.of<SubjectDetailModel>(context)
                                          .headers),
                              fit: BoxFit.cover),
                          mainAxisExtent: 200.0,
                        ),
                      )
                    ],
                  ),
                  Card(
                      elevation: 0,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(4, 2, 4, 10),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    Provider.of<SubjectDetailModel>(context)
                                        .title,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                      Provider.of<SubjectDetailModel>(context)
                                          .description),
                                )
                              ],
                            )
                          ],
                        ),
                      )),
                  Card(
                    elevation: 0,
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: Provider.of<SubjectDetailModel>(context)
                            .data
                            .length,
                        itemBuilder: (context, index) {
                          var item = Provider.of<SubjectDetailModel>(context,
                                  listen: false)
                              .data[index];
                          return SubjectListTile(
                            cover: item.cover,
                            title: item.title,
                            recommendBrief: item.brief,
                            recommendReason: item.reason,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ComicDetailPage(
                                        id: item.comicId,
                                        title: item.title,
                                        model: widget.model,
                                      ),
                                  settings: RouteSettings(
                                      name: 'comic_detail_page')));
                            },
                          );
                        }),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
