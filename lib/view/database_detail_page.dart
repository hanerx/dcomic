import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/model/databaseDetailModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class DatabaseDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DatabaseDetailPage();
  }
}

class _DatabaseDetailPage extends State<DatabaseDetailPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => DatabaseDetailModel(),
      builder: (context, child) {
        return DefaultTabController(
          length: Provider.of<DatabaseDetailModel>(context).tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text('数据库详情'),
              bottom: TabBar(
                tabs:
                    Provider.of<DatabaseDetailModel>(context).getTabs(context),
                isScrollable: true,
              ),
            ),
            endDrawer: Drawer(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      UserAccountsDrawerHeader(
                          accountName: Text('程序内置数据库 '),
                          accountEmail: Text('基于sqlfilte'),
                        otherAccountsPictures: [FlatButton(
                          child: Icon(Icons.file_download,color: Colors.white,),
                          onPressed: ()async{
                            var state = await Permission.storage
                                .request()
                                .isGranted;
                            if (state) {
                              try{
                                String path = await FilePicker.platform.getDirectoryPath();
                                String save = await Provider.of<
                                    DatabaseDetailModel>(context, listen: false)
                                    .backupDatabase(path);
                                if (save!=null) {
                                  Navigator.of(context).pop();
                                  Toast.show("已保存至:$save", context,
                                      duration: Toast.LENGTH_LONG);
                                } else {
                                  Toast.show("保存失败，请检查写入权限", context,
                                      duration: Toast.LENGTH_LONG);
                                }
                              }catch(e){
                                Toast.show("保存失败，请检查写入权限", context,
                                    duration: Toast.LENGTH_LONG);
                              }
                            }
                          },
                          shape: CircleBorder(),
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        ),
                          FlatButton(
                            child: Icon(Icons.file_upload,color: Colors.white,),
                            shape: CircleBorder(),
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            onPressed: ()async{
                              try{
                                var result = await FilePicker.platform.pickFiles(type: FileType.any);
                                bool flag=await Provider.of<
                                    DatabaseDetailModel>(context, listen: false).recoverDatabase(result.paths.first);
                                if(flag){
                                  Navigator.of(context).pop();
                                  Toast.show("以从文件恢复数据库", context,
                                      duration: Toast.LENGTH_LONG);
                                }else{
                                  Toast.show("文件恢复失败，请检查写入权限", context,
                                      duration: Toast.LENGTH_LONG);
                                }
                              }catch(e){
                                Toast.show("文件恢复失败，请检查写入权限", context,
                                    duration: Toast.LENGTH_LONG);
                              }
                            },
                          )
                        ],
                      ),
                      ListTile(
                        title: Text('数据库版本'),
                        subtitle: Text(
                            '${Provider.of<DatabaseDetailModel>(context).version}'),
                      ),
                      ListTile(
                        title: Text('数据库地址'),
                        subtitle: Text(
                            '${Provider.of<DatabaseDetailModel>(context).path}'),
                      ),
                      ListTile(
                        title: Text('当前数据库表数量'),
                        subtitle: Text(
                            '${Provider.of<DatabaseDetailModel>(context).tabs.length}'),
                      ),
                      Divider(),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: Provider.of<DatabaseDetailModel>(context)
                        .getDatabaseDefine,
                    itemCount:
                        Provider.of<DatabaseDetailModel>(context).tabs.length,
                  )
                ],
              ),
            )),
            body: TabBarView(
              children: Provider.of<DatabaseDetailModel>(context)
                  .getTabViews(context),
            ),
          ),
        );
      },
    );
  }
}
