import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:todo_app/constants/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/constants/exception.dart';
import 'package:todo_app/models/category_model.dart';

class CategoryRepository {
  static final storage = FlutterSecureStorage();

  //카테고리 리스트 API
  Future<List> getCategories() async {
    const String url = '${API}/categories';

    try {
      final String? token = await storage.read(key: 'token');
      final Response response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        return res['data']['categories'];
      } else {
        return []; //백엔드 예외
      }
    } catch (error) {
      return []; //프런트엔드 예외
    }
  }

  //카테고리 추가 API
  Future addCategory(CategoryModel categoryModel) async {
    const String url = '${API}/categories';

    try {
      String? token = await storage.read(key: 'token');
      final Response response = await http.post(
        Uri.parse(url),
        body: {'name': categoryModel.name},
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      final res = json.decode(response.body);
      return res;
    } catch (error) {
      return INTERNAL_SERVER_ERROR;
    }
  }

  //카테고리 수정 API
  Future updateCategory({required String categoryId, required CategoryModel categoryModel}) async {
    String url = '${API}/categories/${categoryId}';

    try {
      String? token = await storage.read(key: 'token');
      final Response response = await http.patch(
        Uri.parse(url),
        body: {'name': categoryModel.name},
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      final res = json.decode(response.body);
      return res;
    } catch (error) {
      return INTERNAL_SERVER_ERROR;
    }
  }

  //카테고리 삭제 API
  Future deleteCategory(String categoryId) async {
    String url = '${API}/categories/${categoryId}';

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
