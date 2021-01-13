import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/model/databaseDetailModel.dart';
import 'package:provider/provider.dart';

class DatabaseDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DatabaseDetailPage();
  }
}

class _DatabaseDetailPage extends State<DatabaseDetailPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => DatabaseDetailModel(),
      builder: (context, child) {
        return DefaultTabController(
          length: Provider.of<DatabaseDetailModel>(context).tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text('数据库详情'),
              bottom: TabBar(
                tabs:
                    Provider.of<DatabaseDetailModel>(context).getTabs(context),
                isScrollable: true,
              ),
            ),
            endDrawer: Drawer(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      UserAccountsDrawerHeader(
                          accountName: Text('程序内置数据库 '),
                          accountEmail: Text('基于sqlfilte')),
                      ListTile(
                        title: Text('数据库版本'),
                        subtitle: Text(
                            '${Provider.of<DatabaseDetailModel>(context).version}'),
                      ),
                      ListTile(
                        title: Text('数据库地址'),
                        subtitle: Text(
                            '${Provider.of<DatabaseDetailModel>(context).path}'),
                      ),
                      ListTile(
                        title: Text('当前数据库表数量'),
                        subtitle: Text(
                            '${Provider.of<DatabaseDetailModel>(context).tabs.length}'),
                      ),
                      Divider(),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: Provider.of<DatabaseDetailModel>(context)
                        .getDatabaseDefine,
                    itemCount:
                        Provider.of<DatabaseDetailModel>(context).tabs.length,
                  )
                ],
              ),
            )),
            body: TabBarView(
              children: Provider.of<DatabaseDetailModel>(context)
                  .getTabViews(context),
            ),
          ),
        );
      },
    );
  }
}
