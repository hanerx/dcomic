import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';
import 'package:provider/provider.dart';

class ComicSourceCard extends StatefulWidget {
  final BaseSourceModel model;

  const ComicSourceCard({Key key, this.model}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicSourceCard();
  }
}

class _ComicSourceCard extends State<ComicSourceCard> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => SourceOptionsProvider(widget.model.options),
      builder: (context, child) {
        return Card(
            margin: EdgeInsets.all(5),
            child: Wrap(
              children: [
                ListTile(
                  enabled: !widget.model.type.deprecated,
                  title: Text('${widget.model.type.title}'),
                  subtitle: Text('${widget.model.type.description}'),
                  trailing: Switch(
                    value: Provider.of<SourceOptionsProvider>(context).active,
                    onChanged: widget.model.type.canDisable&&!widget.model.type.deprecated
                        ? (value) {
                            Provider.of<SourceOptionsProvider>(context,
                                    listen: false)
                                .active = value;
                          }
                        : null,
                  ),
                  leading: Icon(widget.model.type.cloud
                      ? Icons.cloud
                      : Icons.phone_android),
                ),
                Divider(),
                widget.model.getSettingWidget(context)
              ],
            ));
      },
    );
  }
}
