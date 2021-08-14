import 'package:dcomic/model/baseModel.dart';
import 'package:flutter/cupertino.dart';

enum RouterLayout{
  RootRoute,
  HomeRoute,
  ViewerRoute
}

class RouterModel extends BaseModel{
    final GlobalKey<NavigatorState> homeNavigator=GlobalKey<NavigatorState>();
    final GlobalKey<NavigatorState> viewerNavigator=GlobalKey<NavigatorState>();
    final BuildContext context;

  RouterModel(this.context);

  NavigatorState getNavigatorState(RouterLayout layout){
    switch(layout){
      case RouterLayout.RootRoute:
        return Navigator.of(context);
      case RouterLayout.HomeRoute:
        return homeNavigator.currentState;
      case RouterLayout.ViewerRoute:
        return viewerNavigator.currentState;
    }
    return Navigator.of(context);
  }

}