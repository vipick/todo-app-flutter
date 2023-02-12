import 'dart:async';
import 'package:flutter/material.dart';
import 'package:todo_app/repositories/user_repository.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserRepository repository = UserRepository();

  Future<bool> checkSignin() async {
    //내 정보보기 api 호출 후 401, 500 에러 이면 false
    final resp = await repository.getProfile();
    if (resp == '') {
      return false;
    } else {
      return true;
    }
  }

  void moveScreen() async {
    await checkSignin().then((isSignin) {
      if (isSignin) {
        Navigator.of(context).pushReplacementNamed('/index');
      } else {
        Navigator.of(context).pushReplacementNamed('/signin');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 1500), () {
      moveScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.today,
          size: 100,
          color: Colors.blue,
        ),
        Text('ToDo 리스트')
      ],
    )));
  }
}
