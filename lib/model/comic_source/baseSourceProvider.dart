import 'package:dcomic/model/baseModel.dart';

import 'baseSourceModel.dart';

abstract class BaseSourceProvider extends BaseModel{
  List<BaseSourceModel> getSources();
  Future<void>init();
  Future<List<BaseSourceModel>>update();
}