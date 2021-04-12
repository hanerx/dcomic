import 'package:flutter/cupertino.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/component/comic_viewer/EndPage.dart';

typedef BoolCallback = Future<bool> Function();
typedef OnPageChangeCallback = void Function(int index);

class Common {
  static Widget builder(BuildContext context, int index, int count,
      IndexedWidgetBuilder builder, bool left, bool right,
      {bool dense = false}) {
    print(
        "class: ComicCommon, action: buildPage, index: $index, count: $count");
    if(count==2){
      return LoadingCube();
    }
    if (index == 0) {
      if (!left) {
          return LoadingCube();
      } else {
        return EndPage();
      }
    } else if (count != null && index == count-1) {
      if (!right) {
          return LoadingCube();
      } else {
        return EndPage();
      }
    } else if (index > 0 && index < count) {
      return builder(context, index - 1);
    }
    return null;
  }

  static Widget builderVertical(BuildContext context, int index, int count,
      IndexedWidgetBuilder builder, bool left, bool right,
      {bool dense = false}){
    print(
        "class: ComicCommon, action: buildPage, index: $index, count: $count");
    if (index >= 0 && index < count) {
      return builder(context, index);
    }
    return null;
  }
}
