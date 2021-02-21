import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/EmptyView.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/model/comicAuthorModel.dart';
import 'package:provider/provider.dart';

class AuthorPage extends StatefulWidget {
  final int authorId;
  final String author;

  AuthorPage(this.authorId, this.author);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AuthorPage();
  }
}

class _AuthorPage extends State<AuthorPage> {
  _AuthorPage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => ComicAuthorModel(widget.authorId),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).AuthorPageTitle(widget.author)),
          ),
          body: EasyRefresh(
            onRefresh: () async {
              await Provider.of<ComicAuthorModel>(context, listen: false)
                  .init();
            },
            emptyWidget: Provider.of<ComicAuthorModel>(context).empty
                ? EmptyView()
                : null,
            scrollController: ScrollController(),
            firstRefreshWidget: LoadingCube(),
            firstRefresh: true,
            child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                children: Provider.of<ComicAuthorModel>(context)
                    .buildAuthorWidget(context)),
          ),
        );
      },
    );
  }
}
