import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:todo_app/constants/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/constants/exception.dart';
import 'package:todo_app/models/template_model.dart';

class TemplateRepository {
  static final storage = FlutterSecureStorage();

// 템플릿 리스트
  Future getTemplates() async {
    const String url = '${API}/templates';

    try {
      final String? token = await storage.read(key: 'token');
      final Response response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res['data']['templates'];
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  // 템플릿 추가
  Future addTemplate(TemplateModel templateModel) async {
    const String url = '${API}/templates';

    try {
      String? token = await storage.read(key: 'token');
      final Response response = await http.post(
        Uri.parse(url),
        body: {'name': templateModel.name},
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      final res = json.decode(response.body);
      return res;
    } catch (error) {
      return INTERNAL_SERVER_ERROR;
    }
  }

  // 템플릿 수정
  Future updateTemplate(String templateId, TemplateModel templateModel) async {
    final String url = '${API}/templates/${templateId}';

    try {
      String? token = await storage.read(key: 'token');
      final Response response = await http.patch(
        Uri.parse(url),
        body: {'name': templateModel.name},
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      final res = json.decode(response.body);
      return res;
    } catch (error) {
      return INTERNAL_SERVER_ERROR;
    }
  }

  // 템플릿 삭제
  Future deleteTemplate(String id) async {
    final String url = '${API}/templates/${id}';

    try {
      final String? token = await storage.read(key: 'token');
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
