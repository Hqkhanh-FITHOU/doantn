
class Address {
  String name;
  String phone;
  String address;
  String addressType; // "home", "company", "other"
  bool isChecked;

  Address({
    required this.name,
    required this.phone,
    required this.address,
    required this.addressType,
    required this.isChecked,
  });

  // Chuyển thành Map để lưu vào SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'addressType': addressType,
      'isChecked': isChecked,
    };
  }

  // Khởi tạo từ Map
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      addressType: map['addressType'],
      isChecked: map['isChecked'],
    );
  }

  @override
  String toString() {
    return '$name - $phone - $address';
  }
}