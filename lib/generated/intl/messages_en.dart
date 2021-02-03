// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static m0(author) => "Author-${author}";

  static m1(name, update_time, body) => "## ${name}\n#### release date：${update_time}\n ${body}\n";

  static m2(version) => "Current version: ${version}";

  static m3(modes) => "${Intl.select(modes, {'followSystem': 'System', 'brightness': 'Brightness', 'darkness': 'Darkness', 'other': 'System', })}";

  static m4(mode) => "Current Setting: ${mode}";

  static m5(channel) => "Current channel：${channel}";

  static m6(mode) => "${Intl.select(mode, {'release': 'Release', 'beta': 'Beta', 'other': 'Unknown', })}";

  static m7(title) => "Latest：${title}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "AppName" : MessageLookupByLibrary.simpleMessage("DMZJ"),
    "AppNameUltimate" : MessageLookupByLibrary.simpleMessage("Super DMZJ-Ultimate"),
    "AuthorPageTitle" : m0,
    "Cancel" : MessageLookupByLibrary.simpleMessage("cancel"),
    "CannotOpenWeb" : MessageLookupByLibrary.simpleMessage("Cannot launch web page, pls check your phone."),
    "CheckUpdateUpToDate" : MessageLookupByLibrary.simpleMessage("Already up to date"),
    "Confirm" : MessageLookupByLibrary.simpleMessage("confirm"),
    "DarkSide" : MessageLookupByLibrary.simpleMessage("DarkSide"),
    "DefaultAvatar" : MessageLookupByLibrary.simpleMessage("https://avatar.dmzj.com/default.png"),
    "Download" : MessageLookupByLibrary.simpleMessage("Download"),
    "DrawerEmail" : MessageLookupByLibrary.simpleMessage("Flutter DMZJ"),
    "DrawerPlsLogin" : MessageLookupByLibrary.simpleMessage("Please login"),
    "Favorite" : MessageLookupByLibrary.simpleMessage("Favorite"),
    "History" : MessageLookupByLibrary.simpleMessage("History"),
    "MainPageTabCategory" : MessageLookupByLibrary.simpleMessage("Category"),
    "MainPageTabHome" : MessageLookupByLibrary.simpleMessage("Home"),
    "MainPageTabLatest" : MessageLookupByLibrary.simpleMessage("Latest"),
    "MainPageTabRanking" : MessageLookupByLibrary.simpleMessage("Ranking"),
    "NoData" : MessageLookupByLibrary.simpleMessage("No more data"),
    "Novel" : MessageLookupByLibrary.simpleMessage("Novel"),
    "Setting" : MessageLookupByLibrary.simpleMessage("Settings"),
    "SettingPageAboutDescription" : MessageLookupByLibrary.simpleMessage("A 3rd-party flutter dmzj application"),
    "SettingPageAboutSubtitle" : MessageLookupByLibrary.simpleMessage("Public licenses"),
    "SettingPageAboutTitle" : MessageLookupByLibrary.simpleMessage("About"),
    "SettingPageCancelDownloadTasksConfirmDescription" : MessageLookupByLibrary.simpleMessage("Confirm to cancel?"),
    "SettingPageCancelDownloadTasksConfirmTitle" : MessageLookupByLibrary.simpleMessage("Confirm?"),
    "SettingPageCancelDownloadTasksSubtitle" : MessageLookupByLibrary.simpleMessage("WARNING: DANGER ZONE. Will cancel all downloading tasks, may cause bugs."),
    "SettingPageCancelDownloadTasksTitle" : MessageLookupByLibrary.simpleMessage("Cancel all download tasks"),
    "SettingPageChangeLogContent" : m1,
    "SettingPageChangeLogSubtitle" : MessageLookupByLibrary.simpleMessage("All change logs record in github"),
    "SettingPageChangeLogTitle" : MessageLookupByLibrary.simpleMessage("ChangeLog"),
    "SettingPageCheckUpdateSubtitle" : m2,
    "SettingPageCheckUpdateTitle" : MessageLookupByLibrary.simpleMessage("Check for update"),
    "SettingPageDarkModeModes" : m3,
    "SettingPageDarkModeSubtitle" : m4,
    "SettingPageDarkModeTitle" : MessageLookupByLibrary.simpleMessage("Dark mode"),
    "SettingPageDatabaseDetailSubtitle" : MessageLookupByLibrary.simpleMessage("Show all the data in your local database. CAUTION: Will direct expose your secret information like token, uid, etc."),
    "SettingPageDatabaseDetailTitle" : MessageLookupByLibrary.simpleMessage("Check database"),
    "SettingPageDisclaimerDetail1" : MessageLookupByLibrary.simpleMessage("1. This program is a third-party app, all program content is provided by anime home, this program does not guarantee the content security and reliability."),
    "SettingPageDisclaimerDetail2" : MessageLookupByLibrary.simpleMessage("2. All interfaces of this program are obtained by official app, and this program promises not to collect any content to any third party."),
    "SettingPageDisclaimerDetail3" : MessageLookupByLibrary.simpleMessage("3. The login function of this program is not the official login function, but the realization of the official interface. By using the login function of this program, you understand and are willing to bear the risks caused by using the login function of this program."),
    "SettingPageDisclaimerSubtitle" : MessageLookupByLibrary.simpleMessage("Disclaimer for apps"),
    "SettingPageDisclaimerTitle" : MessageLookupByLibrary.simpleMessage("Disclaimer"),
    "SettingPageDownloadTaskListDetailTitle" : MessageLookupByLibrary.simpleMessage("Download tasks"),
    "SettingPageDownloadTaskListOpenFailed" : MessageLookupByLibrary.simpleMessage("Fail to open, pls check if task available."),
    "SettingPageDownloadTaskListSubtitle" : MessageLookupByLibrary.simpleMessage("Show all the tasks in download plugin database"),
    "SettingPageDownloadTaskListTitle" : MessageLookupByLibrary.simpleMessage("Check download tasks"),
    "SettingPageFAQSubtitle" : MessageLookupByLibrary.simpleMessage("?"),
    "SettingPageFAQTitle" : MessageLookupByLibrary.simpleMessage("FAQ"),
    "SettingPageLabSettingSubtitle" : MessageLookupByLibrary.simpleMessage("Congratulations, the easter eggs!"),
    "SettingPageLabSettingTitle" : MessageLookupByLibrary.simpleMessage("Experimental function"),
    "SettingPageLogConsoleSubtitle" : MessageLookupByLibrary.simpleMessage("Show logs provide by logger"),
    "SettingPageLogConsoleTitle" : MessageLookupByLibrary.simpleMessage("Log console"),
    "SettingPageLogoutSubtitle" : MessageLookupByLibrary.simpleMessage("Tips: there is an logout button in the drawer"),
    "SettingPageLogoutTitle" : MessageLookupByLibrary.simpleMessage("Logout"),
    "SettingPageMainAboutSubtitle" : MessageLookupByLibrary.simpleMessage("About Application"),
    "SettingPageMainAboutTitle" : MessageLookupByLibrary.simpleMessage("About"),
    "SettingPageMainDebugSubtitle" : MessageLookupByLibrary.simpleMessage("Developer Enhancement"),
    "SettingPageMainDebugTitle" : MessageLookupByLibrary.simpleMessage("Debug"),
    "SettingPageMainDownloadSubtitle" : MessageLookupByLibrary.simpleMessage("Downloader Setting"),
    "SettingPageMainDownloadTitle" : MessageLookupByLibrary.simpleMessage("Download"),
    "SettingPageMainReadingSubtitle" : MessageLookupByLibrary.simpleMessage("Reader Setting"),
    "SettingPageMainReadingTitle" : MessageLookupByLibrary.simpleMessage("Reading"),
    "SettingPageMainSourceSubtitle" : MessageLookupByLibrary.simpleMessage("Comic Source Setting"),
    "SettingPageMainSourceTitle" : MessageLookupByLibrary.simpleMessage("Source"),
    "SettingPageMainUserSubtitle" : MessageLookupByLibrary.simpleMessage("Account Setting"),
    "SettingPageMainUserTitle" : MessageLookupByLibrary.simpleMessage("Account"),
    "SettingPageNoMediaSubtitle" : MessageLookupByLibrary.simpleMessage("Will add a .nomidea file into your save path to refuse media scan"),
    "SettingPageNoMediaTitle" : MessageLookupByLibrary.simpleMessage("Hide Save dictionary"),
    "SettingPagePlaceholderSubtitle" : MessageLookupByLibrary.simpleMessage("An useless placeholder"),
    "SettingPagePlaceholderTitle" : MessageLookupByLibrary.simpleMessage("Placeholder"),
    "SettingPageProjectURL" : MessageLookupByLibrary.simpleMessage("https://github.com/hanerx/flutter_dmzj"),
    "SettingPageProjectURLTitle" : MessageLookupByLibrary.simpleMessage("Project page"),
    "SettingPageReadDirectionHorizontal" : MessageLookupByLibrary.simpleMessage("Horizontal"),
    "SettingPageReadDirectionTitle" : MessageLookupByLibrary.simpleMessage("Read direction"),
    "SettingPageReadDirectionVertical" : MessageLookupByLibrary.simpleMessage("Vertical"),
    "SettingPageResetDatabaseConfirmDescription" : MessageLookupByLibrary.simpleMessage("Confirm to reset database?"),
    "SettingPageResetDatabaseConfirmTitle" : MessageLookupByLibrary.simpleMessage("Confirm?"),
    "SettingPageResetDatabaseSubtitle" : MessageLookupByLibrary.simpleMessage("WARNING: DANGER ZONE. Will delete all data in your local database, only for debug."),
    "SettingPageResetDatabaseTitle" : MessageLookupByLibrary.simpleMessage("Reset Database"),
    "SettingPageResetDioCacheConfirmDescription" : MessageLookupByLibrary.simpleMessage("Confirm to reset http cache?"),
    "SettingPageResetDioCacheConfirmTitle" : MessageLookupByLibrary.simpleMessage("Confirm?"),
    "SettingPageResetDioCacheSubtitle" : MessageLookupByLibrary.simpleMessage("WARNING: DANGER ZONE. Will delete all cache in dio_http_cache, may slow down the network speed."),
    "SettingPageResetDioCacheTitle" : MessageLookupByLibrary.simpleMessage("Reset cache"),
    "SettingPageSavePath" : MessageLookupByLibrary.simpleMessage("Save path"),
    "SettingPageUpdateChannelSubtitle" : m5,
    "SettingPageUpdateChannelTitle" : MessageLookupByLibrary.simpleMessage("Update channel"),
    "SettingPageUpdateChannels" : m6,
    "SubscribeLatestUpdate" : m7,
    "TipsNew" : MessageLookupByLibrary.simpleMessage("new")
  };
}
