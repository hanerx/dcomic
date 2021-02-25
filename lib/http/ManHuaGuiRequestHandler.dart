
import 'package:dio/dio.dart';
import 'package:flutterdmzj/http/UniversalRequestModel.dart';

class ManHuaGuiRequestHandler extends SingleDomainRequestHandler{
  ManHuaGuiRequestHandler() : super('https://m.manhuagui.com');


  Future<Response> search(String keyword){
    return dio.get('/s/${Uri.encodeComponent(keyword)}.html');
  }
  
  Future<Response> getComic(String comicId){
    return dio.get('/comic/$comicId/');
  }
  
  Future<Response> getChapter(String comicId,String chapterId){
    return dio.get('/comic/$comicId/$chapterId.html');
  }
}