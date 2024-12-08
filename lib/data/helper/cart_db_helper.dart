import 'package:doantn/data/models/cart_item.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../api/api_service.dart';
import '../models/product.dart';

class CartDatabaseHelper {
  final logger = Logger();
  static final CartDatabaseHelper _instance = CartDatabaseHelper._();
  static Database? _database;
  final apiService = ApiService();

  CartDatabaseHelper._();

  factory CartDatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cart.db');
    logger.d('sqlite database path: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart(
            id INTEGER PRIMARY KEY,
            foodId INTEGER,
            quantity INTEGER
          )
        ''');
      },
    );
  }


  Future<void> addItemToCart(CartItem item) async {
    final db = await database;
    await db.insert(
      'cart',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Check if product exists in cart
  Future<bool> isProductInCart(int foodId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'cart',
      where: 'foodId = ?',
      whereArgs: [foodId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> updateCartItem(int foodId, int quantity) async {
    final db = await database;
    await db.update(
      'cart',
      {'quantity': quantity},
      where: 'foodId = ?',
      whereArgs: [foodId],
    );
  }


  Future<void> deleteCartItem(int productId) async {
    final db = await database;
    await db.delete(
      'cart',
      where: 'foodId = ?',
      whereArgs: [productId],
    );
  }

  Future<int> getTotalQuantity() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'cart',
    );
    int totalQuantity = 0;
    for (var item in result) {
      totalQuantity += item['quantity'] as int;
    }
    return totalQuantity;
  }


  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final List<Map<String, Object?>> result = await db.query('cart');
    List<CartItem>? list = [];
    for (var element in result) {
      Product food = await apiService.getProduct(element['foodId'] as int);
      int quantity = element['quantity'] as int;
      list.add(CartItem(food: food, quantity: quantity));
    }
    return list;
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  Future<void> close() async {
    final db = _database;
    db?.close();
  }
}