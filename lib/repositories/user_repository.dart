import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:todo_app/constants/api.dart';
import 'package:todo_app/constants/exception.dart';
import 'package:todo_app/models/signin_model.dart';
import 'package:todo_app/models/signup_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  static final storage = FlutterSecureStorage();

// 회원가입
  Future signup({
    required SignupModel signupModel,
  }) async {
    String url = '${API}/users/signup';
    final signupModelToJson = signupModel.toJson();

    try {
      final Response response = await http.post(Uri.parse(url), body: signupModelToJson);
      final res = json.decode(response.body);

      if (response.statusCode == 201) {
        await storage.write(
          key: 'token',
          value: res['data']['accessToken'],
        );
      }

      return res;
    } catch (error) {
      return INTERNAL_SERVER_ERROR;
    }
  }

  // 로그인
  Future signin({
    required SigninModel signinModel,
  }) async {
    String url = '${API}/users/signin';
    final signinModelToJson = signinModel.toJson();

    try {
      final Response response = await http.post(Uri.parse(url), body: signinModelToJson);
      final res = json.decode(response.body);

      if (response.statusCode == 200) {
        await storage.write(
          key: 'token',
          value: res['data']['accessToken'],
        );
      }
      return res;
    } catch (error) {
      return INTERNAL_SERVER_ERROR;
    }
  }

  // 내 정보보기
  Future getProfile() async {
    String url = '${API}/users/me';

    try {
      String? token = await storage.read(key: 'token');

      final Response response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "bearer " + token!},
      );

      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        return res['data']['email'];
      } else {
        return '';
      }
    } catch (error) {
      return '';
    }
  }
}
