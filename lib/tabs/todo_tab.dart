import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/providers/category_provider.dart';
import 'package:todo_app/providers/todo_provider.dart';

final GlobalKey<FormState> formKey = GlobalKey();

class TodoTab extends StatefulWidget {
  const TodoTab({Key? key}) : super(key: key);

  @override
  State<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends State<TodoTab> {
  @override
  Widget build(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final todos = todoProvider.todoCache['todos'] ?? [];
    String todayFromCache = todoProvider.todayCache;
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categoryCache['categories'] ?? [];
    List categoryList = categories.map((item) {
      return {'id': item['id'], 'name': item['name']};
    }).toList();

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Text('+', style: TextStyle(fontSize: 25)),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  String categoryId =
                      categoryList.length > 0 ? categoryList[0]['id'].toString() : "";
                  String? status = 'TODO';
                  String categoryName = categoryList.length > 0 ? categoryList[0]['name'] : "";
                  String memo = '';

                  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                        title: Text('ToDo 추가하기'),
                        content: Container(
                            height: 250,
                            child: Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 200,
                                      child: DropdownButtonFormField(
                                        isExpanded: true,
                                        value: categoryId,
                                        items: categoryList.map((item) {
                                          return DropdownMenuItem(
                                            child: Text('${item['name']}'),
                                            value: item['id'].toString(),
                                          );
                                        }).toList(),
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            categoryId = value;
                                            categoryName = categoryList.firstWhere((item) =>
                                                item['id'] == int.parse(categoryId))['name'];
                                          });
                                        },
                                        validator: (name) {
                                          if (name!.isEmpty) {
                                            return '카테고리를 입력하세요.';
                                          }

                                          return null;
                                        },
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: const Text('TODO'),
                                          leading: Radio(
                                            value: 'TODO',
                                            groupValue: status,
                                            onChanged: (value) {
                                              setState(() {
                                                status = value;
                                              });
                                            },
                                          ),
                                        ),
                                        ListTile(
                                          title: const Text('DONE'),
                                          leading: Radio(
                                            value: 'DONE',
                                            groupValue: status,
                                            onChanged: (value) {
                                              setState(() {
                                                status = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                        child: TextFormField(
                                      maxLength: 20,
                                      onChanged: (value) {
                                        setState(() {
                                          memo = value;
                                        });
                                      },
                                      decoration: InputDecoration(labelText: '메모'),
                                    ))
                                  ],
                                ))),
                        actions: [
                          TextButton(
                              child: Text('추가'),
                              onPressed: () => onAddPressed(
                                    context,
                                    categoryName,
                                    TodoModel(
                                        categoryId: categoryId,
                                        status: status,
                                        memo: memo,
                                        today: todayFromCache),
                                  )),
                          TextButton(
                              child: Text('취소'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ]);
                  });
                });
          },
        ),
        appBar: AppBar(
          title: Text('${todayFromCache}'),
          centerTitle: true,
          backgroundColor: Colors.grey,
          leading: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 4),
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                  icon: Icon(
                    Icons.exposure_minus_1,
                  ),
                  onPressed: () {
                    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
                    DateTime today = DateTime.parse(todoProvider.todayCache);
                    DateTime minusToday = today.subtract(const Duration(days: 1));

                    DateFormat formatter = DateFormat('yyyy-MM-dd');
                    String minusTodayString = formatter.format(minusToday).toString();

                    todoProvider.setTodayToCache(minusTodayString);
                    // 해당 날짜로 ToDo 리스트 가져오기
                    onDatePressed(context, minusTodayString);
                    setState(() {
                      todayFromCache = minusTodayString;
                    });
                  })),
          actions: [
            Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 4),
                  color: Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                    icon: Icon(Icons.exposure_plus_1),
                    onPressed: () {
                      final todoProvider = Provider.of<TodoProvider>(context, listen: false);
                      DateTime today = DateTime.parse(todoProvider.todayCache);
                      DateTime plusToday = today.add(const Duration(days: 1));

                      DateFormat formatter = DateFormat('yyyy-MM-dd');
                      String plusTodayString = formatter.format(plusToday).toString();

                      todoProvider.setTodayToCache(plusTodayString);
                      // 해당 날짜로 ToDo 리스트 가져오기
                      onDatePressed(context, plusTodayString);

                      setState(() {
                        todayFromCache = plusTodayString;
                      });
                    }))
          ],
        ),
        body: ListView.separated(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text('[${todos[index]['status']}] ${todos[index]['categoryName']}'),
                  subtitle: todos[index]['memo'] == null
                      ? Text('${todos[index]['today']}')
                      : Text('${todos[index]['today']}  ${todos[index]['memo']}'),
                  tileColor: todos[index]['status'] == 'DONE' ? Colors.grey : null,
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
                                        //기존 값 불러오기
                                        String categoryId = todos[index]['categoryId'].toString();
                                        String categoryName = todos[index]['categoryName'];
                                        String memo = todos[index]['memo'] == null
                                            ? ''
                                            : todos[index]['memo'];
                                        String? status = todos[index]['status'];

                                        return StatefulBuilder(
                                            builder: (BuildContext context, StateSetter setState) {
                                          return AlertDialog(
                                            title: Text('ToDo 수정하기'),
                                            content: Container(
                                                height: 250,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                        width: 200,
                                                        child: DropdownButton(
                                                          isExpanded: true,
                                                          value: categoryId,
                                                          items: categoryList.map((item) {
                                                            return DropdownMenuItem(
                                                              child: Text('${item['name']}'),
                                                              value: item['id'].toString(),
                                                            );
                                                          }).toList(),
                                                          onChanged: (dynamic value) {
                                                            setState(() {
                                                              categoryId = value;
                                                              categoryName =
                                                                  categoryList.firstWhere((item) =>
                                                                      item['id'] ==
                                                                      int.parse(
                                                                          categoryId))['name'];
                                                            });
                                                          },
                                                        )),
                                                    Column(
                                                      children: <Widget>[
                                                        ListTile(
                                                          title: const Text('TODO'),
                                                          leading: Radio(
                                                            value: 'TODO',
                                                            groupValue: status,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                status = value;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                        ListTile(
                                                          title: const Text('DONE'),
                                                          leading: Radio(
                                                            value: 'DONE',
                                                            groupValue: status,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                status = value;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                        child: TextFormField(
                                                      maxLength: 20,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          memo = value;
                                                        });
                                                      },
                                                      decoration: InputDecoration(hintText: memo),
                                                    ))
                                                  ],
                                                )),
                                            actions: [
                                              TextButton(
                                                  child: Text('수정'),
                                                  onPressed: () async {
                                                    String id = todos[index]['id'].toString();

                                                    onUpdatePressed(
                                                      context,
                                                      id,
                                                      categoryName,
                                                      TodoModel(
                                                          categoryId: categoryId,
                                                          status: status,
                                                          memo: memo,
                                                          today: todayFromCache),
                                                    );
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
                                        //
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
                                            title: Text('ToDo 삭제하기'),
                                            content: Container(
                                              child: Text('삭제하시겠습니까?'),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text('삭제'),
                                                onPressed: () async {
                                                  String id = todos[index]['id'].toString();
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

// ToDO 추가
  void onAddPressed(BuildContext context, String categoryName, TodoModel todoModel) async {
    if (formKey.currentState!.validate()) {
      var res = await context
          .read<TodoProvider>()
          .addTodo(todoModel: todoModel, categoryName: categoryName);

      var statusCode = res!['statusCode'];
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

  // ToDO 수정
  void onUpdatePressed(
      BuildContext context, String id, String categoryName, TodoModel todoModel) async {
    var res = await context.read<TodoProvider>().updateTodo(
          todoId: id,
          categoryName: categoryName,
          todoModel: todoModel,
        );

    if (res['statusCode'] != 200) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(res['message'])),
        );
    }
    Navigator.of(context).pop();
  }

  // ToDO 삭제
  void onDeletePressed(BuildContext context, String id) async {
    var res = await context.read<TodoProvider>().deleteTodo(todoId: id);
    if (res['statusCode'] != 200) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(res['message'])),
        );
    }
    Navigator.of(context).pop();
  }

  //ToDO 날짜 선택 +1, -1
  onDatePressed(BuildContext context, String today) async {
    await context.read<TodoProvider>().getTodos(today);
  }
}
