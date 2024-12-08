import 'package:doantn/data/models/product.dart';

class CartItem {

  Product food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});

  double get totalPrice {
    return food.price * quantity;
  }

  Map<String, Object?> toMap(){
    return {
      'foodId' : food.productId,
      'quantity' : quantity
    };
  }

  CartItem copyWith(
    Product? food,
    int? quantity,
  ) {
    return CartItem(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
    );
  }
}