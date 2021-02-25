// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `DMZJ`
  String get AppName {
    return Intl.message(
      'DMZJ',
      name: 'AppName',
      desc: '',
      args: [],
    );
  }

  /// `Super DMZJ-Ultimate`
  String get AppNameUltimate {
    return Intl.message(
      'Super DMZJ-Ultimate',
      name: 'AppNameUltimate',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get Setting {
    return Intl.message(
      'Settings',
      name: 'Setting',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get MainPageTabHome {
    return Intl.message(
      'Home',
      name: 'MainPageTabHome',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get MainPageTabCategory {
    return Intl.message(
      'Category',
      name: 'MainPageTabCategory',
      desc: '',
      args: [],
    );
  }

  /// `Ranking`
  String get MainPageTabRanking {
    return Intl.message(
      'Ranking',
      name: 'MainPageTabRanking',
      desc: '',
      args: [],
    );
  }

  /// `Latest`
  String get MainPageTabLatest {
    return Intl.message(
      'Latest',
      name: 'MainPageTabLatest',
      desc: '',
      args: [],
    );
  }

  /// `{modes, select, followSystem {System} brightness {Brightness} darkness {Darkness} other {System}}`
  String SettingPageDarkModeModes(Object modes) {
    return Intl.select(
      modes,
      {
        'followSystem': 'System',
        'brightness': 'Brightness',
        'darkness': 'Darkness',
        'other': 'System',
      },
      name: 'SettingPageDarkModeModes',
      desc: '',
      args: [modes],
    );
  }

  /// `Cannot launch web page, pls check your phone.`
  String get CannotOpenWeb {
    return Intl.message(
      'Cannot launch web page, pls check your phone.',
      name: 'CannotOpenWeb',
      desc: '',
      args: [],
    );
  }

  /// `Read direction`
  String get SettingPageReadDirectionTitle {
    return Intl.message(
      'Read direction',
      name: 'SettingPageReadDirectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Horizontal`
  String get SettingPageReadDirectionHorizontal {
    return Intl.message(
      'Horizontal',
      name: 'SettingPageReadDirectionHorizontal',
      desc: '',
      args: [],
    );
  }

  /// `Vertical`
  String get SettingPageReadDirectionVertical {
    return Intl.message(
      'Vertical',
      name: 'SettingPageReadDirectionVertical',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode`
  String get SettingPageDarkModeTitle {
    return Intl.message(
      'Dark mode',
      name: 'SettingPageDarkModeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Current Setting: {mode}`
  String SettingPageDarkModeSubtitle(Object mode) {
    return Intl.message(
      'Current Setting: $mode',
      name: 'SettingPageDarkModeSubtitle',
      desc: '',
      args: [mode],
    );
  }

  /// `Save path`
  String get SettingPageSavePath {
    return Intl.message(
      'Save path',
      name: 'SettingPageSavePath',
      desc: '',
      args: [],
    );
  }

  /// `Hide Save dictionary`
  String get SettingPageNoMediaTitle {
    return Intl.message(
      'Hide Save dictionary',
      name: 'SettingPageNoMediaTitle',
      desc: '',
      args: [],
    );
  }

  /// `Will add a .nomidea file into your save path to refuse media scan`
  String get SettingPageNoMediaSubtitle {
    return Intl.message(
      'Will add a .nomidea file into your save path to refuse media scan',
      name: 'SettingPageNoMediaSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Check database`
  String get SettingPageDatabaseDetailTitle {
    return Intl.message(
      'Check database',
      name: 'SettingPageDatabaseDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `Show all the data in your local database. CAUTION: Will direct expose your secret information like token, uid, etc.`
  String get SettingPageDatabaseDetailSubtitle {
    return Intl.message(
      'Show all the data in your local database. CAUTION: Will direct expose your secret information like token, uid, etc.',
      name: 'SettingPageDatabaseDetailSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Reset Database`
  String get SettingPageResetDatabaseTitle {
    return Intl.message(
      'Reset Database',
      name: 'SettingPageResetDatabaseTitle',
      desc: '',
      args: [],
    );
  }

  /// `WARNING: DANGER ZONE. Will delete all data in your local database, only for debug.`
  String get SettingPageResetDatabaseSubtitle {
    return Intl.message(
      'WARNING: DANGER ZONE. Will delete all data in your local database, only for debug.',
      name: 'SettingPageResetDatabaseSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm?`
  String get SettingPageResetDatabaseConfirmTitle {
    return Intl.message(
      'Confirm?',
      name: 'SettingPageResetDatabaseConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm to reset database?`
  String get SettingPageResetDatabaseConfirmDescription {
    return Intl.message(
      'Confirm to reset database?',
      name: 'SettingPageResetDatabaseConfirmDescription',
      desc: '',
      args: [],
    );
  }

  /// `confirm`
  String get Confirm {
    return Intl.message(
      'confirm',
      name: 'Confirm',
      desc: '',
      args: [],
    );
  }

  /// `cancel`
  String get Cancel {
    return Intl.message(
      'cancel',
      name: 'Cancel',
      desc: '',
      args: [],
    );
  }

  /// `Reset cache`
  String get SettingPageResetDioCacheTitle {
    return Intl.message(
      'Reset cache',
      name: 'SettingPageResetDioCacheTitle',
      desc: '',
      args: [],
    );
  }

  /// `WARNING: DANGER ZONE. Will delete all cache in dio_http_cache, may slow down the network speed.`
  String get SettingPageResetDioCacheSubtitle {
    return Intl.message(
      'WARNING: DANGER ZONE. Will delete all cache in dio_http_cache, may slow down the network speed.',
      name: 'SettingPageResetDioCacheSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm?`
  String get SettingPageResetDioCacheConfirmTitle {
    return Intl.message(
      'Confirm?',
      name: 'SettingPageResetDioCacheConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm to reset http cache?`
  String get SettingPageResetDioCacheConfirmDescription {
    return Intl.message(
      'Confirm to reset http cache?',
      name: 'SettingPageResetDioCacheConfirmDescription',
      desc: '',
      args: [],
    );
  }

  /// `Cancel all download tasks`
  String get SettingPageCancelDownloadTasksTitle {
    return Intl.message(
      'Cancel all download tasks',
      name: 'SettingPageCancelDownloadTasksTitle',
      desc: '',
      args: [],
    );
  }

  /// `WARNING: DANGER ZONE. Will cancel all downloading tasks, may cause bugs.`
  String get SettingPageCancelDownloadTasksSubtitle {
    return Intl.message(
      'WARNING: DANGER ZONE. Will cancel all downloading tasks, may cause bugs.',
      name: 'SettingPageCancelDownloadTasksSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm?`
  String get SettingPageCancelDownloadTasksConfirmTitle {
    return Intl.message(
      'Confirm?',
      name: 'SettingPageCancelDownloadTasksConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm to cancel?`
  String get SettingPageCancelDownloadTasksConfirmDescription {
    return Intl.message(
      'Confirm to cancel?',
      name: 'SettingPageCancelDownloadTasksConfirmDescription',
      desc: '',
      args: [],
    );
  }

  /// `Check download tasks`
  String get SettingPageDownloadTaskListTitle {
    return Intl.message(
      'Check download tasks',
      name: 'SettingPageDownloadTaskListTitle',
      desc: '',
      args: [],
    );
  }

  /// `Show all the tasks in download plugin database`
  String get SettingPageDownloadTaskListSubtitle {
    return Intl.message(
      'Show all the tasks in download plugin database',
      name: 'SettingPageDownloadTaskListSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Download tasks`
  String get SettingPageDownloadTaskListDetailTitle {
    return Intl.message(
      'Download tasks',
      name: 'SettingPageDownloadTaskListDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `Fail to open, pls check if task available.`
  String get SettingPageDownloadTaskListOpenFailed {
    return Intl.message(
      'Fail to open, pls check if task available.',
      name: 'SettingPageDownloadTaskListOpenFailed',
      desc: '',
      args: [],
    );
  }

  /// `Log console`
  String get SettingPageLogConsoleTitle {
    return Intl.message(
      'Log console',
      name: 'SettingPageLogConsoleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Show logs provide by logger`
  String get SettingPageLogConsoleSubtitle {
    return Intl.message(
      'Show logs provide by logger',
      name: 'SettingPageLogConsoleSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Check for update`
  String get SettingPageCheckUpdateTitle {
    return Intl.message(
      'Check for update',
      name: 'SettingPageCheckUpdateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Current version: {version}`
  String SettingPageCheckUpdateSubtitle(Object version) {
    return Intl.message(
      'Current version: $version',
      name: 'SettingPageCheckUpdateSubtitle',
      desc: '',
      args: [version],
    );
  }

  /// `Already up to date`
  String get CheckUpdateUpToDate {
    return Intl.message(
      'Already up to date',
      name: 'CheckUpdateUpToDate',
      desc: '',
      args: [],
    );
  }

  /// `Update channel`
  String get SettingPageUpdateChannelTitle {
    return Intl.message(
      'Update channel',
      name: 'SettingPageUpdateChannelTitle',
      desc: '',
      args: [],
    );
  }

  /// `Current channel：{channel}`
  String SettingPageUpdateChannelSubtitle(Object channel) {
    return Intl.message(
      'Current channel：$channel',
      name: 'SettingPageUpdateChannelSubtitle',
      desc: '',
      args: [channel],
    );
  }

  /// `{mode, select, release {Release} beta {Beta} other {Unknown}}`
  String SettingPageUpdateChannels(Object mode) {
    return Intl.select(
      mode,
      {
        'release': 'Release',
        'beta': 'Beta',
        'other': 'Unknown',
      },
      name: 'SettingPageUpdateChannels',
      desc: '',
      args: [mode],
    );
  }

  /// `Disclaimer`
  String get SettingPageDisclaimerTitle {
    return Intl.message(
      'Disclaimer',
      name: 'SettingPageDisclaimerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Disclaimer for apps`
  String get SettingPageDisclaimerSubtitle {
    return Intl.message(
      'Disclaimer for apps',
      name: 'SettingPageDisclaimerSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `1. This program is a third-party app, all program content is provided by anime home, this program does not guarantee the content security and reliability.`
  String get SettingPageDisclaimerDetail1 {
    return Intl.message(
      '1. This program is a third-party app, all program content is provided by anime home, this program does not guarantee the content security and reliability.',
      name: 'SettingPageDisclaimerDetail1',
      desc: '',
      args: [],
    );
  }

  /// `2. All interfaces of this program are obtained by official app, and this program promises not to collect any content to any third party.`
  String get SettingPageDisclaimerDetail2 {
    return Intl.message(
      '2. All interfaces of this program are obtained by official app, and this program promises not to collect any content to any third party.',
      name: 'SettingPageDisclaimerDetail2',
      desc: '',
      args: [],
    );
  }

  /// `3. The login function of this program is not the official login function, but the realization of the official interface. By using the login function of this program, you understand and are willing to bear the risks caused by using the login function of this program.`
  String get SettingPageDisclaimerDetail3 {
    return Intl.message(
      '3. The login function of this program is not the official login function, but the realization of the official interface. By using the login function of this program, you understand and are willing to bear the risks caused by using the login function of this program.',
      name: 'SettingPageDisclaimerDetail3',
      desc: '',
      args: [],
    );
  }

  /// `FAQ`
  String get SettingPageFAQTitle {
    return Intl.message(
      'FAQ',
      name: 'SettingPageFAQTitle',
      desc: '',
      args: [],
    );
  }

  /// `?`
  String get SettingPageFAQSubtitle {
    return Intl.message(
      '?',
      name: 'SettingPageFAQSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Project page`
  String get SettingPageProjectURLTitle {
    return Intl.message(
      'Project page',
      name: 'SettingPageProjectURLTitle',
      desc: '',
      args: [],
    );
  }

  /// `https://github.com/hanerx/flutter_dmzj`
  String get SettingPageProjectURL {
    return Intl.message(
      'https://github.com/hanerx/flutter_dmzj',
      name: 'SettingPageProjectURL',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get SettingPageAboutTitle {
    return Intl.message(
      'About',
      name: 'SettingPageAboutTitle',
      desc: '',
      args: [],
    );
  }

  /// `Public licenses`
  String get SettingPageAboutSubtitle {
    return Intl.message(
      'Public licenses',
      name: 'SettingPageAboutSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `A 3rd-party flutter dmzj application`
  String get SettingPageAboutDescription {
    return Intl.message(
      'A 3rd-party flutter dmzj application',
      name: 'SettingPageAboutDescription',
      desc: '',
      args: [],
    );
  }

  /// `ChangeLog`
  String get SettingPageChangeLogTitle {
    return Intl.message(
      'ChangeLog',
      name: 'SettingPageChangeLogTitle',
      desc: '',
      args: [],
    );
  }

  /// `All change logs record in github`
  String get SettingPageChangeLogSubtitle {
    return Intl.message(
      'All change logs record in github',
      name: 'SettingPageChangeLogSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `## {name}\n#### release date：{updateTime}\n {body}\n`
  String SettingPageChangeLogContent(Object name, Object updateTime, Object body) {
    return Intl.message(
      '## $name\n#### release date：$updateTime\n $body\n',
      name: 'SettingPageChangeLogContent',
      desc: '',
      args: [name, updateTime, body],
    );
  }

  /// `Placeholder`
  String get SettingPagePlaceholderTitle {
    return Intl.message(
      'Placeholder',
      name: 'SettingPagePlaceholderTitle',
      desc: '',
      args: [],
    );
  }

  /// `An useless placeholder`
  String get SettingPagePlaceholderSubtitle {
    return Intl.message(
      'An useless placeholder',
      name: 'SettingPagePlaceholderSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Experimental function`
  String get SettingPageLabSettingTitle {
    return Intl.message(
      'Experimental function',
      name: 'SettingPageLabSettingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations, the easter eggs!`
  String get SettingPageLabSettingSubtitle {
    return Intl.message(
      'Congratulations, the easter eggs!',
      name: 'SettingPageLabSettingSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get SettingPageLogoutTitle {
    return Intl.message(
      'Logout',
      name: 'SettingPageLogoutTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tips: there is an logout button in the drawer`
  String get SettingPageLogoutSubtitle {
    return Intl.message(
      'Tips: there is an logout button in the drawer',
      name: 'SettingPageLogoutSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Author-{author}`
  String AuthorPageTitle(Object author) {
    return Intl.message(
      'Author-$author',
      name: 'AuthorPageTitle',
      desc: '',
      args: [author],
    );
  }

  /// `Flutter DMZJ`
  String get DrawerEmail {
    return Intl.message(
      'Flutter DMZJ',
      name: 'DrawerEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please login`
  String get DrawerPlsLogin {
    return Intl.message(
      'Please login',
      name: 'DrawerPlsLogin',
      desc: '',
      args: [],
    );
  }

  /// `Favorite`
  String get Favorite {
    return Intl.message(
      'Favorite',
      name: 'Favorite',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get History {
    return Intl.message(
      'History',
      name: 'History',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get Download {
    return Intl.message(
      'Download',
      name: 'Download',
      desc: '',
      args: [],
    );
  }

  /// `DarkSide`
  String get DarkSide {
    return Intl.message(
      'DarkSide',
      name: 'DarkSide',
      desc: '',
      args: [],
    );
  }

  /// `Novel`
  String get Novel {
    return Intl.message(
      'Novel',
      name: 'Novel',
      desc: '',
      args: [],
    );
  }

  /// `https://avatar.dmzj.com/default.png`
  String get DefaultAvatar {
    return Intl.message(
      'https://avatar.dmzj.com/default.png',
      name: 'DefaultAvatar',
      desc: '',
      args: [],
    );
  }

  /// `new`
  String get TipsNew {
    return Intl.message(
      'new',
      name: 'TipsNew',
      desc: '',
      args: [],
    );
  }

  /// `Latest：{title}`
  String SubscribeLatestUpdate(Object title) {
    return Intl.message(
      'Latest：$title',
      name: 'SubscribeLatestUpdate',
      desc: '',
      args: [title],
    );
  }

  /// `No more data`
  String get NoData {
    return Intl.message(
      'No more data',
      name: 'NoData',
      desc: '',
      args: [],
    );
  }

  /// `Cannot load comic, change provider to fix it`
  String get NoComicData {
    return Intl.message(
      'Cannot load comic, change provider to fix it',
      name: 'NoComicData',
      desc: '',
      args: [],
    );
  }

  /// `Cannot automatic bound comicId, try bound id by manual search`
  String get ComicIdNotBound {
    return Intl.message(
      'Cannot automatic bound comicId, try bound id by manual search',
      name: 'ComicIdNotBound',
      desc: '',
      args: [],
    );
  }

  /// `Reading`
  String get SettingPageMainReadingTitle {
    return Intl.message(
      'Reading',
      name: 'SettingPageMainReadingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Reader Setting`
  String get SettingPageMainReadingSubtitle {
    return Intl.message(
      'Reader Setting',
      name: 'SettingPageMainReadingSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get SettingPageMainSourceTitle {
    return Intl.message(
      'Source',
      name: 'SettingPageMainSourceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Comic Source Setting`
  String get SettingPageMainSourceSubtitle {
    return Intl.message(
      'Comic Source Setting',
      name: 'SettingPageMainSourceSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get SettingPageMainAboutTitle {
    return Intl.message(
      'About',
      name: 'SettingPageMainAboutTitle',
      desc: '',
      args: [],
    );
  }

  /// `About Application`
  String get SettingPageMainAboutSubtitle {
    return Intl.message(
      'About Application',
      name: 'SettingPageMainAboutSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Debug`
  String get SettingPageMainDebugTitle {
    return Intl.message(
      'Debug',
      name: 'SettingPageMainDebugTitle',
      desc: '',
      args: [],
    );
  }

  /// `Developer Enhancement`
  String get SettingPageMainDebugSubtitle {
    return Intl.message(
      'Developer Enhancement',
      name: 'SettingPageMainDebugSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get SettingPageMainUserTitle {
    return Intl.message(
      'Account',
      name: 'SettingPageMainUserTitle',
      desc: '',
      args: [],
    );
  }

  /// `Account Setting`
  String get SettingPageMainUserSubtitle {
    return Intl.message(
      'Account Setting',
      name: 'SettingPageMainUserSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get SettingPageMainDownloadTitle {
    return Intl.message(
      'Download',
      name: 'SettingPageMainDownloadTitle',
      desc: '',
      args: [],
    );
  }

  /// `Downloader Setting`
  String get SettingPageMainDownloadSubtitle {
    return Intl.message(
      'Downloader Setting',
      name: 'SettingPageMainDownloadSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Comic Source`
  String get SettingPageSourcePageSourceTitle {
    return Intl.message(
      'Comic Source',
      name: 'SettingPageSourcePageSourceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Config Comic Source`
  String get SettingPageSourcePageSourceSubtitle {
    return Intl.message(
      'Config Comic Source',
      name: 'SettingPageSourcePageSourceSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Comic Source Provider`
  String get SettingPageSourcePageSourceProviderTitle {
    return Intl.message(
      'Comic Source Provider',
      name: 'SettingPageSourcePageSourceProviderTitle',
      desc: '',
      args: [],
    );
  }

  /// `Config Comic Source Provider`
  String get SettingPageSourcePageSourceProviderSubtitle {
    return Intl.message(
      'Config Comic Source Provider',
      name: 'SettingPageSourcePageSourceProviderSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Experiment Setting`
  String get SettingPageMainLabTitle {
    return Intl.message(
      'Experiment Setting',
      name: 'SettingPageMainLabTitle',
      desc: '',
      args: [],
    );
  }

  /// `Oh! you found easter egg.`
  String get SettingPageMainLabSubtitle {
    return Intl.message(
      'Oh! you found easter egg.',
      name: 'SettingPageMainLabSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `API Test Page`
  String get SettingPageDebugTestTitle {
    return Intl.message(
      'API Test Page',
      name: 'SettingPageDebugTestTitle',
      desc: '',
      args: [],
    );
  }

  /// `Provide a test page to test API`
  String get SettingPageDebugTestSubtitle {
    return Intl.message(
      'Provide a test page to test API',
      name: 'SettingPageDebugTestSubtitle',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}