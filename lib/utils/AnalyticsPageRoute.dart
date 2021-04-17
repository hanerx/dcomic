import 'package:flutter/material.dart';

class AnalyticsPageRoute extends MaterialPageRoute {
  AnalyticsPageRoute(Widget page)
      : super(
            builder: (context) => page,
            settings: RouteSettings(name: page.runtimeType.toString()));
}
