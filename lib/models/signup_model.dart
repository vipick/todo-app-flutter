import 'package:flutter/material.dart';

class SignupModel extends ChangeNotifier {
  String email = "";
  String password = "";
  String passwordConfirm = "";

  void setEmail(String email) {
    this.email = email;
  }

  void setPassword(String password) {
    this.password = password;
  }

  void setPasswordConfirm(String passwordConfirm) {
    this.passwordConfirm = passwordConfirm;
  }

  String getPassword() {
    return this.password;
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
