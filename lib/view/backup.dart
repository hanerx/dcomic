// // child: Swiper(
// //   indicatorLayout: PageIndicatorLayout.SLIDE,
// //   viewportFraction: direction ? viewFraction : 1.0,
// //   controller: _controller,
// //   control: click
// //       ? CustomSwiperControl(size: controlSize, debug: debug)
// //       : null,
// //   scrollDirection: direction ? Axis.vertical : Axis.horizontal,
// //   index: index,
// //   loop: false,
// //   itemCount: list.length + 2,
// //   itemBuilder: (context, index) {
// //     if (index > 0 && index < list.length + 1) {
// //       return list[index - 1];
// //     } else if (index == list.length + 1 &&
// //         (next == null || next == '')) {
// //       return EndPage();
// //     } else if (index == 0 && (previous == null || previous == '')) {
// //       return EndPage();
// //     } else {
// //       return LoadingRow();
// //     }
// //   },
// //   onIndexChanged: (index) {
// //     if (refreshState == false && index == 0) {
// //       if (previous == null || previous == '') {
// //         return;
// //       }
// //       setState(() {
// //         refreshState = true;
// //       });
// //       getComic(comicId, previous, true);
// //       return;
// //     }
// //     if (refreshState == false && index == list.length + 1) {
// //       if (next == null || next == '') {
// //         return;
// //       }
// //       setState(() {
// //         refreshState = true;
// //       });
// //       getComic(comicId, next, false);
// //       return;
// //     }
// //     if (index > 0 && index < list.length + 1) {
// //       setState(() {
// //         pageAt = list[index - 1].chapterId;
// //         title = list[index - 1].title;
// //         this.index = index;
// //       });
// //     } else {
// //       setState(() {
// //         this.index = index;
// //       });
// //     }
// //     setState(() {
// //       hiddenAppbar = true;
// //     });
// //     SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
// //   },
// //   onTap: (index) {
// //     setState(() {
// //       hiddenAppbar = !hiddenAppbar;
// //     });
// //     if (!hiddenAppbar) {
// //       SystemChrome.setEnabledSystemUIOverlays(
// //           [SystemUiOverlay.top, SystemUiOverlay.bottom]);
// //     } else {
// //       SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
// //     }
// //   },
// //
// // ),
//
//
// // @Deprecated("用更好的AppBar替代了")
// // List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
// //   return <Widget>[
// //     SliverAppBar(
// //       title: Text('$title'),
// //       snap: true,
// //       floating: true,
// //       actions: <Widget>[
// //         FlatButton(
// //           child: Icon(
// //             Icons.chat,
// //             color: Colors.white,
// //           ),
// //           onPressed: () async {
// //             await getViewPoint();
// //             showModalBottomSheet(
// //                 context: context,
// //                 builder: (context) {
// //                   return Container(
// //                     height: 400,
// //                     padding: EdgeInsets.all(0),
// //                     child: SingleChildScrollView(
// //                         child: Column(
// //                           children: <Widget>[
// //                             Padding(
// //                               padding: EdgeInsets.all(5),
// //                               child: Text('吐槽'),
// //                             ),
// //                             Divider(),
// //                             Wrap(
// //                               children: viewPointList,
// //                             ),
// //                           ],
// //                         )),
// //                   );
// //                 });
// //           },
// //         )
// //       ],
// //     )
// //   ];
// // }
//
// String version = '';
// String appName = '';
// bool direction = false;
// bool cover = false;
// bool labState = false;
// bool nomedia = false;
// String downloadPath = '';
// static const List darkMode = ['followSystem', 'brightness', 'darkness'];
//
// Future<bool> getCoverType() async {
//   DataBase dataBase = DataBase();
//   bool cover = await dataBase.getCoverType();
//   setState(() {
//     this.cover = cover;
//   });
//   return true;
// }
//
// getDownloadPath() async {
//   DataBase dataBase = DataBase();
//   String path = await dataBase.getDownloadPath();
//   setState(() {
//     downloadPath = path;
//   });
//   getMedia();
// }
//
// setDownloadPath() async {
//   DataBase dataBase = DataBase();
//   dataBase.setDownloadPath(downloadPath);
// }
//
// setCoverType() {
//   DataBase dataBase = DataBase();
//   dataBase.setCoverType(cover);
// }
//
// getVersionInfo() async {
//   PackageInfo packageInfo = await PackageInfo.fromPlatform();
//   setState(() {
//     version = packageInfo.version;
//     appName = packageInfo.appName;
//   });
// }
//
// getReadDirection() async {
//   DataBase dataBase = DataBase();
//   bool direction = await dataBase.getReadDirection();
//   setState(() {
//     this.direction = direction;
//   });
// }
//
// setReadDirection() {
//   DataBase dataBase = DataBase();
//   dataBase.setReadDirection(direction);
// }
//
// getLabState() async {
//   DataBase dataBase = DataBase();
//   bool state = await dataBase.getLabState();
//   setState(() {
//     labState = state;
//   });
// }
//
// getMedia() async {
//   var file = File('$downloadPath/.nomedia');
//   var media = await file.exists();
//   setState(() {
//     nomedia = media;
//   });
// }
//
// @override
// void initState() {
//   // TODO: implement initState
//   super.initState();
//   getVersionInfo();
//   getReadDirection();
//   getCoverType();
//   getLabState();
//   getDownloadPath();
// }
//
// _openWeb(String url) async {
//   if (await canLaunch(url)) {
//     await launch(url);
//   } else {
//     Scaffold.of(context).showSnackBar(SnackBar(
//       content: Text(S.of(context).CannotOpenWeb),
//     ));
//   }
// }
//
// @override
// Widget build(BuildContext context) {
//   // TODO: implement build
//   return Scaffold(
//       appBar: AppBar(
//         title: Text(S.of(context).Setting),
//       ),
//       body: ListView(
//         children: <Widget>[
//           ListTile(
//             title: Text(S.of(context).SettingPageReadDirectionTitle),
//             subtitle: Text(
//                 '${direction ? S.of(context).SettingPageReadDirectionHorizontal : S.of(context).SettingPageReadDirectionVertical}'),
//             onTap: () {
//               setState(() {
//                 direction = !direction;
//               });
//               setReadDirection();
//             },
//           ),
//           ListTile(
//             title: Text(S.of(context).SettingPageDarkModeTitle),
//             subtitle: Text(S.of(context).SettingPageDarkModeSubtitle(S
//                 .of(context)
//                 .SettingPageDarkModeModes(darkMode[
//             Provider.of<SystemSettingModel>(context).darkState]))),
//             onTap: () {
//               if (Provider.of<SystemSettingModel>(context, listen: false)
//                   .darkState <
//                   darkMode.length - 1) {
//                 Provider.of<SystemSettingModel>(context, listen: false)
//                     .darkState++;
//               } else {
//                 Provider.of<SystemSettingModel>(context, listen: false)
//                     .darkState = 0;
//               }
//             },
//           ),
//           Divider(),
//           ListTile(
//             title: Text(S.of(context).SettingPageSavePath),
//             subtitle: Text('$downloadPath'),
//             onTap: () async {
//               String result = await FilePicker.platform.getDirectoryPath();
//               if (result != null) {
//                 setState(() {
//                   downloadPath = result;
//                 });
//                 setDownloadPath();
//               }
//             },
//           ),
//           ListTile(
//             title: Text(S.of(context).SettingPageNoMediaTitle),
//             subtitle: Text(S.of(context).SettingPageNoMediaSubtitle),
//             trailing: Switch(
//               value: nomedia,
//               onChanged: (value) async {
//                 var file = File('$downloadPath/.nomedia');
//                 if (value) {
//                   if (await file.exists()) {
//                     return;
//                   } else {
//                     file.create(recursive: true);
//                   }
//                 } else {
//                   if (await file.exists()) {
//                     file.delete();
//                   }
//                 }
//                 setState(() {
//                   nomedia = !nomedia;
//                 });
//               },
//             ),
//           ),
//           Divider(),
//           ListTile(
//             title: Text(S.of(context).SettingPageDatabaseDetailTitle),
//             subtitle: Text(S.of(context).SettingPageDatabaseDetailSubtitle),
//             onTap: () {
//               Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => DatabaseDetailPage()));
//             },
//           ),
//           ListTile(
//             title: Text(S.of(context).SettingPageResetDatabaseTitle),
//             subtitle: Text(S.of(context).SettingPageResetDatabaseSubtitle),
//             onTap: () {
//               showDialog(
//                   context: context,
//                   builder: (context) {
//                     return AlertDialog(
//                       title: Text(
//                           S.of(context).SettingPageResetDatabaseConfirmTitle),
//                       content: Text(S
//                           .of(context)
//                           .SettingPageResetDatabaseConfirmDescription),
//                       actions: [
//                         FlatButton(
//                           child: Text(S.of(context).Cancel),
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                         ),
//                         FlatButton(
//                           child: Text(S.of(context).Confirm),
//                           onPressed: () {
//                             DataBase dataBase = DataBase();
//                             dataBase.resetDataBase();
//                             Navigator.of(context).pop();
//                             Navigator.of(context).pop();
//                           },
//                         )
//                       ],
//                     );
//                   });
//             },
//           ),
//           Divider(),
//           ListTile(
//             title: Text(S.of(context).SettingPageResetDioCacheTitle),
//             subtitle: Text(S.of(context).SettingPageResetDioCacheSubtitle),
//             onTap: () {
//               showDialog(
//                   context: context,
//                   builder: (context) {
//                     return AlertDialog(
//                       title: Text(
//                           S.of(context).SettingPageResetDioCacheConfirmTitle),
//                       content: Text(S
//                           .of(context)
//                           .SettingPageResetDioCacheConfirmDescription),
//                       actions: [
//                         FlatButton(
//                           child: Text(S.of(context).Cancel),
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                         ),
//                         FlatButton(
//                           child: Text(S.of(context).Confirm),
//                           onPressed: () {
//                             CustomHttp().clearCache();
//                             Navigator.of(context).pop();
//                           },
//                         )
//                       ],
//                     );
//                   });
//             },
//           ),
//           Divider(),
//           ListTile(
//             title: Text(S.of(context).SettingPageCancelDownloadTasksTitle),
//             subtitle:
//             Text(S.of(context).SettingPageCancelDownloadTasksSubtitle),
//             onTap: () {
//               showDialog(
//                   context: context,
//                   builder: (context) {
//                     return AlertDialog(
//                       title: Text(S
//                           .of(context)
//                           .SettingPageCancelDownloadTasksConfirmTitle),
//                       content: Text(S
//                           .of(context)
//                           .SettingPageCancelDownloadTasksConfirmDescription),
//                       actions: [
//                         FlatButton(
//                           child: Text(S.of(context).Cancel),
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                         ),
//                         FlatButton(
//                           child: Text(S.of(context).Confirm),
//                           onPressed: () {
//                             print('class: SettingPage, action: cancelTasks');
//                             FlutterDownloader.cancelAll();
//                             Navigator.of(context).pop();
//                           },
//                         )
//                       ],
//                     );
//                   });
//             },
//           ),
//           ListTile(
//             title: Text(S.of(context).SettingPageDownloadTaskListTitle),
//             subtitle: Text(S.of(context).SettingPageDownloadTaskListSubtitle),
//             onTap: () async {
//               final tasks = await FlutterDownloader.loadTasks();
//               showDialog(
//                   context: context,
//                   builder: (context) {
//                     return SimpleDialog(
//                       title: Text(S
//                           .of(context)
//                           .SettingPageDownloadTaskListDetailTitle),
//                       titlePadding: EdgeInsets.all(10),
//                       children: tasks
//                           .map<Widget>((e) => ListTile(
//                         dense: true,
//                         leading: CircleAvatar(
//                           child: Text('${e.status.value}'),
//                         ),
//                         title: Text('${e.taskId}'),
//                         subtitle: Text('${e.url}'),
//                         trailing: Text('${e.progress}%'),
//                         onTap: () async {
//                           if (!await FlutterDownloader.open(
//                               taskId: e.taskId)) {
//                             Toast.show(
//                                 S
//                                     .of(context)
//                                     .SettingPageDownloadTaskListOpenFailed,
//                                 context,
//                                 duration: Toast.LENGTH_LONG);
//                           }
//                         },
//                         onLongPress: () {},
//                       ))
//                           .toList(),
//                     );
//                   });
//             },
//           ),
//           Divider(),
//           ListTile(
//             title: Text(S.of(context).SettingPageLogConsoleTitle),
//             subtitle: Text(S.of(context).SettingPageLogConsoleSubtitle),
//             onTap: () {
//               LogConsole.open(context);
//             },
//           ),
//           Divider(),
//           Builder(
//             builder: (context) {
//               return ListTile(
//                 title: Text(S.of(context).SettingPageCheckUpdateTitle),
//                 subtitle: Text(S.of(context).SettingPageCheckUpdateSubtitle(
//                     Provider.of<VersionModel>(context).currentVersion)),
//                 onTap: () async {
//                   await Provider.of<VersionModel>(context, listen: false)
//                       .checkUpdate();
//                   if (ToolMethods.checkVersionSemver(
//                       Provider.of<VersionModel>(context, listen: false)
//                           .currentVersion,
//                       Provider.of<VersionModel>(context, listen: false)
//                           .latestVersion)) {
//                     Provider.of<VersionModel>(context, listen: false)
//                         .showUpdateDialog(context);
//                   } else {
//                     Scaffold.of(context).showSnackBar(SnackBar(
//                       content: Text(S.of(context).CheckUpdateUpToDate),
//                     ));
//                   }
//                 },
//               );
//             },
//           ),
//           ListTile(
//             title: Text(S.of(context).SettingPageUpdateChannelTitle),
//             subtitle: Text(S.of(context).SettingPageUpdateChannelSubtitle(S
//                 .of(context)
//                 .SettingPageUpdateChannels(
//                 Provider.of<VersionModel>(context).updateChannelName))),
//             onTap: () {
//               Provider.of<VersionModel>(context, listen: false)
//                   .updateChannel++;
//             },
//           ),
//           Divider(),
//           ListTile(
//             title: Text(S.of(context).SettingPageDisclaimerTitle),
//             subtitle: Text(S.of(context).SettingPageDisclaimerSubtitle),
//             onTap: () {
//               showDialog(
//                   context: context,
//                   builder: (context) {
//                     return SimpleDialog(
//                       title: Text(S.of(context).SettingPageDisclaimerTitle),
//                       titlePadding: EdgeInsets.all(10),
//                       children: <Widget>[
//                         SimpleDialogOption(
//                           child: Text(
//                               S.of(context).SettingPageDisclaimerDetail1),
//                         ),
//                         SimpleDialogOption(
//                           child: Text(
//                               S.of(context).SettingPageDisclaimerDetail2),
//                         ),
//                         SimpleDialogOption(
//                           child: Text(
//                               S.of(context).SettingPageDisclaimerDetail3),
//                         )
//                       ],
//                     );
//                   });
//             },
//           ),
//           ListTile(
//             title: Text(S.of(context).SettingPageFAQTitle),
//             subtitle: Text(S.of(context).SettingPageFAQSubtitle),
//             onTap: () {
//               showDialog(
//                   context: context,
//                   builder: (context) {
//                     return SimpleDialog(
//                       title: Text('FAQ'),
//                       titlePadding: EdgeInsets.all(10),
//                       children: <Widget>[
//                         ListTile(
//                           title: Text('Q:为啥会有这个东西？'),
//                           subtitle: Text('A:因为bug有点多，代码有点乱，我还修不了~'),
//                         ),
//                         ListTile(
//                           title: Text('Q:图标好丑啊。'),
//                           subtitle: Text('A:在？那你能帮帮我吗？'),
//                         ),
//                         ListTile(
//                           title: Text('Q:为啥和官方的比起来缺了那么多功能？'),
//                           subtitle: Text('A:简单APP!简单APP!!(写个完整的头发都要掉光了'),
//                         ),
//                         ListTile(
//                           title: Text('Q:那些功能会不会在后续更新里加上？'),
//                           subtitle: Text('A:也许？(要不爽哥结婚的时候再说？)'),
//                         ),
//                         ListTile(
//                           title: Text('Q:有没有iOS版'),
//                           subtitle: Text(
//                               'A:苹果那是人开发的东西吗？99美刀呢，感觉这应用卖了也不值这个价，而且第三方APP有法律风险的('),
//                         ),
//                         ListTile(
//                           title: Text('Q:用户名密码是什么？'),
//                           subtitle: Text(
//                               'A:你大妈之家用户名密码是啥就是啥，第三方登录只有QQ，大妈之家的接口爬起来太恶心了。'),
//                         ),
//                         ListTile(
//                           title: Text('Q:QQ登录怎么不能快捷登录？'),
//                           subtitle: Text('A:QQ的授权难搞的一批，有登录就不错了。'),
//                         ),
//                         ListTile(
//                           title: Text('Q:有没有下载功能？'),
//                           subtitle: Text(
//                               'A:下载功能。。。原本想做的，但是因为大妈之家的图片加载你懂的，我用了带缓存的图片插件，速度是快起来了，但是没法写下载了，flutter又没有原生的，估计实现还得找插件(头发要紧，头发要紧)'),
//                         ),
//                         ListTile(
//                           title: Text('Q:我软件特别卡怎么办？'),
//                           subtitle: Text(
//                               'A:也不知道为啥，大妈之家的接口用起来就是卡卡的，我已经用了带缓存的请求插件了，理论上应该会越用越顺畅？'),
//                         ),
//                         ListTile(
//                           title: Text('Q:内容看不见怎么办？'),
//                           subtitle: Text(
//                               'A:这个真不好说，有的是因为网卡等等就加载出来了，有的不知道为啥就是尬住了，重进就好了，还有的由于各位众所周知的问题是本来就没有内容的('),
//                         ),
//                         ListTile(
//                           title: Text('Q:开发的初衷是啥？'),
//                           subtitle:
//                           Text('A:大妈之家官方的APP有点卡，没想到自己的也好卡，现在感觉是服务器问题？'),
//                         ),
//                         ListTile(
//                           title: Text('Q:源代码怎么这么丑？'),
//                           subtitle: Text(
//                               'A:哦豁，你看源代码啦。小伙子，有没有兴趣来提交一个Pull request？(你以为我是菜，其实是吃人陷阱，这波我在第五层)'),
//                         ),
//                       ],
//                     );
//                   });
//             },
//           ),
//           ListTile(
//             title: Text(S.of(context).SettingPageProjectURLTitle),
//             subtitle: Text(S.of(context).SettingPageProjectURL),
//             onTap: () {
//               _openWeb(S.of(context).SettingPageProjectURL);
//             },
//           ),
//           ListTile(
//             title: Text(S.of(context).SettingPageAboutTitle),
//             subtitle: Text(S.of(context).SettingPageAboutSubtitle),
//             onTap: () {
//               showDialog(
//                   context: context,
//                   builder: (context) {
//                     return AboutDialog(
//                       applicationName:
//                       '${Provider.of<SystemSettingModel>(context).backupApi ? S.of(context).AppNameUltimate : appName}',
//                       applicationVersion: '$version',
//                       applicationIcon: FlutterLogo(),
//                       children: <Widget>[
//                         Text(S.of(context).SettingPageAboutDescription),
//                       ],
//                     );
//                   });
//             },
//           ),
//           ListTile(
//             title: Text(S.of(context).SettingPageChangeLogTitle),
//             subtitle: Text(S.of(context).SettingPageChangeLogSubtitle),
//             onTap: () async {
//               CustomHttp http = CustomHttp();
//               var response = await http.getReleases();
//               if (response.statusCode == 200) {
//                 var data = "";
//                 for (var item in response.data) {
//                   data += S.of(context).SettingPageChangeLogContent(
//                       item['name'], item['published_at'], item['body']);
//                 }
//                 showDialog(
//                     context: context,
//                     builder: (context) {
//                       return AlertDialog(
//                         title: Text(S.of(context).SettingPageChangeLogTitle),
//                         content: Container(
//                           width: 400,
//                           height: 700,
//                           child: buildMarkdown(data),
//                         ),
//                       );
//                     });
//               }
//             },
//           ),
//           Divider(),
//           ListTile(
//             enabled: labState,
//             title: Text(labState
//                 ? S.of(context).SettingPageLabSettingTitle
//                 : S.of(context).SettingPagePlaceholderTitle),
//             subtitle: Text(labState
//                 ? S.of(context).SettingPageLabSettingSubtitle
//                 : S.of(context).SettingPagePlaceholderSubtitle),
//             onTap: () {
//               Navigator.of(context)
//                   .push(MaterialPageRoute(builder: (context) {
//                 return LabSettingPage();
//               }));
//             },
//           ),
//           Divider(),
//           ListTile(
//             title: Text(S.of(context).SettingPageLogoutTitle),
//             subtitle: Text(S.of(context).SettingPageLogoutSubtitle),
//             onTap: () {
//               DataBase dataBase = DataBase();
//               dataBase.setLoginState(false).then(() {
//                 Navigator.of(context).pop();
//               });
//             },
//           )
//         ],
//       ));
// }
//
// Widget buildMarkdown(data) => MarkdownWidget(data: data);