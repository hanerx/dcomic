import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseListTile extends StatelessWidget {
  final Widget leading;
  final List<Widget> detail;
  final VoidCallback onPressed;

  const BaseListTile({Key key, this.leading, this.detail, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Container(
          padding: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.1)))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(width: 100, child: leading)),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: detail),
              )
            ],
          ),
        ),
      ),
    );
  }
}
