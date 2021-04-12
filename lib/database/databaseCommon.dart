import 'package:sqflite/sqflite.dart';

class DatabaseCommon {
  static Map<String, DatabaseStaticModel> databases = {
    'cookies': DatabaseStaticModel(
        1,
        {
          'id': 'INTEGER PRIMARY KEY',
          'key': 'TEXT',
          'value': 'TEXT',
          'provider': "TEXT"
        },
        16),
    'configures': DatabaseStaticModel(
        1, {'id': 'INTEGER PRIMARY KEY', 'key': 'TEXT', 'value': 'TEXT'}, null),
    'history': DatabaseStaticModel(1,
        {'id': 'INTEGER PRIMARY KEY', 'name': 'TEXT', 'value': 'TEXT'}, null),
    'unread': DatabaseStaticModel(
        1,
        {
          'id': 'INTEGER PRIMARY KEY',
          'comicId': 'TEXT',
          'timestamp': 'INTEGER'
        },
        null),
    'local_history': DatabaseStaticModel(
        1,
        {
          'id': 'INTEGER PRIMARY KEY',
          'comicId': 'TEXT',
          'timestamp': 'INTEGER',
          'cover': 'TEXT',
          'title': 'TEXT',
          'last_chapter': 'TEXT',
          'last_chapter_id': 'TEXT'
        },
        null),
    'download_comic_info': DatabaseStaticModel(
        10,
        {
          'id': 'INTEGER PRIMARY KEY',
          'comicId': 'TEXT',
          'cover': 'TEXT',
          'title': 'TEXT'
        },
        null),
    'download_chapter_info': DatabaseStaticModel(
        10,
        {
          'id': 'INTEGER PRIMARY KEY',
          'comicId': 'TEXT',
          'chapterId': 'TEXT',
          'tasks': 'TEXT',
          'title': 'TEXT',
          'data': 'TEXT'
        },
        null),
    'tracking_comic_info': DatabaseStaticModel(
        12,
        {
          'id': 'INTEGER PRIMARY KEY',
          'comicId': 'TEXT',
          'title': 'TEXT',
          'cover': 'TEXT',
          'data': 'TEXT'
        },
        null),
    'source_options': DatabaseStaticModel(
        13,
        {
          'id': 'INTEGER PRIMARY KEY',
          'source_name': 'TEXT',
          'key': 'TEXT',
          'value': 'TEXT'
        },
        null),
    'comic_bounding': DatabaseStaticModel(
        14,
        {
          'id': 'INTEGER PRIMARY KEY',
          'comic_id': 'TEXT',
          'bound_id': 'TEXT',
          'source_name': 'TEXT'
        },
        null),
    'comic_history': DatabaseStaticModel(
        15,
        {
          'id': "INTEGER PRIMARY KEY",
          'raw_comic_id': 'TEXT',
          'comic_id': 'TEXT',
          'source_name': 'TEXT',
          'timestamp': 'INTEGER',
          'cover': 'TEXT',
          'title': 'TEXT',
          'last_chapter': 'TEXT',
          'last_chapter_id': 'TEXT'
        },
        null)
  };

  static String databaseFileName = 'dmzj_2.db';

  static Future<Database> initDatabase() async {
    return await openDatabase(databaseFileName, version: 16,
        onCreate: (Database db, int version) async {
      // await db.execute(
      //     "CREATE TABLE cookies (id INTEGER PRIMARY KEY, key TEXT, value TEXT)");
      // await db.execute(
      //     "CREATE TABLE configures (id INTEGER PRIMARY KEY, key TEXT, value TEXT)");
      // await db.execute(
      //     "CREATE TABLE history (id INTEGER PRIMARY KEY, name TEXT, value TEXT)");
      // await db.execute(
      //     "CREATE TABLE unread (id INTEGER PRIMARY KEY, comicId TEXT, timestamp INTEGER)");
      // await db.execute(
      //     "CREATE TABLE local_history (id INTEGER PRIMARY KEY, comicId TEXT, timestamp INTEGER,cover TEXT,title TEXT,last_chapter TEXT,last_chapter_id TEXT)");
      // await db.execute(
      //     "CREATE TABLE download_comic_info (id INTEGER PRIMARY KEY, comicId TEXT, cover TEXT, title TEXT)");
      // await db.execute(
      //     "CREATE TABLE download_chapter_info (id INTEGER PRIMARY KEY, comicId TEXT, chapterId TEXT, tasks TEXT, title TEXT, data TEXT)");
      // await db.execute(
      //     'CREATE TABLE tracking_comic_info (id INTEGER PRIMARY KEY, comicId TEXT, title TEXT, cover TEXT)');
      databases.forEach((key, value) {
        db.execute('CREATE TABLE $key ($value)');
        print('CREATE TABLE $key ($value)');
      });
    }, onUpgrade: (Database db, int version, int newVersion) async {
      print('class: DataBase, action: upgrade, version: $version');
      // await db.execute(
      //     'CREATE TABLE tracking_comic_info (id INTEGER PRIMARY KEY, comicId TEXT, title TEXT, cover TEXT, data TEXT)');
      databases.forEach((key, value) {
        if (value.version > version && value.version <= newVersion) {
          db.execute('CREATE TABLE $key ($value)');
          print('CREATE TABLE $key ($value)');
        } else if (value.rebuildVersion != null &&
            value.rebuildVersion > version &&
            value.rebuildVersion <= newVersion) {
          db
              .execute('DROP TABLE $key')
              .then((_) => db.execute("CREATE TABLE $key ($value)"));
          print('REBUILD TABLE $key ($value)');
        }
      });
    });
  }

  static Future<void> resetDataBase() async {
    await deleteDatabase(databaseFileName);
  }
}

class DatabaseStaticModel {
  final int version;
  final Map<String, String> tables;
  final int rebuildVersion;

  DatabaseStaticModel(this.version, this.tables, this.rebuildVersion);

  @override
  String toString() {
    // TODO: implement toString
    return tables.keys.map<String>((e) => '$e ${tables[e]}').toList().join(',');
  }
}
