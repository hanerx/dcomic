import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:dcomic/model/homepageModel.dart';
import 'package:dcomic/view/comic_pages/subject_list_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/CardView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/view/favorite_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) =>
          HomepageModel(Provider.of<SourceProvider>(context).activeHomeModel),
      builder: (context, child) => EasyRefresh(
        firstRefreshWidget: LoadingCube(),
        firstRefresh: true,
        onRefresh: () async {
          await Provider.of<HomepageModel>(context, listen: false).init();
        },
        header: ClassicalHeader(
            refreshedText: '刷新完成',
            refreshFailedText: '刷新失败',
            refreshingText: '刷新中',
            refreshText: '下拉刷新',
            refreshReadyText: '释放刷新'),
        child: Column(
          children: Provider.of<HomepageModel>(context)
              .data
              .map<Widget>((e) => CardView(
                    title: e.title,
                    list: e.detail,
                    row: e.detail.length % 3 == 0 ? 3 : 2,
                    ratio: e.detail.length % 3 == 0 ? 0.6 : 1.5,
                    action: e.action == null ? null : e.action(context),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
