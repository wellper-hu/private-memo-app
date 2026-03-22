import 'package:equatable/equatable.dart';

/// 还款提醒模型
class RepaymentItem extends Equatable {
  final String id;
  final String title;
  final String lenderName;
  final double amount;
  final DateTime dueDate;
  final double? paidAmount;
  final String? repaymentMethod;
  final String? notes;
  final bool isCompleted;
  final bool isReminderEnabled;
  final DateTime? lastReminderDate;
  final int? reminderOffsetDays;

  const RepaymentItem({
    required this.id,
    required this.title,
    required this.lenderName,
    required this.amount,
    required this.dueDate,
    this.paidAmount,
    this.repaymentMethod,
    this.notes,
    this.isCompleted = false,
    this.isReminderEnabled = true,
    this.lastReminderDate,
    this.reminderOffsetDays = 1,
  });

  RepaymentItem copyWith({
    String? id,
    String? title,
    String? lenderName,
    double? amount,
    DateTime? dueDate,
    double? paidAmount,
    String? repaymentMethod,
    String? notes,
    bool? isCompleted,
    bool? isReminderEnabled,
    DateTime? lastReminderDate,
    int? reminderOffsetDays,
  }) {
    return RepaymentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      lenderName: lenderName ?? this.lenderName,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paidAmount: paidAmount ?? this.paidAmount,
      repaymentMethod: repaymentMethod ?? this.repaymentMethod,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      lastReminderDate: lastReminderDate ?? this.lastReminderDate,
      reminderOffsetDays: reminderOffsetDays ?? this.reminderOffsetDays,
    );
  }

  /// 获取剩余金额
  double get remainingAmount {
    return (amount - (paidAmount ?? 0));
  }

  /// 检查是否已逾期
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(dueDate);
  }

  /// 获取剩余天数
  int getDaysRemaining() {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// 计算还款进度百分比
  double get progressPercentage {
    if (amount <= 0) return 0.0;
    return ((paidAmount ?? 0) / amount) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lenderName': lenderName,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'paidAmount': paidAmount,
      'repaymentMethod': repaymentMethod,
      'notes': notes,
      'isCompleted': isCompleted,
      'isReminderEnabled': isReminderEnabled,
      'lastReminderDate': lastReminderDate?.toIso8601String(),
      'reminderOffsetDays': reminderOffsetDays,
    };
  }

  factory RepaymentItem.fromJson(Map<String, dynamic> json) {
    return RepaymentItem(
      id: json['id'] as String,
      title: json['title'] as String,
      lenderName: json['lenderName'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidAmount: json['paidAmount'] != null
          ? (json['paidAmount'] as num).toDouble()
          : null,
      repaymentMethod: json['repaymentMethod'] as String?,
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
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
        lenderName,
        amount,
        dueDate,
        paidAmount,
        repaymentMethod,
        notes,
        isCompleted,
        isReminderEnabled,
        lastReminderDate,
        reminderOffsetDays,
      ];
}
