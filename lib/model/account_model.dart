class Account {
  final int? id;
  final int userId;
  final int categoryId;
  final String serviceName;
  final String username;
  final String password;
  final String? recoveryAccount;
  final String? phoneNumbers;

  Account({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.serviceName,
    required this.username,
    required this.password,
    this.recoveryAccount,
    this.phoneNumbers,
  });

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
    );
  }
}