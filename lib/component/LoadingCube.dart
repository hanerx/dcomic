import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingCube extends StatelessWidget {
  final Color textColor;
  final Color backgroundColor;
  final Color cubeColor;

  const LoadingCube({Key key, this.textColor, this.backgroundColor, this.cubeColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
          child: SizedBox(
        height: 200.0,
        width: 300.0,
        child: Card(
          color: backgroundColor,
          elevation: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 50.0,
                height: 50.0,
                child: SpinKitFadingCube(
                  color: cubeColor==null?Theme.of(context).primaryColor:cubeColor,
                  size: 25.0,
                ),
              ),
              Container(
                child: Text('加载中',style: TextStyle(color: textColor),),
              )
            ],
          ),
        ),
      )),
    );
  }
}
