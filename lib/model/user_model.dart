class User {
  final int? id;
  final String username;
  final String password;
  final String profileTag; // ADD THIS

  User({
    this.id,
    required this.username,
    required this.password,
    required this.profileTag, // ADD THIS
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'profileTag': profileTag, // ADD THIS
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      profileTag: map['profileTag'], // ADD THIS
    );
  }
}