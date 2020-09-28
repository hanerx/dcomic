import 'package:flutter/cupertino.dart';
import 'package:flutterdmzj/component/comic_viewer/EndPage.dart';
import 'package:flutterdmzj/component/comic_viewer/EndPageDense.dart';
import 'package:flutterdmzj/component/comic_viewer/LoadingPanel.dart';

typedef BoolCallback = Future<bool> Function();
typedef OnPageChangeCallback = void Function(int index);

class Common {
  static Widget builder(BuildContext context, int index, int count,
      IndexedWidgetBuilder builder, bool left, bool right,
      {bool dense = false}) {
    print(
        "class: ComicCommon, action: buildPage, index: $index, count: $count");
    if (index == 0) {
      if (!left) {
        return LoadingPanel();
      } else {
        return dense ? EndPageDense() : EndPage();
      }
    } else if (count != null && index == count) {
      if (!right) {
        return LoadingPanel();
      } else {
        return dense ? EndPageDense() : EndPage();
      }
    } else if (index > 0 && index < count) {
      return builder(context, index - 1);
    }
    return null;
  }
}
