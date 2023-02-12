import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/user_provider.dart';
import 'package:todo_app/screens/signin_screen.dart';

class ProfileTab extends StatelessWidget {
  static final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    String profile = userProvider.userCache['email'] ?? '';

    return Scaffold(
        body: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      SizedBox(
        height: 20.0,
      ),
      Container(
          child: Column(children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),
            onPressed: () {
              storage.delete(key: "token");
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(builder: (context) => SigninScreen()),
              );
            },
            child: Text('로그아웃')),
        Text(profile)
      ]))
    ])));
  }
}
