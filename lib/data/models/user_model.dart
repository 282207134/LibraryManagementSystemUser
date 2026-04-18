import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class User { // 用户模型
  final String id; // 用户ID
  final String username; // 用户名
  final String email; // 邮箱
  final String? phone; // 手机号
  final String? avatar; // 头像URL
  final String role; // 角色
  final String? studentId; // 学号
  final String? department; // 部门
  final String? realName; // 真实姓名
  final String? gender; // 性别
  final String? birthDate; // 生日
  final String? address; // 地址
  final int borrowLimit; // 借阅限额
  final int currentBorrowCount; // 当前借阅数
  final int? totalBorrowCount; // 总借阅数
  final int? creditScore; // 信用分
  final String status; // 状态
  final String createdAt; // 创建时间
  final String? updatedAt; // 更新时间
  final String? lastLoginAt; // 最后登录时间

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

  factory User.fromJson(Map<String, dynamic> json) => User( // 从JSON创建User对象
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

  Map<String, dynamic> toJson() => { // 转换为JSON
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

  User copyWith({ // 创建副本并修改指定字段
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
