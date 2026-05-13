import 'dart:convert';

class UserThikr {
  final String id;
  final String text;
  final String? description;
  final DateTime createdAt;

  UserThikr({
    required this.id,
    required this.text,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserThikr.fromMap(Map<String, dynamic> map) {
    return UserThikr(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      description: map['description'],
      createdAt: DateTime.parse(
          map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserThikr.fromJson(String source) =>
      UserThikr.fromMap(json.decode(source));

  UserThikr copyWith({
    String? id,
    String? text,
    String? description,
    DateTime? createdAt,
  }) {
    return UserThikr(
      id: id ?? this.id,
      text: text ?? this.text,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
