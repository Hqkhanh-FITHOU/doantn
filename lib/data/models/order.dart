import 'dart:convert';

import 'package:doantn/data/enums/order_status.dart';
import 'package:doantn/data/enums/payment_status.dart';
import 'package:doantn/data/enums/payment_type.dart';

class Order {
  final int orderId;
  final int userId;
  final int? userDeliveryId;
  final double totalAmount;
  final double totalDiscount;
  final double totalPayment;
  final String? note;
  final OrderStatus orderStatus;
  final String receiverAddress;
  final PaymentType? paymentMethod;
  final PaymentStatus? paymentStatus;
  final DateTime? createDate;
  final String? cancelReason;
  int? totalQuantity;

  Order(
      this.orderId,
      this.userId,
      this.userDeliveryId,
      this.totalAmount,
      this.totalDiscount,
      this.totalPayment,
      this.note,
      this.orderStatus,
      this.receiverAddress,
      this.paymentMethod,
      this.paymentStatus,
      this.createDate,
      this.cancelReason);

  // Factory method to create an Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      json['orderId'] as int,
      json['userId'] as int,
      json['deliveryId'],
      (json['totalAmount'] as num).toDouble(),
      (json['totalDiscount'] as num).toDouble(),
      (json['totalPayment'] as num).toDouble(),
      json['note'],
      _orderStatusFromJson(json['status'] as String),
      utf8.decode(json['address'].runes.toList()),
      null,
      null,
      json['createdDate'] != null
          ? DateTime(
        json['createdDate'][0],
        json['createdDate'][1],
        json['createdDate'][2],
        json['createdDate'][3],
        json['createdDate'][4],
        json['createdDate'][5],
        json['createdDate'][6] ~/ 1000,
      )
          : null,
      json['cancelReason']
    );
  }

  // Convert OrderStatus from string
  static OrderStatus _orderStatusFromJson(String status) {
    switch (status) {
      case 'PENDING':
        return OrderStatus.PENDING;
      case 'COMPLETED':
        return OrderStatus.COMPLETED;
      case 'CANCELED':
        return OrderStatus.CANCELED;
      case 'ON_DELIVERY':
        return OrderStatus.ON_DELIVERY;
      case 'ON_PROGRESS':
        return OrderStatus.ON_PROGRESS;
      case 'WILLING_DELIVERY':
        return OrderStatus.WILLING_DELIVERY;
      default:
        throw Exception('Unknown order status: $status');
    }
  }

  // Convert PaymentType from string
  static PaymentType _paymentTypeFromJson(String type) {
    switch (type) {
      case 'CASH_ON_DELIVERY':
        return PaymentType.CASH_ON_DELIVERY;
      case 'VNPAY':
        return PaymentType.VNPAY;
      case 'CREDIT_CARD':
        return PaymentType.CREDIT_CARD;
      default:
        throw Exception('Unknown payment type: $type');
    }
  }

  // Convert PaymentStatus from string
  static PaymentStatus _paymentStatusFromJson(String status) {
    switch (status) {
      case 'PENDING':
        return PaymentStatus.PENDING;
      case 'COMPLETED':
        return PaymentStatus.COMPLETED;
      case 'FAILED':
        return PaymentStatus.FAILED;
      default:
        throw Exception('Unknown payment status: $status');
    }
  }



  Map<String, dynamic> getWithPaymentIdJson(int paymentId) {
    return {
      'orderId': orderId,
      'userId': userId,
      'deliveryId': userId,
      'totalAmount': totalAmount,
      'totalDiscount': totalDiscount,
      'totalPayment': totalPayment,
      'status': orderStatus.toString().split('.').last,
      'address': receiverAddress,
      'paymentId': paymentId,
      'note': note,
      'cancelReason': cancelReason,
      'createdDate': null,
      'updatedDate': null
    };
  }

  Map<String, dynamic> getPaymentJson() {
    return {
      'paymentMethod': paymentMethod.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
    };
  }
}