import 'dart:convert';
import 'package:doantn/data/enums/role.dart';
import 'package:doantn/data/models/coupon.dart';
import 'package:doantn/data/models/order_item2.dart';
import 'package:doantn/data/models/payment.dart';
import 'package:flutter/cupertino.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user.dart';

class ApiService with ChangeNotifier{
  static const String baseUrl = "http://192.168.0.101:8085/L1/";

  final storage = const FlutterSecureStorage();
  var logger = Logger();

  Future<List<Product>> fetchDataProducts() async {
    final url = Uri.parse("${baseUrl}product/all");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load all products');
    }
  }

  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    logger.d('login status code ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['accessToken'];
      await storage.write(key: 'jwt_token', value: token);
      await storage.write(key: 'is_login', value: 'false');
    } else {
      throw Exception('Failed to login - status code: ${response.statusCode}');
    }
  }

  Future<void> register(String fullname, String phone, String email,
      String username, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullname': fullname,
        'phone': phone,
        'email': email,
        'username': username,
        'password': password,
        'roles': [
          Role.CUSTOMER.name,
        ]
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      logger.i('user registered with userId ${data['userId']}');
    } else {
      throw Exception(
          'Failed to register - status code: ${response.statusCode}');
    }
  }

  Future<Product> getProduct(int id) async {
    final response = await http.get(
      Uri.parse('${baseUrl}product/$id'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception(
          'Failed to get product with id $id : ${response.statusCode}');
    }
  }

  Future<int> getUserId() async {
    String? token = await storage.read(key: 'jwt_token');
    Map<String, dynamic> jwtDecoded = JwtDecoder.decode(token!);
    dynamic uid = jwtDecoded['sub'];
    final response = await http.get(
        Uri.parse(
          '${baseUrl}user/username/$uid',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data as int;
    } else {
      throw Exception('Failed to get user id : ${response.statusCode}');
    }
  }

  Future<int> makeOrder(Order order) async {
    String? token = await storage.read(key: 'jwt_token');
    final paymentId = await makePayment(order);
    logger.d('make order with paymentId $paymentId');
    final response = await http.post(
      Uri.parse('${baseUrl}order/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(order.getWithPaymentIdJson(paymentId)),
    );
    logger.d('makeOrder status code ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      logger.d(data['orderId']);
      return data['orderId'];
    } else {
      throw Exception(
          'Fail to makeOrder - status code: ${response.statusCode}');
    }
  }

  Future<int> makePayment(Order order) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.post(
      Uri.parse('${baseUrl}payment/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(order.getPaymentJson()),
    );
    logger.d('makePayment status code ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['paymentId'];
    } else {
      throw Exception(
          'Failed to makePayment - status code: ${response.statusCode}');
    }
  }

  Future<void> addOrderItems(
      int orderId, int productId, int quantity, double priceAtOrderTime) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.post(
      Uri.parse('${baseUrl}orderItem/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'orderId': orderId,
        'productId': productId,
        'quantity': quantity,
        'priceAtOrderTime': priceAtOrderTime
      }),
    );
    logger.d('login status code ${response.statusCode}');
    if (response.statusCode == 200) {
      logger.d('add order item');
    } else {
      throw Exception(
          'Failed to add order item - status code: ${response.statusCode}');
    }
  }

  Future<List<Coupon>> fetchDataActiveCoupons() async {
    final response = await http.get(Uri.parse('${baseUrl}coupon'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Coupon.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load active coupon');
    }
  }

  Future<List<Order>> fetchComingOrder() async {
    String? token = await storage.read(key: 'jwt_token');
    int userId = await getUserId();
    final response = await http.get(
        Uri.parse('${baseUrl}order/coming/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });
    if(response.statusCode == 200){
      List<dynamic> data = json.decode(response.body);
      List<Order> orders = [];
      for(var json in data){
        int orderId = json['orderId'];
        int quantity = await getOrderQuantity(orderId);
        var order = Order.fromJson(json);
        order.totalQuantity = quantity;
        orders.add(order);
      }
      return orders;
    } else {
      throw Exception('Failed to fetchComingOrder');
    }
  }

  Future<List<Order>> fetchCompleteOrder() async {
    String? token = await storage.read(key: 'jwt_token');
    int userId = await getUserId();
    final response = await http.get(
        Uri.parse('${baseUrl}order/completed/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
    );
    if(response.statusCode == 200){
      List<dynamic> data = json.decode(response.body);
      List<Order> orders = [];
      for(var json in data){
        int orderId = json['orderId'];
        int quantity = await getOrderQuantity(orderId);
        var order = Order.fromJson(json);
        order.totalQuantity = quantity;
        orders.add(order);
      }
      return orders;
    } else {
      throw Exception('Failed to fetchCompleteOrder');
    }
  }

  Future<List<Order>> fetchCanceledOrder() async {
    String? token = await storage.read(key: 'jwt_token');
    int userId = await getUserId();
    final response = await http.get(
        Uri.parse('${baseUrl}order/canceled/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
    );
    if(response.statusCode == 200){
      List<dynamic> data = json.decode(response.body);
      List<Order> orders = [];
      for(var json in data){
        int orderId = json['orderId'];
        int quantity = await getOrderQuantity(orderId);
        var order = Order.fromJson(json);
        order.totalQuantity = quantity;
        orders.add(order);
      }
      return orders;
    } else {
      throw Exception('Failed to fetchCanceledOrder');
    }
  }

  Future<List<Order>> fetchWillingOrder() async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
        Uri.parse('${baseUrl}order/willing-delivery'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
    );
    if(response.statusCode == 200){
      List<dynamic> data = json.decode(response.body);
      List<Order> orders = [];
      for(var json in data){
        int orderId = json['orderId'];
        int quantity = await getOrderQuantity(orderId);
        var order = Order.fromJson(json);
        order.totalQuantity = quantity;
        orders.add(order);
      }
      return orders;
    } else {
      throw Exception('Failed to fetchWillingOrder');
    }
  }

  Future<List<Order>> fetchDeliveringOrder() async {
    String? token = await storage.read(key: 'jwt_token');
    int userId = await getUserId();
    final response = await http.get(
        Uri.parse('${baseUrl}order/delivering/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
    );
    if(response.statusCode == 200){
      List<dynamic> data = json.decode(response.body);
      List<Order> orders = [];
      for(var json in data){
        int orderId = json['orderId'];
        int quantity = await getOrderQuantity(orderId);
        var order = Order.fromJson(json);
        order.totalQuantity = quantity;
        orders.add(order);
      }
      return orders;
    } else {
      throw Exception('Failed to fetchDeliveringOrder');
    }
  }

  Future<int> getOrderQuantity(int orderId) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
        Uri.parse('${baseUrl}order/quantity/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
    );
    if(response.statusCode == 200){
      int data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to getOrderQuantity');
    }
  }

  Future<User> getUder() async {
    String? token = await storage.read(key: 'jwt_token');
    int id = await getUserId();
    final response = await http.get(
        Uri.parse('${baseUrl}user/id/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
    );
    if(response.statusCode == 200){
      dynamic data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to getUder');
    }
  }

  Future<List<OrderItem2>> fectOrderItemsWithOrderId(int id) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
        Uri.parse('${baseUrl}orderItem/order/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
    );
    if(response.statusCode == 200){
      List<dynamic> data = json.decode(response.body);
      logger.i('${baseUrl}orderItem/order/$id \n $data');
      return data.map((json) => OrderItem2.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetchDeliveringOrder');
    }
  }

  Future<Order> getOrderById(int id) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
        Uri.parse('${baseUrl}order/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
    );
    if(response.statusCode == 200){
      dynamic data = json.decode(response.body);
      logger.i('${baseUrl}order/$id \n $data');
      return Order.fromJson(data);
    } else {
      throw Exception('Failed to fetchDeliveringOrder');
    }
  }

  Future<User> getUserByOrderId(int id) async{
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
        Uri.parse('${baseUrl}order/user/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
    );
    if(response.statusCode == 200){
      dynamic data = json.decode(response.body);
      logger.i('${baseUrl}order/user/$id \n $data');
      return User.fromJson(data);
    } else {
      throw Exception('Failed to fetchDeliveringOrder');
    }
  }


  Future<bool> confirmToDelivery(int orderId) async {
    String? token = await storage.read(key: 'jwt_token');
    int id = await getUserId();
    final response = await http.get(
        Uri.parse('${baseUrl}order/$orderId/confirmDelivery/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });
    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      logger.i('${baseUrl}order/$orderId/confirmDelivery/$id \n $data');
      return data;
    } else {
      logger.e('${baseUrl}order/$orderId/confirmDelivery/$id');
      throw Exception('Failed to confirmToDelivery');
    }
  }

  Future<Payment> getPaymentByOrderId(int orderId) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
        Uri.parse('${baseUrl}order/$orderId/payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });
    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      logger.i('${baseUrl}order/$orderId/payment');
      return Payment.fromJson(data);
    } else {
      logger.e('${baseUrl}order/$orderId/payment');
      throw Exception('Failed to confirmToDelivery');
    }
  }

  Future<bool> confirmComplete(int orderId) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
        Uri.parse('${baseUrl}order/$orderId/confirmComplete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });
    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      logger.i('${baseUrl}order/$orderId/confirmComplete');
      return data;
    } else {
      logger.e('${baseUrl}order/$orderId/confirmComplete');
      throw Exception('Failed to confirmComplete');
    }
  }

  Future<bool> confirmCancel(int orderId, String cancelReason) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
        Uri.parse('${baseUrl}order/cancel/$orderId?cancelReason=${Uri.encodeComponent(cancelReason)}',),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
    );
    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      logger.i('${baseUrl}order/$orderId/cancelReason $data');
      return data;
    } else {
      logger.e('${baseUrl}order/cancel/$orderId?cancelReason=${Uri.encodeComponent(cancelReason)}');
      throw Exception('Failed to cancelOrder ${response.statusCode}' );
    }
  }
}
