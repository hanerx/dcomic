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
  BaseSourceModel _activeHomeModel;
  int _homeIndex = 0;
  int _index = 0;
  LocalSourceModel localSourceModel = LocalSourceModel();
  bool lock = false;

  SourceProvider() {
    init();
  }

  Future<void> init() async {
    if (!lock) {
      await Future.delayed(Duration(seconds: 5));
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
      if (options.containsKey("home_index")) {
        _homeIndex = int.parse(options['home_index']);
        if (_homeIndex >= 0 && _homeIndex < activeHomeSources.length) {
          _activeHomeModel = activeHomeSources[homeIndex];
        } else {
          _activeHomeModel = activeHomeSources.first;
          _homeIndex = 0;
        }
      } else {
        _activeHomeModel = activeHomeSources.first;
        _homeIndex = 0;
      }
      logger.i('class: SourceProvider, action: init, sources: $sources');
      lock = true;
      notifyListeners();
    }
    // notifyListeners();
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

  List<BaseSourceModel> get activeHomeSources {
    List<BaseSourceModel> data = [];
    for (var item in sources) {
      if (item.options.active && item.type.haveHomePage) {
        data.add(item);
      }
    }
    return data;
  }

  BaseSourceModel get activeHomeModel => _activeHomeModel;

  set activeHomeModel(BaseSourceModel active) {
    _activeHomeModel = active;
    homeIndex = activeHomeSources.indexOf(active);
    notifyListeners();
  }

  int get homeIndex => _homeIndex;

  set homeIndex(int index) {
    if (index < activeSources.length) {
      _homeIndex = index;
      SourceDatabaseProvider.insertSourceOption(
          'provider', 'home_index', index);
      notifyListeners();
    }
  }
}
