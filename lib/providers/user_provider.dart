import 'package:flutter/cupertino.dart';
import 'package:todo_app/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository userRepository;
  Map<String, dynamic> userCache = {};

  UserProvider({
    required this.userRepository,
  }) : super() {
    getProfile();
  }

// 내 정보 가져오기
  void getProfile() async {
    final resp = await userRepository.getProfile();

    userCache.update('email', (value) => resp, ifAbsent: () => resp);
    notifyListeners();
  }
}
