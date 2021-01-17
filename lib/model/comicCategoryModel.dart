import 'package:flutter/cupertino.dart';
import 'package:flutterdmzj/component/CategoryCard.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/baseModel.dart';

class ComicCategoryModel extends BaseModel{
  final int type;
  List category=[];

  ComicCategoryModel(this.type);

  Future<void> init()async{
    CustomHttp http = CustomHttp();
    try{
      var response = await http.getCategory(type);
      if(response.statusCode==200){
        category=response.data;
        notifyListeners();
      }
    }catch(e){
      logger.e('class: ComicCategoryModel, action: initFailed, exception: $e');
    }

  }


  List<Widget> buildCategoryWidget(context){
    return category.map<Widget>((e) => CategoryCard(e['cover'], e['title'],e['tag_id'],type: type,)).toList();
  }
}