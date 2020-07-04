import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class CustomSwiperControl extends SwiperPlugin {
  ///IconData for previous


  ///icon size
  final double size;


  final EdgeInsetsGeometry padding;

  final Key key;

  final bool debug;

  const CustomSwiperControl(
      {
        this.key,
        this.size: 30.0,
        this.padding: const EdgeInsets.all(5.0),
        this.debug:false
      });

  Widget buildButton(SwiperPluginConfig config,
      int quarterTurns, bool previous) {
    return new GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        bool next=true;
        bool prev=true;
        if (!config.loop){
          next = config.activeIndex < config.itemCount - 1;
          prev = config.activeIndex > 0;
        }
        if (previous&&prev) {
          config.controller.previous(animation: true);
        } else if(next) {
          config.controller.next(animation: true);
        }
      },
      child: Padding(
          padding: padding,
          child: RotatedBox(
              quarterTurns: quarterTurns,
              child: Container(
                width: size,
                color: debug?Colors.black38:null,
              ))),
    );
  }

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {




    Widget child;
    if (config.scrollDirection == Axis.horizontal) {
      child = Row(
        key: key,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildButton(config,  0, true),
          buildButton(config,  0, false)
        ],
      );
    } else {
      child = Column(
        key: key,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildButton(config,  -3, true),
          buildButton(config,  -3, false)
        ],
      );
    }

    return new Container(
      child: child,
    );
  }
}
