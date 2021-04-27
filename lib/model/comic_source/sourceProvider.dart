import 'package:dcomic/model/comic_source/CopyMangaSourceModel.dart';
import 'package:dcomic/model/comic_source/LocalSourceModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:dcomic/component/ComicSourceCard.dart';
import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/DMZJSourceModel.dart';
import 'package:dcomic/model/comic_source/KuKuSourceModel.dart';
import 'package:dcomic/model/comic_source/ManHuaGuiSourceModel.dart';
import 'package:dcomic/model/comic_source/MangabzSourceModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';

class SourceProvider extends BaseModel {
  List<BaseSourceModel> sources = [];
  BaseSourceModel _active;
  int _index = 0;
  LocalSourceModel localSourceModel = LocalSourceModel();

  SourceProvider() {
    init();
  }

  Future<void> init() async {
    sources.add(DMZJWebSourceModel());
    // sources.add(DMZJSourceModel());
    sources.add(MangabzSourceModel());
    sources.add(ManHuaGuiSourceModel());
    sources.add(KuKuSourceModel());
    sources.add(localSourceModel);
    sources.add(CopyMangaSourceModel());
    var options = await SourceDatabaseProvider.getSourceOptions('provider');
    if (options.containsKey('index')) {
      _index = int.parse(options['index']);
      if (_index >= 0 && _index < activeSources.length) {
        _active = activeSources[index];
      } else {
        _active = sources.first;
        _index = 0;
      }
    } else {
      _active = sources.first;
      _index = 0;
    }
    logger.i('class: SourceProvider, action: init, sources: $sources');
  }

  List<BaseSourceModel> get activeSources {
    List<BaseSourceModel> activeSources = [];
    for (BaseSourceModel item in sources) {
      if (item.options.active) {
        activeSources.add(item);
      }
    }
    return activeSources;
  }

  List<BaseSourceModel> get favoriteSources {
    List<BaseSourceModel> favoriteSources = [];
    for (BaseSourceModel item in sources) {
      if (item.options.active && item.type.canSubscribe) {
        favoriteSources.add(item);
      }
    }
    return favoriteSources;
  }

  Widget getSourceConfigWidget(context, index) {
    if (index > -1 && index < sources.length) {
      return ComicSourceCard(model: sources[index]);
    }
    return null;
  }

  BaseSourceModel get active => _active;

  void setActiveWithoutNotify(BaseSourceModel model) {
    _active = model;
    _index = activeSources.indexOf(model);
    SourceDatabaseProvider.insertSourceOption('provider', 'index', index);
  }

  set active(BaseSourceModel active) {
    _active = active;
    index = activeSources.indexOf(active);
    notifyListeners();
  }

  int get index => _index;

  set index(int index) {
    if (index < activeSources.length) {
      _index = index;
      SourceDatabaseProvider.insertSourceOption('provider', 'index', index);
      notifyListeners();
    }
  }
}
