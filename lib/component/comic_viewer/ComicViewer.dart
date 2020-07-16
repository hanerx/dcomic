import 'package:flutter/cupertino.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'Page.dart';

class ComicViewer extends StatefulWidget {
  final List<Page> list;
  final Page front;
  final Page end;
  final Page empty;

  ComicViewer({
    @required this.list,
    this.front,
    this.end,
    this.empty,

  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicViewer();
  }
}

class _ComicViewer extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Swiper();
  }
}
