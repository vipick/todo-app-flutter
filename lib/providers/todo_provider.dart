import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/repositories/todo_repository.dart';

class TodoProvider extends ChangeNotifier {
  final TodoRepository todoRepository;
  Map<String, dynamic> todoCache = {};
  String todayCache = '';

  TodoProvider({
    required this.todoRepository,
  }) : super() {
    getTodos(getToday());
    getTodayFromCache();
  }
  void getTodayFromCache() {
    todayCache = getToday();
    notifyListeners();
  }

  void setTodayToCache(String today) {
    todayCache = today;
    notifyListeners();
  }

// ToDo 리스트
  Future getTodos(String today) async {
    final res = await todoRepository.getTodos(today);
    todoCache.update('todos', (value) => res, ifAbsent: () => res);
    notifyListeners();
    return;
  }

  // ToDo 추가하기
  Future addTodo({required TodoModel todoModel, required String categoryName}) async {
    var todoObj = todoModel.toJson();
    var res = await todoRepository.addTodo(todoObj);

    if (res['statusCode'] == 201) {
      int todoId = res['data']['id'];
      todoObj['id'] = todoId;
      todoObj['categoryName'] = categoryName;

      todoCache['todos'].add(todoObj);
      await todoCache.update('todos', (value) => todoCache['todos'], ifAbsent: () => []);
    }
    notifyListeners();
    return res;
  }

  // ToDo 수정
  Future updateTodo(
      {required String todoId, required String categoryName, required TodoModel todoModel}) async {
    var todoObj = todoModel.toJson();
    var res = await todoRepository.updateTodo(todoId, todoObj);

    if (res['statusCode'] == 200) {
      var result = await todoCache['todos'].map((item) {
        if (item['id'] == int.parse(todoId)) {
          item['categoryName'] = categoryName;
          item['categoryId'] = todoModel.categoryId;
          item['status'] = todoModel.status;
          item['memo'] = todoModel.memo;
          item['today'] = todoModel.today;
        }
        return item;
      }).toList();
      await todoCache.update('todos', (value) => result, ifAbsent: () => []);
      notifyListeners();
    }

    return res;
  }

  // ToDo 삭제
  Future deleteTodo({required String todoId}) async {
    var res = await todoRepository.deleteTodo(todoId);
    if (res['statusCode'] == 200) {
      var result = todoCache['todos'].where((item) => item['id'] != int.parse(todoId)).toList();
      todoCache.update('todos', (value) => result, ifAbsent: () => []);
    }
    notifyListeners();
    return res;
  }
}

String getToday() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  String strToday = formatter.format(now);
  return strToday;
}
