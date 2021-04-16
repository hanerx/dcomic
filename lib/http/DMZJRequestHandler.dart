import 'package:dcomic/database/cookieDatabaseProvider.dart';
import 'package:dio/dio.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';



class DMZJRequestHandler extends SingleDomainRequestHandler {
  DMZJRequestHandler() : super('https://v3api.dmzj1.com');

  Future<Response> getUserInfo(String uid) async {
    return dio.get('/UCenter/comics/$uid.json');
  }

  Future<Response> getIfSubscribe(String comicId, String uid,
      {int type: 0}) async {
    return dio.get('$baseUrl/subscribe/$type/$uid/$comicId');
  }

  Future<Response> cancelSubscribe(String comicId, String uid,
      {int type: 0}) async {
    return dio.get(
        '/subscribe/cancel?obj_ids=$comicId&uid=$uid&type=${type == 0 ? 'mh' : 'xs'}');
  }

  Future<Response> addSubscribe(String comicId, String uid,
      {int type: 0}) async {
    FormData formData = FormData.fromMap(
        {"obj_ids": comicId, "uid": uid, 'type': type == 0 ? 'mh' : 'xs'});
    return dio.post('/subscribe/add', data: formData);
  }

  Future<Response<T>> getSubscribe<T>(int uid, int page, {int type: 0}) {
    return dio.get(
        '/UCenter/subscribe?uid=$uid&sub_type=1&letter=all&page=$page&type=$type');
  }
}

class DMZJIRequestHandler extends SingleDomainRequestHandler {
  DMZJIRequestHandler() : super('https://i.dmzj1.com');

  Future<Response> login(String username, String password) async {
    return dio.get(
        '/api/login?callback=&nickname=$username&password=$password&type=1');
  }
}

class DMZJMobileRequestHandler extends SingleDomainRequestHandler {
  DMZJMobileRequestHandler() : super('https://m.dmzj.com');
}

class DMZJInterfaceRequestHandler extends CookiesRequestHandler {
  DMZJInterfaceRequestHandler() : super('dmzj', 'https://interface.dmzj.com');

  Future<Response> updateUnread(String comicId) async {
    return dio.get('/api/subscribe/upread?sub_id=$comicId',
        options: await setHeader());
  }
}
