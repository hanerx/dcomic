import 'dart:io';

import 'package:dio/adapter.dart';

class HttpProxyAdapter extends DefaultHttpClientAdapter {
  final String ipAddr;
  final int port;

  HttpProxyAdapter({this.ipAddr = 'localhost', this.port = 8888}) {
    onHttpClientCreate = (client) {
      String proxy = '$ipAddr:$port';
      client.findProxy = (url) {
        return 'PROXY $proxy';
      };

      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
  }
}

class BadCertificateAdapter extends DefaultHttpClientAdapter {
  BadCertificateAdapter() {
    onHttpClientCreate = (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
  }
}
