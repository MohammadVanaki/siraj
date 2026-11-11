class RulingCategoryModel {
  final int id;
  final String title;
  final String? iconName;
  final int count;

  RulingCategoryModel({
    required this.id,
    required this.title,
    this.iconName,
    this.count = 0,
  });

  factory RulingCategoryModel.fromJson(Map<String, dynamic> json) {
    return RulingCategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      iconName: json['icon_name'] ?? json['icon'],
      count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon_name': iconName,
      'count': count,
    };
  }
}
