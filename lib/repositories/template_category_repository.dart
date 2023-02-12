import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:todo_app/constants/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/constants/exception.dart';

class TemplateCategoryRepository {
  static final storage = FlutterSecureStorage();

// 모든 템플릿의 카테고리 리스트
  Future getTemplateCategories() async {
    const String url = '${API}/templates/categories';

    try {
      String? token = await storage.read(key: 'token');
      final Response response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        return res['data']['templateCategories'];
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  // 템플릿에 카테고리 추가하기
  Future addCategoryToTemplate(String templateId, String categoryId) async {
    String url = '${API}/templates/${templateId}/categories/${categoryId}';

    try {
      String? token = await storage.read(key: 'token');
      final Response response = await http.post(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      final res = json.decode(response.body);
      return res;
    } catch (error) {
      return INTERNAL_SERVER_ERROR;
    }
  }

  // 템플릿에서 카테고리 제거하기
  Future removeCategoryFromTemplate(String templateId, List? categoryList) async {
    String url = '${API}/templates/${templateId}/categories';

    try {
      String? token = await storage.read(key: 'token');
      final Response response = await http.delete(
        Uri.parse(url),
        body: {'templateCategoryIds': json.encode(categoryList)},
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      final res = json.decode(response.body);
      return res;
    } catch (error) {
      return INTERNAL_SERVER_ERROR;
    }
  }

  // 템플릿을 ToDo 를 복사
  Future copyTemplate(String id, String date) async {
    String url = '${API}/templates/${id}/todo-copy';

    try {
      String? token = await storage.read(key: 'token');
      final Response response = await http.post(
        Uri.parse(url),
        body: {'today': date},
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      final res = json.decode(response.body);
      return res;
    } catch (error) {
      return INTERNAL_SERVER_ERROR;
    }
  }
}
