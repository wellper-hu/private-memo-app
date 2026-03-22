import 'package:equatable/equatable.dart';

/// 密码本项模型
class PasswordItem extends Equatable {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? url;
  final String? category;
  final String? notes;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PasswordItem({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url,
    this.category,
    this.notes,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  PasswordItem copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? url,
    String? category,
    String? notes,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PasswordItem(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'category': category,
      'notes': notes,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PasswordItem.fromJson(Map<String, dynamic> json) {
    return PasswordItem(
      id: json['id'] as String,
      title: json['title'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      url: json['url'] as String?,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        username,
        password,
        url,
        category,
        notes,
        isFavorite,
        createdAt,
        updatedAt,
      ];
}
