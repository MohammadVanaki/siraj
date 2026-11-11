class MarjaModel {
  final int id;
  final String name;
  final String title;
  final String? image;

  MarjaModel({
    required this.id,
    required this.name,
    required this.title,
    this.image,
  });

  factory MarjaModel.fromJson(Map<String, dynamic> json) {
    return MarjaModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'image': image,
    };
  }
}
