class Category {
  final int? id;
  final int userId;
  final String name;

  Category({this.id, required this.userId, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
    );
  }
}