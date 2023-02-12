import 'package:flutter/material.dart';

class SigninModel extends ChangeNotifier {
  String email = "";
  String password = "";

  void setEmail(String email) {
    this.email = email;
  }

  void setPassword(String password) {
    this.password = password;
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
