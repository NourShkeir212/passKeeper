class User {
  final int? id;
  final String username;
  final String password;
  final String profileTag;
  final int? linkedRealUserId;

  User({
    this.id,
    required this.username,
    required this.password,
    this.linkedRealUserId,
    required this.profileTag,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'profileTag': profileTag,
      'linkedRealUserId': linkedRealUserId,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      linkedRealUserId: map['linkedRealUserId'],
      id: map['id'],
      username: map['username'],
      password: map['password'],
      profileTag: map['profileTag'],
    );
  }
}