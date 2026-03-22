import 'package:equatable/equatable.dart';

/// 纪念日模型
class AnniversaryItem extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final int repeatDays; // 重复间隔天数
  final String? notes;
  final bool isReminderEnabled;
  final DateTime? lastReminderDate;
  final int? reminderOffsetDays; // 提前几天提醒

  const AnniversaryItem({
    required this.id,
    required this.title,
    required this.date,
    this.repeatDays = 365,
    this.notes,
    this.isReminderEnabled = true,
    this.lastReminderDate,
    this.reminderOffsetDays = 1,
  });

  AnniversaryItem copyWith({
    String? id,
    String? title,
    DateTime? date,
    int? repeatDays,
    String? notes,
    bool? isReminderEnabled,
    DateTime? lastReminderDate,
    int? reminderOffsetDays,
  }) {
    return AnniversaryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      repeatDays: repeatDays ?? this.repeatDays,
      notes: notes ?? this.notes,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      lastReminderDate: lastReminderDate ?? this.lastReminderDate,
      reminderOffsetDays: reminderOffsetDays ?? this.reminderOffsetDays,
    );
  }

  /// 获取距离纪念日的天数（正数表示已过，负数表示未到）
  int getDaysDifference() {
    final now = DateTime.now();
    final anniversaryDate = DateTime(now.year, date.month, date.day);
    if (anniversaryDate.isAfter(now)) {
      return (anniversaryDate.difference(now).inDays).abs();
    }
    return (now.difference(anniversaryDate).inDays).abs();
  }

  /// 获取下次纪念日日期
  DateTime getNextAnniversary() {
    final now = DateTime.now();
    DateTime nextDate = DateTime(now.year, date.month, date.day);
    if (nextDate.isBefore(now)) {
      nextDate = DateTime(now.year + 1, date.month, date.day);
    }
    return nextDate;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'repeatDays': repeatDays,
      'notes': notes,
      'isReminderEnabled': isReminderEnabled,
      'lastReminderDate': lastReminderDate?.toIso8601String(),
      'reminderOffsetDays': reminderOffsetDays,
    };
  }

  factory AnniversaryItem.fromJson(Map<String, dynamic> json) {
    return AnniversaryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      repeatDays: json['repeatDays'] as int? ?? 365,
      notes: json['notes'] as String?,
      isReminderEnabled: json['isReminderEnabled'] as bool? ?? true,
      lastReminderDate: json['lastReminderDate'] != null
          ? DateTime.parse(json['lastReminderDate'] as String)
          : null,
      reminderOffsetDays: json['reminderOffsetDays'] as int?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        date,
        repeatDays,
        notes,
        isReminderEnabled,
        lastReminderDate,
        reminderOffsetDays,
      ];
}
