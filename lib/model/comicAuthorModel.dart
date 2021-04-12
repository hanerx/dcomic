import 'package:flutter/cupertino.dart';
import 'package:dcomic/component/AuthorCard.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/baseModel.dart';

class ComicAuthorModel extends BaseModel{
  final int authorId;

  List comics=[];

  ComicAuthorModel(this.authorId);

  Future<void> init()async{
    CustomHttp http = CustomHttp();
    try{
      var response = await http.getAuthor(authorId);
      if (response.statusCode == 200) {
        comics=response.data['data'];
        notifyListeners();
      }
    }catch(e){
      logger.e('class: ComicAuthorModel, action: initFailed, authorId: $authorId exception: $e');
    }
  }

  List<Widget> buildAuthorWidget(context){
    return comics.map<Widget>((e) => AuthorCard(e['cover'],e['name'],e['status'],e['id'])).toList();
  }

  bool get empty=>comics.length==0;
}