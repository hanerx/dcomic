import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/model/comicViewerSettingModel.dart';
import 'package:provider/provider.dart';

class ReaderSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ReaderSettingPage();
  }
}

class _ReaderSettingPage extends State<ReaderSettingPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => ComicViewerSettingModel(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).SettingPageMainReadingTitle),
          ),
          body: ListView(
            children: [
              ListTile(
                title: Text("阅读方向"),
                subtitle: Text(
                    "${Provider.of<ComicViewerSettingModel>(context).direction ? '横向阅读' : '纵向阅读'}"),
                onTap: () {
                  Provider.of<ComicViewerSettingModel>(context, listen: false)
                      .direction = !Provider.of<ComicViewerSettingModel>(
                          context,
                          listen: false)
                      .direction;
                },
              ),
              ListTile(
                title: Text('横向阅读方向'),
                subtitle: Text(
                    '${Provider.of<ComicViewerSettingModel>(context).reverse ? '从右到左' : '从左到右'}'),
                enabled:
                    Provider.of<ComicViewerSettingModel>(context).direction,
                onTap: () {
                  Provider.of<ComicViewerSettingModel>(context, listen: false)
                      .reverse = !Provider.of<ComicViewerSettingModel>(context,
                          listen: false)
                      .reverse;
                },
              ),
              ListTile(
                title: Text('翻页动画设置'),
                subtitle: Text(
                    '${Provider.of<ComicViewerSettingModel>(context).animation ? '启用动画' : '禁用动画'}'),
                enabled:
                    Provider.of<ComicViewerSettingModel>(context).direction,
                onTap: () {
                  Provider.of<ComicViewerSettingModel>(context, listen: false)
                      .animation = !Provider.of<ComicViewerSettingModel>(
                          context,
                          listen: false)
                      .animation;
                },
              ),
              Divider(),
              ListTile(
                title: Text('碰撞体积'),
                subtitle: Slider(
                  min: 0,
                  max: 200,
                  value: Provider.of<ComicViewerSettingModel>(context).hitBox,
                  onChanged: (value) {
                    Provider.of<ComicViewerSettingModel>(context, listen: false)
                        .hitBox = value;
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text("翻页距离"),
                subtitle: Slider(
                  label: "垂直翻页使用固定距离翻页法，在这调整翻页距离",
                  min: 100,
                  max: 1000,
                  value: Provider.of<ComicViewerSettingModel>(context).range,
                  onChanged: (value) {
                    Provider.of<ComicViewerSettingModel>(context, listen: false)
                        .range = value;
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text('阅读器背景自动夜间模式'),
                subtitle: Text('启用后不管你选择了任何背景颜色，在进入夜间模式后均会自动变成黑色'),
                trailing: Switch(
                  value: Provider.of<ComicViewerSettingModel>(context).autoDark,
                  onChanged: (value) {
                    Provider.of<ComicViewerSettingModel>(context, listen: false)
                        .autoDark = value;
                  },
                ),
              ),
              Container(
                child: ListTile(
                  title: Text(
                    '背景颜色',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Row(
                    children: ComicViewerSettingModel.backgroundColors
                        .map<Widget>((e) => IconButton(
                              icon: Icon(
                                Icons.color_lens,
                                color: e,
                              ),
                              onPressed: () {
                                Provider.of<ComicViewerSettingModel>(context,
                                            listen: false)
                                        .backgroundColor =
                                    ComicViewerSettingModel.backgroundColors
                                        .indexOf(e);
                              },
                            ))
                        .toList(),
                  ),
                ),
                decoration: BoxDecoration(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
