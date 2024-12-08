
class Coupon {
  int couponId;
  String code;
  String discountType; // Có thể dùng enum nếu cần
  double discountValue;
  DateTime expirationDate;
  double minPurchase;
  DateTime createdAt;
  DateTime updatedAt;
  bool enabled;
  bool expired;

  Coupon({
    required this.couponId,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.expirationDate,
    required this.minPurchase,
    required this.createdAt,
    required this.updatedAt,
    required this.enabled,
    required this.expired,
  });

  // Tạo từ JSON
  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      couponId: json['couponId'],
      code: json['code'],
      discountType: json['discountType'],
      discountValue: (json['discountValue'] as num).toDouble(),
      expirationDate: DateTime(
        json['expirationDate'][0],
        json['expirationDate'][1],
        json['expirationDate'][2],
        json['expirationDate'][3],
        json['expirationDate'][4],
      ),
      minPurchase: (json['minPurchase'] as num).toDouble(),
      createdAt: DateTime(
        json['createdAt'][0],
        json['createdAt'][1],
        json['createdAt'][2],
        json['createdAt'][3],
        json['createdAt'][4],
        json['createdAt'][5],
        json['createdAt'][6] ~/ 1000, // Chuyển từ nanosecond thành millisecond
      ),
      updatedAt: DateTime(
        json['updatedAt'][0],
        json['updatedAt'][1],
        json['updatedAt'][2],
        json['updatedAt'][3],
        json['updatedAt'][4],
        json['updatedAt'][5],
        json['updatedAt'][6] ~/ 1000, // Chuyển từ nanosecond thành millisecond
      ),
      enabled: json['enabled'],
      expired: json['expired'],
    );
  }

  // Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'couponId': couponId,
      'code': code,
      'discountType': discountType,
      'discountValue': discountValue,
      'expirationDate': [
        expirationDate.year,
        expirationDate.month,
        expirationDate.day,
        expirationDate.hour,
        expirationDate.minute,
      ],
      'minPurchase': minPurchase,
      'createdAt': [
        createdAt.year,
        createdAt.month,
        createdAt.day,
        createdAt.hour,
        createdAt.minute,
        createdAt.second,
        createdAt.microsecond * 1000, // Chuyển thành nanosecond
      ],
      'updatedAt': [
        updatedAt.year,
        updatedAt.month,
        updatedAt.day,
        updatedAt.hour,
        updatedAt.minute,
        updatedAt.second,
        updatedAt.microsecond * 1000, // Chuyển thành nanosecond
      ],
      'enabled': enabled,
      'expired': expired,
    };
  }
}
