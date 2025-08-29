import 'dart:convert';

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
  final String? notes;
  final bool isFavorite;
  final Map<String, String> customFields;
  final int accountOrder;
  final String profileTag;

  const Account({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.serviceName,
    required this.username,
    required this.password,
    this.recoveryAccount,
    this.phoneNumbers,
    this.notes,
    this.isFavorite = false,
    this.customFields = const {},
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
    String? notes,
    bool? isFavorite,
    int? accountOrder,
    String? profileTag,
    Map<String, String>? customFields,
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
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      accountOrder: accountOrder ?? this.accountOrder,
      profileTag: profileTag ?? this.profileTag,
      customFields: customFields ?? this.customFields,
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
      'notes': notes,
      'isFavorite': isFavorite ? 1 : 0,
      'customFields': jsonEncode(customFields),
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
      notes: map['notes'],
      isFavorite: map['isFavorite'] == 1,
      accountOrder: map['accountOrder'] ?? 0,
      profileTag: map['profileTag'],
      customFields: map['customFields'] != null
          ? Map<String, String>.from(jsonDecode(map['customFields']))
          : {}, // Convert JSON String back to Map
    );
  }

  @override
  List<Object?> get props =>
      [
        id,
        userId,
        categoryId,
        serviceName,
        username,
        password,
        recoveryAccount,
        phoneNumbers,
        notes,
        isFavorite,
        accountOrder,
        profileTag
      ];
}