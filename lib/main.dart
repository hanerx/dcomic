import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutterdmzj/component/Drawer.dart';
import 'package:flutterdmzj/component/search/SearchButton.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/model/comicViewerSettingModel.dart';
import 'package:flutterdmzj/model/comic_source/sourceProvider.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:flutterdmzj/model/trackerModel.dart';
import 'package:flutterdmzj/model/versionModel.dart';
import 'package:flutterdmzj/utils/ChineseCupertinoLocalizations.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/category_page.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';
import 'package:flutterdmzj/view/download_page.dart';
import 'package:flutterdmzj/view/history_page.dart';
import 'package:flutterdmzj/view/home_page.dart';
import 'package:flutterdmzj/view/latest_update_page.dart';
import 'package:flutterdmzj/view/login_page.dart';
import 'package:flutterdmzj/view/ranking_page.dart';
import 'package:flutterdmzj/view/settings/setting_page.dart';
import 'package:logger/logger.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';


void main() async {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MultiProvider(providers: [
      ChangeNotifierProvider<SystemSettingModel>(
        create: (_) => SystemSettingModel(),
        lazy: false,
      ),
      ChangeNotifierProvider<ComicViewerSettingModel>(
        create: (_) => ComicViewerSettingModel(),
      ),
      ChangeNotifierProvider<VersionModel>(
        create: (_) => VersionModel(),
      ),
      ChangeNotifierProvider<TrackerModel>(
        create: (_) => TrackerModel(),
      ),
      ChangeNotifierProvider<SourceProvider>(
        lazy: false,
        create: (_) => SourceProvider(),
      )
    ], child: MainFrame());
  }
}

class MainFrame extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainFrame();
  }
}

class _MainFrame extends State<MainFrame> {
  initDownloader() async {
    print("class: MainFrame, action: initDownloader");
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(
        debug: true // optional: set false to disable printing logs to console
        );
    FlutterDownloader.registerCallback(ToolMethods.downloadCallback);
  }

  initEasyRefresh() {
    EasyRefresh.defaultHeader = ClassicalHeader(
        refreshedText: '刷新完成',
        refreshFailedText: '刷新失败',
        refreshingText: '刷新中',
        refreshText: '下拉刷新',
        refreshReadyText: '释放刷新');
    EasyRefresh.defaultFooter = ClassicalFooter(
        loadReadyText: '下拉加载更多',
        loadFailedText: '加载失败',
        loadingText: '加载中',
        loadedText: '加载完成',
        noMoreText: '没有更多内容了');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initDownloader();
    initEasyRefresh();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = true;
    debugPaintSizeEnabled = false;
    // TODO: implement build
    return new MaterialApp(
        themeMode: Provider.of<SystemSettingModel>(context).themeMode,
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            platform: TargetPlatform.iOS,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Colors.black, foregroundColor: Colors.white),
            buttonTheme: ButtonThemeData(buttonColor: Colors.black)),
        routes: {
          "history": (BuildContext context) => new HistoryPage(),
          "settings": (BuildContext context) => new SettingPage(),
          "login": (BuildContext context) => new LoginPage(),
          "download": (BuildContext context) => new DownloadPage()
        },
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: [
          //此处
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          ChineseCupertinoLocalizations.delegate,
        ],
        color: Colors.grey[400],
        showSemanticsDebugger: false,
        showPerformanceOverlay: false,
        theme: ThemeData(
            platform: TargetPlatform.iOS,
            buttonTheme: ButtonThemeData(buttonColor: Colors.blue)),
        home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainPage();
  }
}

class _MainPage extends State<MainPage> {
  Future<Null> initUniLinks() async {
    getUriLinksStream().listen((Uri event) {
      print(
          'class: Main, action: deepLink, raw: $event, path: ${event.path}, query: ${event.query}');
      switch (event.path) {
        case '/comic':
          var params = event.queryParameters;
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ComicDetailPage(id:params['id']);
          }));
          break;
      }
    });
  }

  Future<void> checkUpdate() async {
    await Provider.of<VersionModel>(context, listen: false).init();
    if (ToolMethods.checkVersionSemver(
        Provider.of<VersionModel>(context, listen: false).localLatestVersion,
        Provider.of<VersionModel>(context, listen: false).latestVersion)) {
      Provider.of<VersionModel>(context, listen: false).localLatestVersion =
          Provider.of<VersionModel>(context, listen: false).latestVersion;
      Provider.of<VersionModel>(context, listen: false)
          .showUpdateDialog(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUpdate();
    initUniLinks();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 4,
      child: new Scaffold(
          appBar: new AppBar(
            title: Text(S.of(context).AppName),
            actions: <Widget>[SearchButton()],
            bottom: TabBar(
              tabs: <Widget>[
                new Tab(
                  text: S.of(context).MainPageTabHome,
                ),
                new Tab(
                  text: S.of(context).MainPageTabCategory,
                ),
                new Tab(
                  text: S.of(context).MainPageTabRanking,
                ),
                new Tab(
                  text: S.of(context).MainPageTabLatest,
                )
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              new HomePage(),
              CategoryPage(),
              RankingPage(),
              LatestUpdatePage(),
            ],
          ),
          drawer: CustomDrawer()),
    );
  }
}
