import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final int? id;
  final int userId;
  final int categoryId;
  final String serviceName;
  final String username;
  final String password;
  final String? recoveryAccount;
  final String? phoneNumbers;
  final int accountOrder;

  const Account({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.serviceName,
    required this.username,
    required this.password,
    this.recoveryAccount,
    this.phoneNumbers,
    this.accountOrder = 0,
  });

  // ADD THIS METHOD
  Account copyWith({
    int? id,
    int? userId,
    int? categoryId,
    String? serviceName,
    String? username,
    String? password,
    String? recoveryAccount,
    String? phoneNumbers,
    int? accountOrder,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      serviceName: serviceName ?? this.serviceName,
      username: username ?? this.username,
      password: password ?? this.password,
      recoveryAccount: recoveryAccount ?? this.recoveryAccount,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      accountOrder: accountOrder ?? this.accountOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'serviceName': serviceName,
      'username': username,
      'password': password,
      'recoveryAccount': recoveryAccount,
      'phoneNumbers': phoneNumbers,
      'accountOrder': accountOrder,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      userId: map['userId'],
      categoryId: map['categoryId'],
      serviceName: map['serviceName'],
      username: map['username'],
      password: map['password'],
      recoveryAccount: map['recoveryAccount'],
      phoneNumbers: map['phoneNumbers'],
      accountOrder: map['accountOrder'] ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [
        id, userId, categoryId, serviceName, username, password,
        recoveryAccount, phoneNumbers, accountOrder
      ];
}