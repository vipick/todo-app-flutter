import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/category_provider.dart';
import 'package:todo_app/providers/template_category_provider.dart';
import 'package:todo_app/providers/template_provider.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/providers/user_provider.dart';
import 'package:todo_app/repositories/category_repository.dart';
import 'package:todo_app/repositories/template_category_repository.dart';
import 'package:todo_app/repositories/template_repository.dart';
import 'package:todo_app/repositories/todo_repository.dart';
import 'package:todo_app/repositories/user_repository.dart';
import 'package:todo_app/screens/index_screen.dart';
import 'package:todo_app/screens/signin_screen.dart';
import 'package:todo_app/screens/signup_screen.dart';
import 'package:todo_app/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    final userProvier = UserProvider(userRepository: userRepository);
    final categoryRepository = CategoryRepository();
    final categoryProvier = CategoryProvider(categoryRepository: categoryRepository);
    final todoRepository = TodoRepository();
    final todoProvier = TodoProvider(todoRepository: todoRepository);
    final templateRepository = TemplateRepository();
    final templateProvier = TemplateProvider(templateRepository: templateRepository);
    final templateCategoryRepository = TemplateCategoryRepository();
    final templateCategoryProvier =
        TemplateCategoryProvider(templateCategoryRepository: templateCategoryRepository);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => userProvier),
          ChangeNotifierProvider(create: (_) => categoryProvier),
          ChangeNotifierProvider(create: (_) => todoProvier),
          ChangeNotifierProvider(create: (_) => templateProvier),
          ChangeNotifierProvider(create: (_) => templateCategoryProvier)
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ToDo 리스트',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          routes: {
            '/': (context) => SplashScreen(),
            '/index': (context) => IndexScreen(),
            '/signup': (context) => SignupScreen(),
            '/signin': (context) => SigninScreen(),
          },
          initialRoute: '/',
        ));
  }
}
