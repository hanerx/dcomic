import 'dart:convert';

import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/baseModel.dart';

class CloudHistoryModel extends BaseModel {
  int _page = 0;
  List _data = [];
  String _uid = '';
  bool _login = false;

  Future<void> initLoginState() async {
    _login =
        await SourceDatabaseProvider.getSourceOption<bool>('dmzj', 'login');
    if (_login) {
      _uid = await SourceDatabaseProvider.getSourceOption('dmzj', 'uid');
    }
  }

  Future<void> getHistory() async {
    try {
      var response = await UniversalRequestModel.dmzjInterfaceRequestHandler
          .getHistory(_uid, _page);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.data);
        _data += data;
        notifyListeners();
      }
    } catch (e) {
      logger.e(
          'class: ${this.runtimeType}, action: getHistoryFailed, exception: $e');
    }
  }

  Future<void> refresh() async {
    _page = 0;
    _data.clear();
    await initLoginState();
    await getHistory();
    notifyListeners();
  }

  Future<void> next() async {
    _page++;
    await getHistory();
    notifyListeners();
  }

  bool get login => _login;

  List get data => _data;

  int get length => _data.length;
}
