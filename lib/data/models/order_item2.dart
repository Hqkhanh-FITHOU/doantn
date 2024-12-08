import 'package:doantn/data/models/product.dart';

class OrderItem2 {
  final int orderItemId;
  final Product product;
  final int quantity;
  final double priceAtOrderTime;

  OrderItem2({
    required this.orderItemId,
    required this.product,
    required this.quantity,
    required this.priceAtOrderTime,
  });

  // Chuyển từ JSON sang đối tượng OrderItem
  factory OrderItem2.fromJson(Map<String, dynamic> json) {
    return OrderItem2(
      orderItemId: json['orderItemId'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      priceAtOrderTime: json['priceAtOrderTime'].toDouble(),
    );
  }

  // Chuyển từ đối tượng OrderItem sang JSON
  Map<String, dynamic> toJson() {
    return {
      'orderItemId': orderItemId,
      'product': product.toJson(),
      'quantity': quantity,
      'priceAtOrderTime': priceAtOrderTime,
    };
  }
}