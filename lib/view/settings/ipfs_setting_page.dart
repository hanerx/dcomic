import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_proxy/dio_proxy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/model/ipfsSettingProvider.dart';
import 'package:ipfs/ipfs.dart';
import 'package:provider/provider.dart';

class IPFSSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IPFSSettingPage();
  }
}

class _IPFSSettingPage extends State<IPFSSettingPage> {
  Uint8List _image;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).SettingPageIPFSTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(S.of(context).SettingPageIPFSSettingPageModesTitle),
            subtitle: Text(S.of(context).SettingPageIPFSSettingPageModes(
                IPFSSettingProvider
                    .modes[Provider.of<IPFSSettingProvider>(context).mode])),
            onTap: () {
              Provider.of<IPFSSettingProvider>(context, listen: false).mode++;
            },
          ),
          Divider(),
          ListTile(
            title: Text(S.of(context).SettingPageIPFSSettingPageServerTitle),
            subtitle:
                Text('${Provider.of<IPFSSettingProvider>(context).server}'),
            onTap: () async {
              TextEditingController controller = TextEditingController(
                  text: Provider.of<IPFSSettingProvider>(context, listen: false)
                      .server
                      .toString());
              var data = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: S
                                .of(context)
                                .SettingPageIPFSSettingPageServerTitle,
                            helperText: S
                                .of(context)
                                .SettingPageIPFSSettingPageServerTitle),
                      ),
                      actions: [
                        FlatButton(
                          child: Text(S.of(context).Cancel),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text(S.of(context).Confirm),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        )
                      ],
                    );
                  });
              if (data != null && data) {
                Provider.of<IPFSSettingProvider>(context, listen: false)
                    .server = controller.text;
              }
            },
          ),
          ListTile(
            title: Text(S.of(context).SettingPageIPFSSettingPagePortTitle),
            subtitle: Text('${Provider.of<IPFSSettingProvider>(context).port}'),
            onTap: () async {
              TextEditingController controller = TextEditingController(
                  text: Provider.of<IPFSSettingProvider>(context, listen: false)
                      .port
                      .toString());
              var data = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: TextField(
                        keyboardType: TextInputType.number,
                        controller: controller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: S
                                .of(context)
                                .SettingPageIPFSSettingPagePortTitle,
                            helperText: S
                                .of(context)
                                .SettingPageIPFSSettingPagePortTitle),
                      ),
                      actions: [
                        FlatButton(
                          child: Text(S.of(context).Cancel),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text(S.of(context).Confirm),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        )
                      ],
                    );
                  });
              if (data != null && data) {
                Provider.of<IPFSSettingProvider>(context, listen: false).port =
                    int.parse(controller.text);
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text(S.of(context).SettingPageIPFSSettingPageProxyTitle),
            subtitle:
                Text(S.of(context).SettingPageIPFSSettingPageProxySubtitle),
            trailing: Switch(
              value: Provider.of<IPFSSettingProvider>(context).enableProxy,
              onChanged: (value) {
                Provider.of<IPFSSettingProvider>(context, listen: false)
                    .enableProxy = value;
              },
            ),
          ),
          ListTile(
            enabled: Provider.of<IPFSSettingProvider>(context).enableProxy,
            title:
                Text(S.of(context).SettingPageIPFSSettingPageProxyServerTitle),
            subtitle: Text(
                '${Provider.of<IPFSSettingProvider>(context).proxyServer}'),
            onTap: () async {
              TextEditingController controller = TextEditingController(
                  text: Provider.of<IPFSSettingProvider>(context, listen: false)
                      .proxyServer
                      .toString());
              var data = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: S
                                .of(context)
                                .SettingPageIPFSSettingPageProxyServerTitle,
                            helperText: S
                                .of(context)
                                .SettingPageIPFSSettingPageProxyServerTitle),
                      ),
                      actions: [
                        FlatButton(
                          child: Text(S.of(context).Cancel),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text(S.of(context).Confirm),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        )
                      ],
                    );
                  });
              if (data != null && data) {
                Provider.of<IPFSSettingProvider>(context, listen: false)
                    .proxyServer = controller.text;
              }
            },
          ),
          ListTile(
            enabled: Provider.of<IPFSSettingProvider>(context).enableProxy,
            title: Text(S.of(context).SettingPageIPFSSettingPageProxyPortTitle),
            subtitle:
                Text('${Provider.of<IPFSSettingProvider>(context).proxyPort}'),
            onTap: () async {
              TextEditingController controller = TextEditingController(
                  text: Provider.of<IPFSSettingProvider>(context, listen: false)
                      .proxyPort
                      .toString());
              var data = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: TextField(
                        keyboardType: TextInputType.number,
                        controller: controller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: S
                                .of(context)
                                .SettingPageIPFSSettingPageProxyPortTitle,
                            helperText: S
                                .of(context)
                                .SettingPageIPFSSettingPageProxyPortTitle),
                      ),
                      actions: [
                        FlatButton(
                          child: Text(S.of(context).Cancel),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text(S.of(context).Confirm),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        )
                      ],
                    );
                  });
              if (data != null && data) {
                Provider.of<IPFSSettingProvider>(context, listen: false)
                    .proxyPort = int.parse(controller.text);
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text(S.of(context).SettingPageIPFSSettingPageTestTitle),
            trailing: IconButton(
              icon: Icon(Icons.network_check),
              onPressed: () async {
                if (_image != null) {
                  setState(() {
                    _image = null;
                  });
                }
                Dio dio = Dio();
                if (Provider.of<IPFSSettingProvider>(context, listen: false)
                    .enableProxy) {
                  dio
                    ..httpClientAdapter = HttpProxyAdapter(
                        ipAddr: Provider.of<IPFSSettingProvider>(context,
                                listen: false)
                            .proxyServer,
                        port: Provider.of<IPFSSettingProvider>(context,
                                listen: false)
                            .proxyPort);
                }
                switch (Provider.of<IPFSSettingProvider>(context, listen: false)
                    .mode) {
                  case 0:
                    Ipfs ipfs = Ipfs.dio(
                        baseUrl: Provider.of<IPFSSettingProvider>(context,
                                listen: false)
                            .server,
                        port: Provider.of<IPFSSettingProvider>(context,
                                listen: false)
                            .port,
                        dio: dio);
                    ipfs.getPeers();
                    String cid =
                        'QmSY5BqPor7aQD8EsSJvXdixkgLoAdQHP3uq5yX28jGwsT';
                    var item = await ipfs.catObject(cid);
                    setState(() {
                      _image = Uint8List.fromList(item);
                    });
                    break;
                  case 1:
                    var response = await dio.get(
                        'https://ipfs.io/ipfs/QmSY5BqPor7aQD8EsSJvXdixkgLoAdQHP3uq5yX28jGwsT',
                        options: Options(responseType: ResponseType.bytes));
                    setState(() {
                      _image = Uint8List.fromList(response.data);
                    });
                    break;
                }
              },
            ),
            subtitle:
                Text(S.of(context).SettingPageIPFSSettingPageTestSubtitle),
          ),
          ListTile(
            title: _image == null
                ? Text(S.of(context).NoImage)
                : Image.memory(_image),
          )
        ],
      ),
    );
  }
}
