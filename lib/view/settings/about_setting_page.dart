import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:flutterdmzj/model/versionModel.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';

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
        title: Text(S.of(context).SettingPageMainAboutTitle),
      ),
      body: ListView(
        children: [
          Builder(
            builder: (context) {
              return ListTile(
                title: Text(S.of(context).SettingPageCheckUpdateTitle),
                subtitle: Text(S.of(context).SettingPageCheckUpdateSubtitle(
                    Provider.of<VersionModel>(context).currentVersion)),
                onTap: () async {
                  await Provider.of<VersionModel>(context, listen: false)
                      .checkUpdate();
                  if (ToolMethods.checkVersionSemver(
                      Provider.of<VersionModel>(context, listen: false)
                          .currentVersion,
                      Provider.of<VersionModel>(context, listen: false)
                          .latestVersion)) {
                    Provider.of<VersionModel>(context, listen: false)
                        .showUpdateDialog(context);
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(S.of(context).CheckUpdateUpToDate),
                    ));
                  }
                },
              );
            },
          ),
          ListTile(
            title: Text(S.of(context).SettingPageUpdateChannelTitle),
            subtitle: Text(S.of(context).SettingPageUpdateChannelSubtitle(S
                .of(context)
                .SettingPageUpdateChannels(
                    Provider.of<VersionModel>(context).updateChannelName))),
            onTap: () {
              Provider.of<VersionModel>(context, listen: false).updateChannel++;
            },
          ),
          Divider(),
          ListTile(
            title: Text(S.of(context).SettingPageProjectURLTitle),
            subtitle: Text(S.of(context).SettingPageProjectURL),
            onTap: () {
              ToolMethods.callWeb(S.of(context).SettingPageProjectURL, context);
            },
          ),
          ListTile(
            title: Text(S.of(context).SettingPageAboutTitle),
            subtitle: Text(S.of(context).SettingPageAboutSubtitle),
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
                        Text(S.of(context).SettingPageAboutDescription),
                      ],
                    );
                  });
            },
          ),
          ListTile(
            title: Text(S.of(context).SettingPageChangeLogTitle),
            subtitle: Text(S.of(context).SettingPageChangeLogSubtitle),
            onTap: () async {
              CustomHttp http = CustomHttp();
              var response = await http.getReleases();
              if (response.statusCode == 200) {
                var data = "";
                for (var item in response.data) {
                  data += S.of(context).SettingPageChangeLogContent(
                      item['name'], item['published_at'], item['body']);
                }
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(S.of(context).SettingPageChangeLogTitle),
                        content: Container(
                          width: 400,
                          height: 700,
                          child: MarkdownWidget(
                            data: data,
                            styleConfig: StyleConfig(
                              pConfig: PConfig(
                                onLinkTap: (url){
                                  ToolMethods.callWeb(url, context);
                                }
                              )
                            ),
                          ),
                        ),
                      );
                    });
              }
            },
          ),
        ],
      ),
    );
  }
}
