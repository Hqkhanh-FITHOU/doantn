import 'dart:convert';
import 'package:logger/logger.dart';

class ProductImage {
  final int imageId;
  final String pathString;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final logger = Logger();
  ProductImage({
    required this.imageId,
    required this.pathString,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor để parse JSON thành ProductImage object
  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      imageId: json['imageId'],
      pathString: utf8.decode(json['pathString'].runes.toList()),
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
      'imageId': imageId,
      'pathString': pathString,
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
