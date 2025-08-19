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
  final bool isFavorite;
  final int accountOrder;
  final String profileTag; // ADD THIS

  const Account({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.serviceName,
    required this.username,
    required this.password,
    this.recoveryAccount,
    this.phoneNumbers,
    this.isFavorite = false,
    this.accountOrder = 0,
    required this.profileTag, // ADD THIS
  });

  Account copyWith({
    int? id,
    int? userId,
    int? categoryId,
    String? serviceName,
    String? username,
    String? password,
    String? recoveryAccount,
    String? phoneNumbers,
    bool? isFavorite,
    int? accountOrder,
    String? profileTag,
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
      isFavorite: isFavorite ?? this.isFavorite,
      accountOrder: accountOrder ?? this.accountOrder,
      profileTag: profileTag ?? this.profileTag, // ADD THIS
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
      'isFavorite': isFavorite ? 1 : 0,
      'accountOrder': accountOrder,
      'profileTag': profileTag, // ADD THIS
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
      isFavorite: map['isFavorite'] == 1,
      accountOrder: map['accountOrder'] ?? 0,
      profileTag: map['profileTag'], // ADD THIS
    );
  }

  @override
  List<Object?> get props => [
    id, userId, categoryId, serviceName, username, password,
    recoveryAccount, phoneNumbers, isFavorite, accountOrder, profileTag
  ];
}