import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/CardView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/database/database.dart';
import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/view/favorite_page.dart';

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
    bool login=await SourceDatabaseProvider.getSourceOption<bool>('dmzj', 'login');
    if (login) {
      CustomHttp http = CustomHttp();
      var uid = await SourceDatabaseProvider.getSourceOption('dmzj', 'uid');
      try{
        var response = await http.getRecommendBatchUpdate(uid);
        if (response.statusCode == 200 && mounted) {
          setState(() {
            list.insert(
                0,
                CardView.action(
                    response.data['data']['title'],
                    response.data['data']['data'],
                    3,
                    49,
                    IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return FavoritePage(uid);
                        }));
                      },
                      icon: Icon(Icons.arrow_forward_ios),
                    )));
            refreshState = false;
          });
        }
      }catch(e){

      }
    }
  }

  getMainPage() async {
    CustomHttp http = CustomHttp();
    try{
      var response = await http.getMainPageRecommend();
      if (response.statusCode == 200) {
        List data = response.data;
        if (this.mounted) {
          setState(() {
            data.forEach((item) {
              if (allowedCategory.indexOf(item['category_id']) >= 0) {
                if (item['data'].length % 3 == 0) {
                  list.add(new CardView(
                      item['title'], item['data'], 3, item['category_id']));
                } else {
                  list.add(new CardView(
                      item['title'], item['data'], 2, item['category_id']));
                }
              }
            });
          });
          await getSubscribe();
        }
      }
    }catch(e){

    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return EasyRefresh(
      firstRefreshWidget: LoadingCube(),
      firstRefresh: true,
      onRefresh: ()async{
        setState(() {
          refreshState=true;
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
