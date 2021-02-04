import 'package:flutter/cupertino.dart';
import 'package:flutterdmzj/component/ComicSourceCard.dart';
import 'package:flutterdmzj/model/baseModel.dart';
import 'package:flutterdmzj/model/comic_source/DMZJSourceModel.dart';
import 'package:flutterdmzj/model/comic_source/IKanManSourceModel.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';

class SourceProvider extends BaseModel {
  List<BaseSourceModel> sources = [];

  SourceProvider() {
    init();
  }

  Future<void> init() async {
    sources.add(DMZJSourceModel());
    sources.add(IKanManSourceModel());
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
}
