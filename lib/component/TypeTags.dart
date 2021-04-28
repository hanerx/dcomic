import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/view/category_detail_page.dart';

class TypeTags extends StatelessWidget {
  final List tags;

  TypeTags(this.tags);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextButton(
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
      child: Text(
          '${tags.map((value) {
                return value['tag_name'];
              }).toList().join('/')}',
          style: Theme.of(context).textTheme.bodyText1),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text('分类'),
                children: tags.map((value) {
                  return SimpleDialogOption(
                    child: Text('${value['tag_name']}'),
                    onPressed: () {
                      Navigator.pop(context);
                      if (value['tag_name'] != null) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return CategoryDetailPage(
                              categoryId: value['tag_id'],
                              title: value['tag_name']);
                        }));
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
