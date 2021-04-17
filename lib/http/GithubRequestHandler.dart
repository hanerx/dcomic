import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dio/dio.dart';

class GithubRequestHandler extends SingleDomainRequestHandler {
  GithubRequestHandler() : super('https://api.github.com');

  Future<Response> getReleases() {
    return dio.get('/repos/hanerx/dcomic/releases');
  }

  Future<Response> getLatestRelease() {
    return dio.get('/repos/hanerx/flutter_dmzj/releases/latest');
  }
}
