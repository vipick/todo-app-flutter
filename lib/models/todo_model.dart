class TodoModel {
  String categoryId;
  String? status;
  String memo;
  String today;

  TodoModel(
      {required this.categoryId, required this.status, required this.memo, required this.today});

  Map<String, dynamic> toJson() {
    return {'categoryId': categoryId, 'status': status, 'memo': memo, 'today': today};
  }
}
