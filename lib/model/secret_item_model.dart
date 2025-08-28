import 'package:equatable/equatable.dart';

class SecretItem extends Equatable {
  final int? id;
  final int userId;
  final String title;
  final String content; // Encrypted

  const SecretItem({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
  });

  /// Converts a SecretItem object into a Map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
    };
  }

  /// Creates a SecretItem object from a Map from the database.
  factory SecretItem.fromMap(Map<String, dynamic> map) {
    return SecretItem(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      content: map['content'],
    );
  }

  SecretItem copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
  }) {
    return SecretItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, content];
}