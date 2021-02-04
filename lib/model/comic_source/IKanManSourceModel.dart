import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutterdmzj/database/sourceDatabaseProvider.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';

class IKanManSourceModel extends BaseSourceModel {
  IKanManSourceOptions _options = IKanManSourceOptions.fromMap({});

  IKanManSourceModel() {
    init();
  }

  Future<void> init() async {
    Map map = await SourceDatabaseProvider.getSourceOptions(type.name);
    _options = IKanManSourceOptions.fromMap(map);
  }

  @override
  Future<ComicDetail> get({String comicId, String title}) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<Comic> getChapter(
      {String comicId, String title, String chapterId, String chapterTitle}) {
    // TODO: implement getChapter
    throw UnimplementedError();
  }

  @override
  Widget getSettingWidget(context) {
    // TODO: implement getSettingWidget
    return Container();
  }

  @override
  // TODO: implement options
  SourceOptions get options => _options;

  @override
  Future<List<ComicDetail>> search(String keyword) {
    // TODO: implement search
    throw UnimplementedError();
  }

  @override
  // TODO: implement type
  SourceDetail get type => SourceDetail('ikanman', '看漫画', '看漫画源', true, false);
}

class IKanManSourceOptions extends SourceOptions {
  bool _active = false;

  @override
  bool get active => _active;

  IKanManSourceOptions.fromMap(Map map) {
    _active = map['active'] == '1';
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {'active': active};
  }

  @override
  set active(bool value) {
    // TODO: implement active
    _active = value;
    SourceDatabaseProvider.insertSourceOption(
        'ikanman', 'active', value ? '1' : '0');
    notifyListeners();
  }
}
