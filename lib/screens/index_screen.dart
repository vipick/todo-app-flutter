import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/category_provider.dart';
import 'package:todo_app/providers/template_category_provider.dart';
import 'package:todo_app/providers/template_provider.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/providers/user_provider.dart';
import 'package:todo_app/tabs/category_tab.dart';
import 'package:todo_app/tabs/profile_tab.dart';
import 'package:todo_app/tabs/template_tab.dart';
import 'package:todo_app/tabs/todo_tab.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    TodoTab(),
    CategoryTab(),
    TemplateTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontSize: 12),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            //ToDo 탭 클릭시 변경 사항있는 경우 다시 호출
            if (index == 0) {
              final todoProvider = Provider.of<TodoProvider>(context, listen: false);
              todoProvider.getTodos(getToday());
              todoProvider.getTodayFromCache();
            } else if (index == 1) {
              final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
              categoryProvider.getCategories();
            } else if (index == 2) {
              final templateProvider = Provider.of<TemplateProvider>(context, listen: false);
              templateProvider.getTemplates();
              final templateCategoryProvider =
                  Provider.of<TemplateCategoryProvider>(context, listen: false);
              templateCategoryProvider.getTemplateCategories();
              final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
              categoryProvider.getCategories();
            } else if (index == 3) {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.getProfile();
            }
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Todo'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: '카테고리'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: '템플릿'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: '프로필')
        ],
      ),
      body: _tabs[_currentIndex],
    );
  }
}

// 오늘 날짜 가져오기
String getToday() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  String strToday = formatter.format(now);
  return strToday;
}
