import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final int userId;
  final String name;
  final int categoryOrder;

  const Category({
    this.id,
    required this.userId,
    required this.name,
    this.categoryOrder = 0,
  });

  // ADD THIS METHOD
  Category copyWith({
    int? id,
    int? userId,
    String? name,
    int? categoryOrder,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      categoryOrder: categoryOrder ?? this.categoryOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'categoryOrder': categoryOrder,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      categoryOrder: map['categoryOrder'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, categoryOrder];
}