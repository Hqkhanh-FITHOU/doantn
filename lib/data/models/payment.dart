class Payment {
  int paymentId;
  String paymentMethod;
  String paymentStatus;
  DateTime paymentDate;

  Payment({
    required this.paymentId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentDate,
  });

  // Phương thức từ JSON sang đối tượng Dart
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      paymentDate: DateTime(
        json['paymentDate'][0],
        json['paymentDate'][1],
        json['paymentDate'][2],
        json['paymentDate'][3],
        json['paymentDate'][4],
        json['paymentDate'][5],
        json['paymentDate'][6] ~/ 1000000, // Chuyển từ nano giây sang milli giây
      ),
    );
  }

  // Phương thức từ đối tượng Dart sang JSON
  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentDate': [
        paymentDate.year,
        paymentDate.month,
        paymentDate.day,
        paymentDate.hour,
        paymentDate.minute,
        paymentDate.second,
        paymentDate.microsecond * 1000, // Chuyển từ milli giây sang nano giây
      ],
    };
  }
}