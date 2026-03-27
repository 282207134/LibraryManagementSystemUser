import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class User {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? avatar;
  final String role;
  final String? studentId;
  final String? department;
  final String? realName;
  final String? gender;
  final String? birthDate;
  final String? address;
  final int borrowLimit;
  final int currentBorrowCount;
  final int? totalBorrowCount;
  final int? creditScore;
  final String status;
  final String createdAt;
  final String? updatedAt;
  final String? lastLoginAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.avatar,
    required this.role,
    this.studentId,
    this.department,
    this.realName,
    this.gender,
    this.birthDate,
    this.address,
    required this.borrowLimit,
    required this.currentBorrowCount,
    this.totalBorrowCount,
    this.creditScore,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String? ?? '',
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
        avatar: json['avatar'] as String?,
        role: json['role'] as String? ?? '',
        studentId: json['student_id'] as String?,
        department: json['department'] as String?,
        realName: json['real_name'] as String?,
        gender: json['gender'] as String?,
        birthDate: json['birth_date'] as String?,
        address: json['address'] as String?,
        borrowLimit: json['borrow_limit'] as int? ?? 0,
        currentBorrowCount: json['current_borrow_count'] as int? ?? 0,
        totalBorrowCount: json['total_borrow_count'] as int?,
        creditScore: json['credit_score'] as int?,
        status: json['status'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String?,
        lastLoginAt: json['last_login_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'phone': phone,
        'avatar': avatar,
        'role': role,
        'student_id': studentId,
        'department': department,
        'real_name': realName,
        'gender': gender,
        'birth_date': birthDate,
        'address': address,
        'borrow_limit': borrowLimit,
        'current_borrow_count': currentBorrowCount,
        'total_borrow_count': totalBorrowCount,
        'credit_score': creditScore,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'last_login_at': lastLoginAt,
      };

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? avatar,
    String? role,
    String? studentId,
    String? department,
    String? realName,
    String? gender,
    String? birthDate,
    String? address,
    int? borrowLimit,
    int? currentBorrowCount,
    int? totalBorrowCount,
    int? creditScore,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      realName: realName ?? this.realName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      borrowLimit: borrowLimit ?? this.borrowLimit,
      currentBorrowCount: currentBorrowCount ?? this.currentBorrowCount,
      totalBorrowCount: totalBorrowCount ?? this.totalBorrowCount,
      creditScore: creditScore ?? this.creditScore,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
