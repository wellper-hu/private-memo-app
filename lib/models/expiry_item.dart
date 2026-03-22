import 'package:equatable/equatable.dart';

/// 有效期提醒模型
class ExpiryItem extends Equatable {
  final String id;
  final String title;
  final String category;
  final DateTime expiryDate;
  final String? location;
  final String? description;
  final String? imageUrl;
  final bool isReminderEnabled;
  final int? reminderOffsetDays;

  const ExpiryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.expiryDate,
    this.location,
    this.description,
    this.imageUrl,
    this.isReminderEnabled = true,
    this.reminderOffsetDays = 7, // 默认提前7天提醒
  });

  ExpiryItem copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? expiryDate,
    String? location,
    String? description,
    String? imageUrl,
    bool? isReminderEnabled,
    int? reminderOffsetDays,
  }) {
    return ExpiryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderOffsetDays: reminderOffsetDays ?? this.reminderOffsetDays,
    );
  }

  /// 检查是否已过期
  bool get isExpired {
    return DateTime.now().isAfter(expiryDate);
  }

  /// 检查是否即将过期（根据设置的提前天数）
  bool get isExpiringSoon {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    return daysLeft > 0 && daysLeft <= (reminderOffsetDays ?? 7);
  }

  /// 获取剩余天数
  int getDaysRemaining() {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  /// 获取提醒日期
  DateTime get reminderDate {
    final days = reminderOffsetDays ?? 7;
    return expiryDate.subtract(Duration(days: days));
  }

  /// 检查是否需要提醒
  bool shouldRemind() {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= (reminderOffsetDays ?? 7);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'expiryDate': expiryDate.toIso8601String(),
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'isReminderEnabled': isReminderEnabled,
      'reminderOffsetDays': reminderOffsetDays,
    };
  }

  factory ExpiryItem.fromJson(Map<String, dynamic> json) {
    return ExpiryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      location: json['location'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isReminderEnabled: json['isReminderEnabled'] as bool? ?? true,
      reminderOffsetDays: json['reminderOffsetDays'] as int?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        expiryDate,
        location,
        description,
        imageUrl,
        isReminderEnabled,
        reminderOffsetDays,
      ];
}
