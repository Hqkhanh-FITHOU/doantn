import 'dart:convert';

class User {
  final int userId;
  final String fullname;
  final String username;
  final String password;
  final String email;
  final String phone;
  final List<String> roles;
  final int userPoint;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatar;

  User({
    required this.userId,
    required this.fullname,
    required this.username,
    required this.password,
    required this.email,
    required this.phone,
    required this.roles,
    required this.userPoint,
    required this.createdAt,
    required this.updatedAt,
    this.avatar,
  });

  // Hàm chuyển từ JSON sang đối tượng User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      fullname: utf8.decode(json['fullname'].runes.toList()),
      username: json['username'],
      password: json['password'],
      email: json['email'],
      phone: json['phone'],
      roles: List<String>.from(json['roles']),
      userPoint: json['userPoint'],
      createdAt: DateTime(
        json['createdAt'][0],
        json['createdAt'][1],
        json['createdAt'][2],
        json['createdAt'][3],
        json['createdAt'][4],
        json['createdAt'][5],
      ),
      updatedAt: DateTime(
        json['updatedAt'][0],
        json['updatedAt'][1],
        json['updatedAt'][2],
        json['updatedAt'][3],
        json['updatedAt'][4],
        json['updatedAt'][5],
      ),
      avatar: json['avatar'],
    );
  }

  // Hàm chuyển từ đối tượng User sang JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullname': fullname,
      'username': username,
      'password': password,
      'email': email,
      'phone': phone,
      'roles': roles,
      'userPoint': userPoint,
      'createdAt': [
        createdAt.year,
        createdAt.month,
        createdAt.day,
        createdAt.hour,
        createdAt.minute,
        createdAt.second,
      ],
      'updatedAt': [
        updatedAt.year,
        updatedAt.month,
        updatedAt.day,
        updatedAt.hour,
        updatedAt.minute,
        updatedAt.second,
      ],
      'avatar': avatar,
    };
  }
}