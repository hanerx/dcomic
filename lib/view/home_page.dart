import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/CardView.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  List list = <Widget>[];
  static List allowedCategroy = <int>[47, 48, 52, 53, 54, 55, 56];
  bool refreshState = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSubscribe();
    getMainPage();
  }

  getSubscribe() async {
    DataBase dataBase = DataBase();
    var login = await dataBase.getLoginState();
    if (login) {
      CustomHttp http = CustomHttp();
      var response =
          await http.getRecommendBatchUpdate(await dataBase.getUid());
      if (response.statusCode == 200 && mounted) {
        setState(() {
          list.insert(
              0,
              CardView(response.data['data']['title'],
                  response.data['data']['data'], 3, 49));
        });
      }
    }
  }

  getMainPage() async {
    CustomHttp http = CustomHttp();
    var response = await http.getMainPageRecommend();
    if (response.statusCode == 200) {
      List data = response.data;
      if (this.mounted) {
        setState(() {
          data.forEach((item) {
            if (allowedCategroy.indexOf(item['category_id']) >= 0) {
              if (item['data'].length % 3 == 0) {
                list.add(new CardView(
                    item['title'], item['data'], 3, item['category_id']));
              } else {
                list.add(new CardView(
                    item['title'], item['data'], 2, item['category_id']));
              }
            }
          });
          refreshState = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshIndicator(
      child: new Scrollbar(
        child: new SingleChildScrollView(
            child: Column(
          children: list,
        )),
      ),
      onRefresh: () async {
        if (!refreshState) {
          setState(() {
            refreshState=true;
            list.clear();
          });
          await getSubscribe();
          await getMainPage();
        }
        return;
      },
    );
  }
}
