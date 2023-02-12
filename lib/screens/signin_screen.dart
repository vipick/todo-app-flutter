import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/constants/regular_expression.dart';
import 'package:todo_app/models/signin_model.dart';
import 'package:todo_app/providers/category_provider.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/repositories/user_repository.dart';
import 'package:todo_app/screens/index_screen.dart';

final GlobalKey<FormState> formKey = GlobalKey();

class SigninScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => SigninModel(),
        child: Scaffold(
            appBar: AppBar(
              title: Text("로그인"),
            ),
            body: Form(
                key: formKey,
                child: Column(
                  children: [
                    EmailInput(),
                    PasswordInput(),
                    SigninButton(),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Divider(thickness: 1),
                    ),
                    SignupButton()
                  ],
                ))));
  }
}

class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final signinModel = Provider.of<SigninModel>(context, listen: false);

    return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: TextFormField(
          onChanged: (email) {
            signinModel.setEmail(email);
          },
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: '이메일',
            helperText: '',
          ),
          validator: (email) {
            if (email!.isEmpty) {
              return '이메일을 입력하세요.';
            }

            RegExp regExp = new RegExp(EMAIL_PATTERN);
            if (!regExp.hasMatch(email)) {
              return '잘못된 이메일 형식입니다.';
            }

            if (email.length < 4) {
              return '이메일은 4글자 이상이어야 합니다.';
            }
            return null;
          },
        ));
  }
}

class PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final signinModel = Provider.of<SigninModel>(context, listen: false);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextFormField(
        onChanged: (password) {
          signinModel.setPassword(password);
        },
        obscureText: true,
        decoration: InputDecoration(labelText: '패스워드', helperText: ''),
        validator: (password) {
          if (password!.isEmpty) {
            return '패스워드를 입력하세요.';
          }

          if (password.length < 4) {
            return '패스워드는 4글자 이상이어야 합니다.';
          }

          RegExp regExp = new RegExp(PASSWORD_PATTERN);
          if (!regExp.hasMatch(password)) {
            return '패스워드는 숫자 또는 알파벳 형식입니다.';
          }
          return null;
        },
      ),
    );
  }
}

class SigninButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final signinModel = Provider.of<SigninModel>(context, listen: false);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          )),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              UserRepository userRepository = new UserRepository();
              var res = await userRepository.signin(signinModel: signinModel);

              if (res['statusCode'] == 200) {
                //ToDo 리스트 가져오기
                final todoProvider = await Provider.of<TodoProvider>(context, listen: false);
                await todoProvider.getTodos(getToday());
                final categoryProvider =
                    await Provider.of<CategoryProvider>(context, listen: false);
                await categoryProvider.getCategories();

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(res['message'])),
                  );
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(builder: (context) => IndexScreen()),
                );
              } else {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(res['message'])),
                  );
              }
            }
          },
          child: Text('로그인')),
    );
  }
}

class SignupButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/signup');
      },
      child: Text(
        '이메일로 회원가입 하기',
        style: TextStyle(color: theme.primaryColor),
      ),
    );
  }
}

String getToday() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  String strToday = formatter.format(now);
  return strToday;
}
