import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:flutterdmzj/model/versionModel.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';
import 'package:version/version.dart';

class AboutSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AboutSettingPage();
  }
}

class _AboutSettingPage extends State<AboutSettingPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).SettingPageMainAboutTitle,
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0.0,
          brightness: Brightness.dark,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            EasyRefresh.custom(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate([
                    // 顶部栏
                    new Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 220.0,
                          color: Colors.white,
                        ),
                        ClipPath(
                          clipper: new TopBarClipper(
                              MediaQuery.of(context).size.width, 200.0),
                          child: new SizedBox(
                            width: double.infinity,
                            height: 200.0,
                            child: new Container(
                              width: double.infinity,
                              height: 240.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        // 名字
                        Container(
                          margin: new EdgeInsets.only(top: 30.0),
                          child: new Center(
                            child: new Text(
                              S.of(context).AppName,
                              style: new TextStyle(
                                  fontSize: 30.0, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // 图标
                        Container(
                          margin: new EdgeInsets.only(top: 100.0),
                          child: new Center(
                              child: new Container(
                            width: 100.0,
                            height: 100.0,
                            child: new PreferredSize(
                              child: new Container(
                                child: new ClipOval(
                                  child: new Container(
                                    color: Colors.white,
                                    child: FlutterLogo(),
                                  ),
                                ),
                              ),
                              preferredSize: new Size(80.0, 80.0),
                            ),
                          )),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 70),
                          child: Center(
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                  text:
                                      '${Provider.of<VersionModel>(context).currentVersion}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                    text:
                                        ' ${Version.parse(Provider.of<VersionModel>(context).currentVersion).preRelease.length > 0 ? 'beta' : 'release'}',
                                    style: TextStyle(color: Version.parse(Provider.of<VersionModel>(context).currentVersion).preRelease.length > 0?Colors.deepOrange:Colors.lightGreen))
                              ]),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                    // 内容
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      child: ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Builder(
                            builder: (context) {
                              return InkWell(child:ListTile(
                                title: Text(
                                    S.of(context).SettingPageCheckUpdateTitle),
                                subtitle: Text(S
                                    .of(context)
                                    .SettingPageCheckUpdateSubtitle(
                                        Provider.of<VersionModel>(context)
                                            .currentVersion)),
                                onTap: () async {
                                  await Provider.of<VersionModel>(context,
                                          listen: false)
                                      .checkUpdate();
                                  if (ToolMethods.checkVersionSemver(
                                      Provider.of<VersionModel>(context,
                                              listen: false)
                                          .currentVersion,
                                      Provider.of<VersionModel>(context,
                                              listen: false)
                                          .latestVersion)) {
                                    Provider.of<VersionModel>(context,
                                            listen: false)
                                        .showUpdateDialog(context);
                                  } else {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                          S.of(context).CheckUpdateUpToDate),
                                    ));
                                  }
                                },
                              ));
                            },
                          ),
                          InkWell(
                            child: ListTile(
                              title: Text(
                                  S.of(context).SettingPageUpdateChannelTitle),
                              subtitle: Text(S
                                  .of(context)
                                  .SettingPageUpdateChannelSubtitle(S
                                  .of(context)
                                  .SettingPageUpdateChannels(
                                  Provider.of<VersionModel>(context)
                                      .updateChannelName))),
                              onTap: () {
                                Provider.of<VersionModel>(context, listen: false)
                                    .updateChannel++;
                              },
                            ),
                          ),
                          Divider(),
                          InkWell(
                            child: ListTile(
                              title:
                              Text(S.of(context).SettingPageProjectURLTitle),
                              subtitle: Text(S.of(context).SettingPageProjectURL),
                              onTap: () {
                                ToolMethods.callWeb(
                                    S.of(context).SettingPageProjectURL, context);
                              },
                            ),
                          ),
                          InkWell(
                            child: ListTile(
                              title: Text(S.of(context).SettingPageAboutTitle),
                              subtitle:
                              Text(S.of(context).SettingPageAboutSubtitle),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AboutDialog(
                                        applicationName:
                                        '${Provider.of<SystemSettingModel>(context).backupApi ? S.of(context).AppNameUltimate : S.of(context).AppName}',
                                        applicationVersion:
                                        '${Provider.of<VersionModel>(context).currentVersion}',
                                        applicationIcon: FlutterLogo(),
                                        children: <Widget>[
                                          Text(S
                                              .of(context)
                                              .SettingPageAboutDescription),
                                        ],
                                      );
                                    });
                              },
                            ),
                          ),
                          InkWell(
                            child: ListTile(
                              title:
                              Text(S.of(context).SettingPageChangeLogTitle),
                              subtitle: Text(
                                  S.of(context).SettingPageChangeLogSubtitle),
                              onTap: () async {
                                CustomHttp http = CustomHttp();
                                var response = await http.getReleases();
                                if (response.statusCode == 200) {
                                  var data = "";
                                  for (var item in response.data) {
                                    data += S
                                        .of(context)
                                        .SettingPageChangeLogContent(item['name'],
                                        item['published_at'], item['body']);
                                  }
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(S
                                              .of(context)
                                              .SettingPageChangeLogTitle),
                                          content: Container(
                                            width: 400,
                                            height: 700,
                                            child: MarkdownWidget(
                                              data: data,
                                              styleConfig: StyleConfig(pConfig:
                                              PConfig(onLinkTap: (url) {
                                                ToolMethods.callWeb(url, context);
                                              })),
                                            ),
                                          ),
                                        );
                                      });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ]),
                ),
              ],
            ),
          ],
        ));

  }
}

class TopBarClipper extends CustomClipper<Path> {
  // 宽高
  double width;
  double height;

  TopBarClipper(this.width, this.height);

  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(width, 0.0);
    path.lineTo(width, height / 2);
    path.lineTo(0.0, height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
