import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/constants/regular_expression.dart';
import 'package:todo_app/models/signup_model.dart';
import 'package:todo_app/repositories/user_repository.dart';
import 'package:todo_app/screens/index_screen.dart';

final GlobalKey<FormState> formKey = GlobalKey();

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => SignupModel(),
        child: Scaffold(
            appBar: AppBar(
              title: Text('회원가입'),
            ),
            body: Form(
                key: formKey,
                child: Column(
                  children: [
                    EmailInput(),
                    PasswordInput(),
                    PasswordConfirmInput(),
                    SignupButton(),
                  ],
                ))));
  }
}

class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final signupModel = Provider.of<SignupModel>(context, listen: false);

    return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: TextFormField(
          onChanged: (email) {
            signupModel.setEmail(email);
          },
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: '이메일', helperText: ''),
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
    final signupModel = Provider.of<SignupModel>(context, listen: false);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextFormField(
        onChanged: (password) {
          signupModel.setPassword(password);
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

class PasswordConfirmInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final signupModel = Provider.of<SignupModel>(context);

    return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: TextFormField(
          onChanged: (passwordConfirm) {
            signupModel.setPasswordConfirm(passwordConfirm);
          },
          obscureText: true,
          decoration: InputDecoration(labelText: '패스워드 확인', helperText: ''),
          validator: (passwordConfirm) {
            if (passwordConfirm!.isEmpty) {
              return '패스워드를 입력하세요.';
            }

            if (passwordConfirm.length < 4) {
              return '패스워드는 4글자 이상이어야 합니다.';
            }

            if (passwordConfirm != signupModel.getPassword()) {
              return '두 패스워드가 일치하지 않습니다.';
            }
            return null;
          },
        ));
  }
}

class SignupButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final signupModel = Provider.of<SignupModel>(context, listen: false);

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
              var res = await userRepository.signup(signupModel: signupModel);

              if (res['statusCode'] == 201) {
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
          child: Text('회원 가입')),
    );
  }
}
