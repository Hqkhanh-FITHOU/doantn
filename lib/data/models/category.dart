import 'dart:convert';

class Category {
  final int categoryId;
  final String name;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category(
      {required this.categoryId,
      required this.name,
      required this.description,
      required this.createdAt,
      required this.updatedAt});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'],
      name: utf8.decode(json['name'].runes.toList()),
      description: utf8.decode(json['description'].runes.toList()),
      createdAt: json['createdAt'] != null
          ? DateTime(
              json['createdAt'][0],
              json['createdAt'][1],
              json['createdAt'][2],
              json['createdAt'][3],
              json['createdAt'][4],
              json['createdAt'][5],
              json['createdAt'][6] ~/ 1000,
            )
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime(
              json['updatedAt'][0],
              json['updatedAt'][1],
              json['updatedAt'][2],
              json['updatedAt'][3],
              json['updatedAt'][4],
              json['updatedAt'][5],
              json['updatedAt'][6] ~/ 1000,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'createdAt': [
        createdAt?.year,
        createdAt?.month,
        createdAt?.day,
        createdAt?.hour,
        createdAt?.minute,
        createdAt?.second,
      ],
      'updatedAt': [
        updatedAt?.year,
        updatedAt?.month,
        updatedAt?.day,
        updatedAt?.hour,
        updatedAt?.minute,
        updatedAt?.second,
      ],
    };
  }
}
