import 'package:flutter/cupertino.dart';
import 'package:todo_app/models/template_model.dart';
import 'package:todo_app/repositories/template_repository.dart';

class TemplateProvider extends ChangeNotifier {
  final TemplateRepository templateRepository;
  Map<String, dynamic> templateCache = {};

  TemplateProvider({
    required this.templateRepository,
  }) : super() {
    getTemplates();
  }

// 템플릿 리스트
  Future getTemplates() async {
    final res = await templateRepository.getTemplates();

    templateCache.update('templates', (value) => res, ifAbsent: () => res);
    notifyListeners();
  }

  // 템플릿 추가
  Future addTemplate({required TemplateModel templateModel}) async {
    var res = await templateRepository.addTemplate(templateModel);

    if (res['statusCode'] == 201) {
      int templateId = res['data']['id'];
      String name = templateModel.name;
      Object categoryObj = {'id': templateId, 'name': name};
      templateCache['templates'].add(categoryObj);

      await templateCache.update('templates', (value) => templateCache['templates'],
          ifAbsent: () => []);
    }
    notifyListeners();
    return res;
  }

  // 템플릿 수정
  Future updateTemplate({required String templateId, required TemplateModel templateModel}) async {
    var res = await templateRepository.updateTemplate(templateId, templateModel);

    if (res['statusCode'] == 200) {
      var result = await templateCache['templates'].map((item) {
        if (item['id'] == int.parse(templateId)) {
          item['name'] = templateModel.name;
        }
        return item;
      }).toList();
      await templateCache.update('templates', (value) => result, ifAbsent: () => []);
      notifyListeners();
    }

    return res;
  }

  // 템플릿 삭제
  Future deleteTemplate({required String templateId}) async {
    var res = await templateRepository.deleteTemplate(templateId);

    if (res['statusCode'] == 200) {
      var result =
          templateCache['templates'].where((item) => item['id'] != int.parse(templateId)).toList();
      templateCache.update('templates', (value) => result, ifAbsent: () => []);
    }
    notifyListeners();
    return res;
  }
}
