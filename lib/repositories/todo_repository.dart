import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:todo_app/constants/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/constants/exception.dart';

class TodoRepository {
  static final storage = FlutterSecureStorage();

// ToDo 리스트
  Future getTodos(String today) async {
    final String url = '${API}/todos?today=${today}';

    try {
      String? token = await storage.read(key: 'token');
      final Response response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res['data']['todos'];
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

// ToDo 추가
  Future addTodo(Object todo) async {
    final String url = '${API}/todos';

    try {
      String? token = await storage.read(key: 'token');
      final Response response = await http.post(
        Uri.parse(url),
        body: todo,
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      final res = json.decode(response.body);
      return res;
    } catch (error) {
      return INTERNAL_SERVER_ERROR;
    }
  }

// ToDO 수정
  Future updateTodo(String todoId, Object todoObj) async {
    String url = '${API}/todos/${todoId}';

    try {
      String? token = await storage.read(key: 'token');
      final Response response = await http.patch(
        Uri.parse(url),
        body: todoObj,
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      final res = json.decode(response.body);
      return res;
    } catch (error) {
      print(error);
      return INTERNAL_SERVER_ERROR;
    }
  }

  // ToDO 삭제
  Future deleteTodo(String id) async {
    String url = '${API}/todos/${id}';

    try {
      String? token = await storage.read(key: 'token');
      final Response response = await http.delete(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      final res = json.decode(response.body);
      return res;
    } catch (error) {
      return INTERNAL_SERVER_ERROR;
    }
  }
}
