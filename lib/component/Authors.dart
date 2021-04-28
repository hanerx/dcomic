import 'package:dcomic/model/comicCategoryModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/view/author_page.dart';

class Authors extends StatelessWidget {
  final List<CategoryModel> tags;

  Authors(this.tags);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextButton(
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
      child: Text(
          '${tags.map((value) {
                return value.title;
              }).toList().join('/')}',
          style: Theme.of(context).textTheme.bodyText1),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text('作者'),
                children: tags.map((value) {
                  return SimpleDialogOption(
                    child: Text('${value.title}'),
                    onPressed: () {
                      Navigator.pop(context);
                      if (value.categoryId != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) {
                                  return AuthorPage(
                                      author: value.title,
                                      authorId: value.categoryId,
                                      model: value.model);
                                },
                                settings: RouteSettings(name: 'author_page')));
                      }
                    },
                  );
                }).toList(),
              );
            });
      },
    );
  }
}
