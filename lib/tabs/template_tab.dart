import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/template_model.dart';
import 'package:todo_app/providers/category_provider.dart';
import 'package:todo_app/providers/template_category_provider.dart';
import 'package:todo_app/providers/template_provider.dart';

final GlobalKey<FormState> formKey = GlobalKey();

String globalCategoryId = "";
String globalTemplateId = "";
String globalTemplateName = "";

class TemplateTab extends StatefulWidget {
  const TemplateTab({Key? key}) : super(key: key);

  @override
  State<TemplateTab> createState() => _TemplateTabState();
}

class _TemplateTabState extends State<TemplateTab> {
  List checkListValue = [];

  @override
  Widget build(BuildContext context) {
    final templateProvider = context.watch<TemplateProvider>();
    final templates = templateProvider.templateCache['templates'] ?? [];
    final templateCategoryProvider = context.watch<TemplateCategoryProvider>();
    final templateCategories =
        templateCategoryProvider.templateCategoryCache['templateCategories'] ?? [];
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categoryCache['categories'] ?? [];

    List categoryList = categories.map((item) {
      return {'id': item['id'], 'name': item['name']};
    }).toList();

    List templateList = templates.map((item) {
      return {'id': item['id'], 'name': item['name']};
    }).toList();

    String selectedCategory = globalCategoryId != ""
        ? globalCategoryId
        : categoryList.length > 0
            ? categoryList[0]['id'].toString()
            : "";
    String selectedTemplate = globalTemplateId != ""
        ? globalTemplateId
        : templateList.length > 0
            ? templateList[0]['id'].toString()
            : "";
    String templateName = globalTemplateName != ""
        ? globalTemplateName
        : templateList.length > 0
            ? templateList[0]['name']
            : "";

    String selectedDate = getToday();

    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Text('+', style: TextStyle(fontSize: 25)),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String name = '';

                    return AlertDialog(
                        title: Text('템플릿 추가하기'),
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
                                        decoration: InputDecoration(labelText: '템플릿'),
                                        validator: (name) {
                                          if (name!.isEmpty) {
                                            return '템플릿를 입력하세요.';
                                          }

                                          if (name.length < 2) {
                                            return '템플릿은 2글자 이상이어야 합니다.';
                                          }
                                          return null;
                                        }),
                                  ],
                                ))),
                        actions: [
                          TextButton(
                              child: Text('추가'), onPressed: () => onAddPressed(context, name)),
                          TextButton(
                              child: Text('취소'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ]);
                  });
            },
          ),
          body: Column(children: [
            Container(
              child: Text('템플릿에 카테고리 추가'),
              margin: EdgeInsets.all(10),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Container(
                  height: 50,
                  width: 100,
                  child: DropdownButton(
                    isExpanded: true,
                    value: selectedTemplate,
                    items: templateList.map((item) {
                      return DropdownMenuItem(
                        child: Text('${item['name']}'),
                        value: item['id'].toString(),
                      );
                    }).toList(),
                    onChanged: (dynamic value) {
                      selectedTemplate = value;
                      setState(() {
                        selectedTemplate = value;
                        templateName = templateList.firstWhere(
                            (item) => item['id'] == int.parse(selectedTemplate))['name'];

                        globalTemplateId = selectedTemplate;
                        globalTemplateName = templateName;
                      });
                    },
                  )),
              Container(
                height: 50,
                width: 100,
                child: DropdownButton(
                  isExpanded: true,
                  value: selectedCategory,
                  items: categoryList.map((item) {
                    return DropdownMenuItem(
                      child: Text('${item['name']}'),
                      value: item['id'].toString(),
                    );
                  }).toList(),
                  onChanged: (dynamic value) {
                    setState(() {
                      selectedCategory = value;

                      globalCategoryId = selectedCategory;
                    });
                  },
                ),
              ),
              ElevatedButton(
                  child: Text('추가'),
                  onPressed: () =>
                      onAddTemplatePressed(context, selectedTemplate, selectedCategory)),
            ]),
            Container(
              child: Text('템플릿을 ToDo 에 복사'),
              margin: EdgeInsets.all(10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    width: 70,
                    child: Text(
                      style: TextStyle(height: 1.0),
                      '${templateName}',
                      textAlign: TextAlign.center,
                    )),
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                        icon: Icon(Icons.exposure_minus_1),
                        onPressed: () {
                          DateTime today = DateTime.parse(selectedDate);
                          DateTime minusToday = today.subtract(const Duration(days: 1));

                          DateFormat formatter = DateFormat('yyyy-MM-dd');
                          String minusTodayString = formatter.format(minusToday).toString();

                          setState(() {
                            selectedDate = minusTodayString;
                          });
                        })),
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                        icon: Icon(Icons.exposure_plus_1),
                        onPressed: () {
                          DateTime today = DateTime.parse(selectedDate);
                          DateTime plusToday = today.add(const Duration(days: 1));

                          DateFormat formatter = DateFormat('yyyy-MM-dd');
                          String plusTodayString = formatter.format(plusToday).toString();

                          setState(() {
                            selectedDate = plusTodayString;
                          });
                        })),
                Container(
                    width: 80,
                    child: Text(
                      style: TextStyle(height: 1.0),
                      '${selectedDate}',
                      textAlign: TextAlign.center,
                    )),
                ElevatedButton(
                    child: Text('복사'),
                    onPressed: () =>
                        onCopyTemplatePressed(context, selectedTemplate, selectedDate)),
              ],
            ),
            Expanded(
                child: ListView.separated(
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      String id = templates[index]['id'].toString();
                      String name = templates[index]['name'];
                      String categories = '';
                      templateCategories.forEach((item) {
                        if (item['templateId'].toString() == id) {
                          categories += '(${item['categoryName']})';
                        }
                      });
                      List categoryList = templateCategories
                          .where((item) => item['templateId'].toString() == id)
                          .toList();

                      int categoryCount = categoryList.length;

                      return ListTile(
                          title: Text('${name} : ${categoryCount} 개'),
                          subtitle: Text(categories),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  String name = templates[index]['name'];

                                  return StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                    return AlertDialog(
                                      title: Text('템플릿 : ${name}'),
                                      content: Container(
                                        width: double.maxFinite,
                                        child: ListView(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.all(8.0),
                                          children: categoryList
                                              .map((category) => CheckboxListTile(
                                                    title: Text('${category['categoryName']}'),
                                                    value: checkListValue.indexOf(
                                                                category['id'].toString()) >
                                                            -1
                                                        ? true
                                                        : false,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        if (checkListValue.indexOf(
                                                                category['id'].toString()) >
                                                            -1) {
                                                          checkListValue
                                                              .remove(category['id'].toString());

                                                          return;
                                                        }
                                                        checkListValue
                                                            .add(category['id'].toString());
                                                      });
                                                    },
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            child: Text('삭제'),
                                            onPressed: () async {
                                              onDeleteTemplatePressed(
                                                  context,
                                                  templates[index]['id'].toString(),
                                                  checkListValue);
                                              checkListValue = [];
                                            }),
                                        TextButton(
                                          child: Text('취소'),
                                          onPressed: () {
                                            checkListValue = [];
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  });
                                });
                          },
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
                                                String name = templates[index]['name'];

                                                return AlertDialog(
                                                  title: Text('템플릿 수정하기'),
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
                                                                  decoration: InputDecoration(
                                                                      hintText: templates[index]
                                                                          ['name']),
                                                                  validator: (name) {
                                                                    if (name!.isEmpty) {
                                                                      return '템플릿를 입력하세요.';
                                                                    }

                                                                    if (name.length < 2) {
                                                                      return '템플릿은 2글자 이상이어야 합니다.';
                                                                    }

                                                                    if (name ==
                                                                        templates[index]['name']) {
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
                                                          var id =
                                                              templates[index]['id'].toString();
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
                                                    title: Text('템플릿 삭제하기'),
                                                    content: Container(
                                                      child: Text('삭제하시겠습니까?'),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        child: Text('삭제'),
                                                        onPressed: () async {
                                                          var id =
                                                              templates[index]['id'].toString();

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
                    })),
          ]));
    });
  }
}

// 템플릿 추가
void onAddPressed(BuildContext context, String name) async {
  if (formKey.currentState!.validate()) {
    var res = await context
        .read<TemplateProvider>()
        .addTemplate(templateModel: TemplateModel(name: name));
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

// 템플릿 수정
void onUpdatePressed(BuildContext context, String id, String name) async {
  if (formKey.currentState!.validate()) {
    var res = await context
        .read<TemplateProvider>()
        .updateTemplate(templateId: id, templateModel: TemplateModel(name: name));
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

// 템플릿 삭제
void onDeletePressed(BuildContext context, String id) async {
  globalCategoryId = "";
  globalTemplateId = "";
  globalTemplateName = "";

  var res = await context.read<TemplateProvider>().deleteTemplate(templateId: id);
  if (res['statusCode'] != 200) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(res['message'])),
      );
  }
  Navigator.of(context).pop();
}

// 템플릿에 카테고리 추가
void onAddTemplatePressed(
    BuildContext context, String selectedTemplate, String selectedCategory) async {
  if (selectedTemplate == "" || selectedCategory == "") {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('템플릿과 카테고리를 선택해주세요.')),
      );
    return;
  }
  var res = await context
      .read<TemplateCategoryProvider>()
      .addCategoryToTemplate(selectedTemplate, selectedCategory);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(res['message'])),
    );
}

//템플릿에서 카테고리 리스트 제거
void onDeleteTemplatePressed(BuildContext context, String templateId, List categoryList) async {
  var res = await context
      .read<TemplateCategoryProvider>()
      .removeCategoryFromTemplate(templateId: templateId, categoryList: categoryList);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(res['message'])),
    );
  Navigator.of(context).pop();
}

// 템플릿을 ToDO 에 복사
void onCopyTemplatePressed(
    BuildContext context, String selectedTemplate, String selectedDate) async {
  if (selectedTemplate == "") {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('템플릿를 선택해주세요.')),
      );
    return;
  }
  var res = await context
      .read<TemplateCategoryProvider>()
      .copyTemplate(id: selectedTemplate, date: selectedDate);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(res['message'])),
    );
}

String getToday() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  String strToday = formatter.format(now);
  return strToday;
}
