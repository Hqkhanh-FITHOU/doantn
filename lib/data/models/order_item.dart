class OrderItem {
  final int orderId;
  final int productId;
  final int quantity;
  final double priceAtOrderTime;

  OrderItem(this.orderId, this.productId, this.quantity, this.priceAtOrderTime);

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      json['orderId'] as int,
      json['productId'] as int,
      json['quantity'] as int,
      json['priceAtOrderTime'] as double,
    );
  }
}