import 'package:flutter/cupertino.dart';
import 'package:todo_app/repositories/template_category_repository.dart';

class TemplateCategoryProvider extends ChangeNotifier {
  final TemplateCategoryRepository templateCategoryRepository;
  Map<String, dynamic> templateCategoryCache = {};

  TemplateCategoryProvider({
    required this.templateCategoryRepository,
  }) : super() {
    getTemplateCategories();
  }

//  모든 템플릿의 카테고리 리스트
  Future getTemplateCategories() async {
    final res = await templateCategoryRepository.getTemplateCategories();

    templateCategoryCache.update('templateCategories', (value) => res, ifAbsent: () => res);
    notifyListeners();
  }

  // 템플릿에 카테고리 추가
  Future addCategoryToTemplate(String templateId, String categoryId) async {
    var res = await templateCategoryRepository.addCategoryToTemplate(templateId, categoryId);

    if (res['statusCode'] == 201) {
      var templateCategoryObj = {
        'id': res['data']['templateCategory']['id'],
        'templateId': res['data']['templateCategory']['templateId'],
        'categoryId': res['data']['templateCategory']['categoryId'],
        'categoryName': res['data']['templateCategory']['categoryName'],
        'createdAt': res['data']['templateCategory']['createdAt']
      };

      templateCategoryCache['templateCategories'].add(templateCategoryObj);

      await templateCategoryCache.update(
          'templateCategories', (value) => templateCategoryCache['templateCategories'],
          ifAbsent: () => []);
    }
    notifyListeners();
    return res;
  }

  // 템플릿에서 카테고리 제거
  Future removeCategoryFromTemplate(
      {required String templateId, required List categoryList}) async {
    var res = await templateCategoryRepository.removeCategoryFromTemplate(templateId, categoryList);

    if (res['statusCode'] == 200) {
      var result = templateCategoryCache['templateCategories']
          .where((item) => !((item['templateId'] == int.parse(templateId)) &&
              (categoryList.contains(item['id'].toString()))))
          .toList();

      templateCategoryCache.update('templateCategories', (value) => result, ifAbsent: () => []);
    }
    notifyListeners();
    return res;
  }

  // 템플릿을 ToDO 에 복사
  Future copyTemplate({required String id, required String date}) async {
    var res = await templateCategoryRepository.copyTemplate(id, date);

    return res;
  }
}
