import 'package:dcomic/component/Card.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/subjectListModel.dart';
import 'package:dcomic/view/subject_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class SubjectListPage extends StatefulWidget {
  final BaseSourceModel model;

  const SubjectListPage({Key key, this.model}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SubjectListPage();
  }
}

class _SubjectListPage extends State<SubjectListPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => SubjectListModel(widget.model),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text('专题'),
        ),
        body: EasyRefresh(
          emptyWidget: Provider.of<SubjectListModel>(context).length == 0 ||
                  Provider.of<SubjectListModel>(context).error != null
              ? EmptyView(
                  message: Provider.of<SubjectListModel>(context).error,
                )
              : null,
          onLoad: () async {
            await Provider.of<SubjectListModel>(context, listen: false).next();
          },
          onRefresh: () async {
            await Provider.of<SubjectListModel>(context, listen: false)
                .refresh();
          },
          firstRefreshWidget: LoadingCube(),
          firstRefresh: true,
          child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: Provider.of<SubjectListModel>(context).length,
              itemBuilder: (context, index) {
                var item = Provider.of<SubjectListModel>(context, listen: false)
                    .data[index];
                return HomePageCard(
                  imageUrl: item.cover,
                  title: item.title,
                  subtitle: item.subtitle,
                  onPressed: (context) => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => SubjectDetailPage(
                                subjectId: item.subjectId,
                                model: item.model,
                              ),
                          settings:
                              RouteSettings(name: 'subject_detail_page'))),
                );
              }),
        ),
      ),
    );
  }
}
