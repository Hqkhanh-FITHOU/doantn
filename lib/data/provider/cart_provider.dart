import 'package:doantn/data/helper/cart_db_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

import '../models/cart_item.dart';

class Cart extends ChangeNotifier {
  final CartDatabaseHelper dbHelper = CartDatabaseHelper();
  final logger = Logger();
  late List<CartItem> _cart = [];
  List<CartItem> get cart => _cart;

  Future<void> loadFormDb() async {
    _cart = await dbHelper.getCartItems();
    notifyListeners();
  }

  Future<List<CartItem>> getData() async {
    return _cart;
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    // Cập nhật số lượng trong cơ sở dữ liệu
    if(newQuantity > 0){
      dbHelper.updateCartItem(productId, newQuantity);
    } else {
      dbHelper.deleteCartItem(productId);
    }
    // Cập nhật danh sách sản phẩm trong Provider
    _cart = _cart.map((item) {
      if (item.food.productId == productId) {
        return item.copyWith(null, newQuantity);
      }
      return item;
    }).toList();
    notifyListeners();
  }

  Future<void> deleteCartItem(int productId) async {
    dbHelper.deleteCartItem(productId);
  }


  double getTotalPrice(){
    double total = 0.0;
    for(CartItem cartItem in _cart){
      double itemTotal = cartItem.food.price;
      total += itemTotal*cartItem.quantity;
    }
    return total;
  }


  int _totalQuantity = 0;

  int get totalQuantity => _totalQuantity;

  Future<void> calculateTotalQuantity() async {
    _totalQuantity = await _getTotalItemCount();
    notifyListeners();
  }

  Future<int> _getTotalItemCount() {
    return dbHelper.getTotalQuantity();
  }

  void clearCart () {
    dbHelper.clearCart();
    notifyListeners();
  }
}
