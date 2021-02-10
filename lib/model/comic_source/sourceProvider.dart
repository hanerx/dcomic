import 'package:flutter/cupertino.dart';
import 'package:flutterdmzj/component/ComicSourceCard.dart';
import 'package:flutterdmzj/database/sourceDatabaseProvider.dart';
import 'package:flutterdmzj/model/baseModel.dart';
import 'package:flutterdmzj/model/comic_source/DMZJSourceModel.dart';
import 'package:flutterdmzj/model/comic_source/IKanManSourceModel.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';

class SourceProvider extends BaseModel {
  List<BaseSourceModel> sources = [];
  BaseSourceModel _active;
  int _index = 0;

  SourceProvider() {
    init();
  }

  Future<void> init() async {
    sources.add(DMZJSourceModel());
    sources.add(IKanManSourceModel());
    sources.add(DMZJWebSourceModel());
    var options=await SourceDatabaseProvider.getSourceOptions('provider');
    if(options.containsKey('index')){
      _index = int.parse(options['index']);
      _active = sources[index];
    }else{
      _active=sources.first;
      _index=0;
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

  Widget getSourceConfigWidget(context, index) {
    if (index > -1 && index < sources.length) {
      return ComicSourceCard(model: sources[index]);
    }
    return null;
  }

  BaseSourceModel get active => _active;

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
