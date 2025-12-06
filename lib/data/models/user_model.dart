import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

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

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

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
