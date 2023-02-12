import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/providers/category_provider.dart';

final GlobalKey<FormState> formKey = GlobalKey();

class CategoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categoryCache['categories'] ?? [];

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Text('+', style: TextStyle(fontSize: 25)),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  String name = '';

                  return AlertDialog(
                      title: Text('카테고리 추가하기'),
                      content: Container(
                          height: 100,
                          child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                      onChanged: (value) {
                                        name = value;
                                      },
                                      decoration: InputDecoration(labelText: '카테고리'),
                                      validator: (name) {
                                        if (name!.isEmpty) {
                                          return '카테고리를 입력하세요.';
                                        }

                                        if (name.length < 2) {
                                          return '카테고리는 2글자 이상이어야 합니다.';
                                        }
                                        return null;
                                      }),
                                ],
                              ))),
                      actions: [
                        TextButton(child: Text('추가'), onPressed: () => onAddPressed(context, name)),
                        TextButton(
                            child: Text('취소'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                      ]);
                });
          },
        ),
        body: ListView.separated(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final String id = categories[index]['id'].toString();
              String name = categories[index]['name'];

              return ListTile(
                  title: Text(name),
                  onTap: () {},
                  trailing: Container(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              padding: EdgeInsets.all(5),
                              child: InkWell(
                                child: Icon(Icons.edit),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('카테고리 수정하기'),
                                          content: Container(
                                              height: 100,
                                              child: Form(
                                                  key: formKey,
                                                  child: Column(
                                                    children: [
                                                      TextFormField(
                                                          onChanged: (value) {
                                                            name = value;
                                                          },
                                                          decoration:
                                                              InputDecoration(hintText: name),
                                                          validator: (name) {
                                                            if (name!.isEmpty) {
                                                              return '카테고리를 입력하세요.';
                                                            }

                                                            if (name.length < 2) {
                                                              return '카테고리는 2글자 이상이어야 합니다.';
                                                            }

                                                            if (name == categories[index]['name']) {
                                                              return '같은 이름으로 수정할 수 없습니다.';
                                                            }
                                                            return null;
                                                          })
                                                    ],
                                                  ))),
                                          actions: [
                                            TextButton(
                                                child: Text('수정'),
                                                onPressed: () async {
                                                  onUpdatePressed(context, id, name);
                                                }),
                                            TextButton(
                                              child: Text('취소'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      });
                                },
                              )),
                          Container(
                              padding: EdgeInsets.all(5),
                              child: InkWell(
                                  child: Icon(Icons.delete),
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('카테고리 삭제하기'),
                                            content: Container(
                                              child: Text('삭제하시겠습니까?'),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text('삭제'),
                                                onPressed: () async {
                                                  onDeletePressed(context, id);
                                                },
                                              ),
                                              TextButton(
                                                  child: Text('취소'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  })
                                            ],
                                          );
                                        });
                                  }))
                        ],
                      )));
            },
            separatorBuilder: (context, index) {
              return Divider();
            }));
  }
}

// 카테고리 추가
void onAddPressed(BuildContext context, String name) async {
  if (formKey.currentState!.validate()) {
    var res = await context
        .read<CategoryProvider>()
        .addCategory(categoryModel: CategoryModel(name: name));
    var statusCode = res['statusCode'];
    if (statusCode != 201) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(res['message'])),
        );
    }
    Navigator.of(context).pop();
  }
}

// 카테고리 수정
void onUpdatePressed(BuildContext context, String id, String name) async {
  if (formKey.currentState!.validate()) {
    var res = await context
        .read<CategoryProvider>()
        .updateCategory(categoryId: id, categoryModel: CategoryModel(name: name));
    if (res['statusCode'] != 200) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(res['message'])),
        );
    }
    Navigator.of(context).pop();
  }
}

// 카테고리 삭제
void onDeletePressed(BuildContext context, String id) async {
  var res = await context.read<CategoryProvider>().deleteCategory(categoryId: id);
  if (res['statusCode'] != 200) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(res['message'])),
      );
  }
  Navigator.of(context).pop();
}
