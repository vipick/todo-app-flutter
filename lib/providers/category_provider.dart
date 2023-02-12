import 'package:flutter/cupertino.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository categoryRepository;
  Map<String, dynamic> categoryCache = {};

  CategoryProvider({
    required this.categoryRepository,
  }) : super() {
    getCategories();
  }

// 카테고리 리스트
  Future getCategories() async {
    final res = await categoryRepository.getCategories();

    categoryCache.update('categories', (value) => res, ifAbsent: () => res);
    notifyListeners();
  }

  // 카테고리 추가
  Future addCategory({required CategoryModel categoryModel}) async {
    final res = await categoryRepository.addCategory(categoryModel);

    if (res['statusCode'] == 201) {
      int categoryId = res['data']['id'];
      String name = categoryModel.name;
      Object categoryObj = {'id': categoryId, 'name': name};
      categoryCache['categories'].add(categoryObj);

      await categoryCache.update('categories', (value) => categoryCache['categories'],
          ifAbsent: () => []);
    }
    notifyListeners();
    return res;
  }

  // 카테고리 수정
  Future updateCategory({required String categoryId, required CategoryModel categoryModel}) async {
    final res = await categoryRepository.updateCategory(
        categoryId: categoryId, categoryModel: categoryModel);

    if (res['statusCode'] == 200) {
      final result = await categoryCache['categories'].map((item) {
        if (item['id'] == int.parse(categoryId)) {
          item['name'] = categoryModel.name;
        }
        return item;
      }).toList();
      await categoryCache.update('categories', (value) => result, ifAbsent: () => []);
      notifyListeners();
    }

    return res;
  }

  // 카테고리 삭제
  Future deleteCategory({required String categoryId}) async {
    final res = await categoryRepository.deleteCategory(categoryId);

    if (res['statusCode'] == 200) {
      final result =
          categoryCache['categories'].where((item) => item['id'] != int.parse(categoryId)).toList();
      categoryCache.update('categories', (value) => result, ifAbsent: () => []);
    }
    notifyListeners();
    return res;
  }
}
