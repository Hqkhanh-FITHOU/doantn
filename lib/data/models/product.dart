import 'dart:convert';

import 'package:doantn/data/models/category.dart';
import 'package:doantn/data/models/product_image.dart';

class Product {
  final int productId;
  final String name;
  final String description;
  final bool isServing;
  final bool isHidden;
  final double price;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ProductImage> images;
  final Category category;

  Product(
      {required this.productId,
      required this.name,
      required this.description,
      required this.isServing,
      required this.isHidden,
      required this.createdAt,
      required this.updatedAt,
      required this.price,
      required this.images,
      required this.category});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        productId: json['productId'],
        name: utf8.decode(json['name'].runes.toList()),
        description: utf8.decode(json['description'].runes.toList()) ?? '',
        price: (json['price'] as num).toDouble(),
        createdAt: json['createdAt'] != null
            ? DateTime(
                json['createdAt'][0],
                json['createdAt'][1],
                json['createdAt'][2],
                json['createdAt'][3],
                json['createdAt'][4],
                json['createdAt'][5],
                json['createdAt'][6] ~/
                    1000, // Convert nanoseconds to microseconds
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
        images: (json['productImages'] as List<dynamic>)
            .map((imageJson) => ProductImage.fromJson(imageJson))
            .toList(),
        isHidden: json['hidden'],
        isServing: json['serving'],
        category: Category.fromJson(json['category']));
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'price': price,
      'category': category.toJson(),
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
      'productImages': images.map((image) => image.toJson()).toList(),
      'hidden': isHidden,
      'serving': isServing,
    };
  }
}
