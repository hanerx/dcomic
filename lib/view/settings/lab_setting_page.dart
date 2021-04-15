import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/model/systemSettingModel.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:provider/provider.dart';

class LabSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LabSettingPage();
  }
}

class _LabSettingPage extends State<LabSettingPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('实验功能'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('隐藏漫画搜索功能'),
            subtitle: Text(
                '通过调用奇葩的接口实现把一部分隐藏的漫画显示出来，该功能会讲搜索变成两部分，一部分使用普通搜索，另一部分使用隐藏搜索'),
            trailing: Switch(
              onChanged: (val) {
                Provider.of<SystemSettingModel>(context, listen: false)
                    .deepSearch = val;
              },
              value: Provider.of<SystemSettingModel>(context).deepSearch,
            ),
            onTap: () {
              Provider.of<SystemSettingModel>(context, listen: false)
                      .deepSearch =
                  !Provider.of<SystemSettingModel>(context, listen: false)
                      .deepSearch;
            },
          ),
          ListTile(
            title: Text('黑匣子'),
            subtitle: Text('在本地记录漫画id，方便想看的时候直接找，适用于在订阅里消失的漫画'),
            onTap: () {
              Provider.of<SystemSettingModel>(context, listen: false).blackBox =
                  !Provider.of<SystemSettingModel>(context, listen: false)
                      .blackBox;
            },
            trailing: Switch(
              value: Provider.of<SystemSettingModel>(context).blackBox,
              onChanged: (bool value) {
                Provider.of<SystemSettingModel>(context, listen: false)
                    .blackBox = value;
              },
            ),
          ),
          ListTile(
            title: Text('黑暗面'),
            subtitle: Text.rich(TextSpan(children: [
              TextSpan(text: '这个是通过GitHub上一位大佬的接口实现的影藏漫画查看功能，地址：'),
              TextSpan(
                  text: 'https://github.com/torta/dark-dmzj',
                  style: TextStyle(color: Theme.of(context).accentColor)),
              TextSpan(text: ' 长按跳转至项目')
            ])),
            trailing: Switch(
              value: Provider.of<SystemSettingModel>(context).darkSide,
              onChanged: (bool value) {
                Provider.of<SystemSettingModel>(context, listen: false)
                    .darkSide = value;
              },
            ),
            onLongPress: () {
              ToolMethods.callWeb(
                  'https://github.com/torta/dark-dmzj', context);
            },
            onTap: () {
              Provider.of<SystemSettingModel>(context, listen: false).darkSide =
                  !Provider.of<SystemSettingModel>(context, listen: false)
                      .darkSide;
            },
          ),
          Divider(),
          ListTile(
            title: Text('小说功能'),
            subtitle: Text('欸，我还真把卫星放下来了'),
            trailing: Switch(
              value: Provider.of<SystemSettingModel>(context).novel,
              onChanged: (value) {
                Provider.of<SystemSettingModel>(context, listen: false).novel =
                    value;
              },
            ),
            onTap: () {
              Provider.of<SystemSettingModel>(context, listen: false).novel =
                  !Provider.of<SystemSettingModel>(context, listen: false)
                      .novel;
            },
          )
        ],
      ),
    );
  }
}
