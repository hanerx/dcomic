import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class ComicSourceProviderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicSourceProviderPage();
  }
}

class _ComicSourceProviderPage extends State<ComicSourceProviderPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).SettingPageSourcePageSourceProviderTitle),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                TextEditingController controller = TextEditingController();
                var data = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '添加分布式服务器',
                              helperText: '添加分布式服务器地址，需加上http://与端口号'),
                        ),
                        actions: [
                          TextButton(
                            child: Text(S.of(context).Cancel),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: Text(S.of(context).Confirm),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          )
                        ],
                      );
                    });
                if (data != null && data) {
                  await Provider.of<SourceProvider>(context, listen: false)
                      .addAddress(controller.text);
                }
              })
        ],
      ),
      body: EasyRefresh(
        emptyWidget: Provider.of<SourceProvider>(context)
                    .ipfsSourceProvider
                    .nodes
                    .length ==
                0
            ? EmptyView()
            : null,
        child: ListView.builder(
            itemCount: Provider.of<SourceProvider>(context)
                .ipfsSourceProvider
                .nodes
                .length,
            itemBuilder: (context, index) {
              var node = Provider.of<SourceProvider>(context)
                  .ipfsSourceProvider
                  .nodes[index];
              return ListTile(
                title: Text('${node['title']}'),
                subtitle:
                    Text('服务器地址：${node['address']} 简介：${node['description']}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await Provider.of<SourceProvider>(context, listen: false)
                        .deleteAddress(node['url']);
                  },
                ),
              );
            }),
      ),
    );
  }
}
