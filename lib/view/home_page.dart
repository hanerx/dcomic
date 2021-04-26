import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
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
  List list = <Widget>[];
  static List allowedCategory = <int>[47, 48, 52, 53, 54, 55, 56];
  bool refreshState = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getSubscribe() async {
    bool login =
        await SourceDatabaseProvider.getSourceOption<bool>('dmzj', 'login');
    if (login) {
      var uid = await SourceDatabaseProvider.getSourceOption('dmzj', 'uid');
      try {
        var response = await UniversalRequestModel.dmzjRequestHandler.getUpdateBatch(uid);
        if (response.statusCode == 200 && mounted) {
          setState(() {
            list.insert(
                0,
                CardView(
                    title: response.data['data']['title'],
                    list: response.data['data']['data'],
                    row: 3,
                    ratio: 0.7,
                    categoryId: 49,
                    action: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return FavoritePage();
                            },
                            settings: RouteSettings(name: 'favorite_page')));
                      },
                      icon: Icon(Icons.arrow_forward_ios),
                    )));
            refreshState = false;
          });
        }
      } catch (e) {}
    }
  }

  getMainPage() async {
    try {
      var response =
          await UniversalRequestModel.dmzjRequestHandler.getMainPageRecommend();
      if (response.statusCode == 200) {
        List data = response.data;
        if (this.mounted) {
          setState(() {
            data.forEach((item) {
              if (allowedCategory.indexOf(item['category_id']) >= 0) {
                if (item['data'].length % 3 == 0) {
                  list.add(new CardView(
                      title: item['title'],
                      list: item['data'],
                      row: 3,
                      categoryId: item['category_id']));
                } else if (item['category_id'] == 48) {
                  list.add(CardView(
                    title: item['title'],
                    list: item['data'],
                    row: 2,
                    ratio: 1.4,
                    categoryId: item['category_id'],
                    action: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return SubjectListPage(
                                model: Provider.of<SourceProvider>(context,
                                        listen: false)
                                    .activeSources
                                    .first,
                              );
                            },
                            settings:
                                RouteSettings(name: 'subject_list_page')));
                      },
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ));
                } else {
                  list.add(new CardView(
                      title: item['title'],
                      list: item['data'],
                      row: 2,
                      ratio: 1.4,
                      categoryId: item['category_id']));
                }
              }
            });
          });
          await getSubscribe();
        }
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'MainPageLoadingFailed');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return EasyRefresh(
      firstRefreshWidget: LoadingCube(),
      firstRefresh: true,
      onRefresh: () async {
        setState(() {
          refreshState = true;
          list.clear();
        });
        await getMainPage();
      },
      header: ClassicalHeader(
          refreshedText: '刷新完成',
          refreshFailedText: '刷新失败',
          refreshingText: '刷新中',
          refreshText: '下拉刷新',
          refreshReadyText: '释放刷新'),
      child: Column(
        children: list,
      ),
    );
  }
}
