import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// 审批状态枚举
enum ApprovalStatus {
  pending, // 待审批
  approved, // 已通过
  rejected; // 已拒绝

  String get displayName {
    switch (this) {
      case ApprovalStatus.pending:
        return '待审批';
      case ApprovalStatus.approved:
        return '已通过';
      case ApprovalStatus.rejected:
        return '已拒绝';
    }
  }

  Color get color {
    switch (this) {
      case ApprovalStatus.pending:
        return Colors.orange;
      case ApprovalStatus.approved:
        return Colors.green;
      case ApprovalStatus.rejected:
        return Colors.red;
    }
  }
}

/// 审批项模型
class ApprovalItem extends Equatable {
  final String id;
  final String title;
  final String applicant; // 申请人
  final String approver; // 审批人
  final ApprovalStatus status;
  final DateTime createdAt;
  final String? notes;
  final DateTime? approvedAt; // 审批时间
  final String? approvedBy; // 审批人

  const ApprovalItem({
    required this.id,
    required this.title,
    required this.applicant,
    required this.approver,
    required this.status,
    required this.createdAt,
    this.notes,
    this.approvedAt,
    this.approvedBy,
  });

  ApprovalItem copyWith({
    String? id,
    String? title,
    String? applicant,
    String? approver,
    ApprovalStatus? status,
    DateTime? createdAt,
    String? notes,
    DateTime? approvedAt,
    String? approvedBy,
  }) {
    return ApprovalItem(
      id: id ?? this.id,
      title: title ?? this.title,
      applicant: applicant ?? this.applicant,
      approver: approver ?? this.approver,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'applicant': applicant,
      'approver': approver,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }

  factory ApprovalItem.fromJson(Map<String, dynamic> json) {
    return ApprovalItem(
      id: json['id'] as String,
      title: json['title'] as String,
      applicant: json['applicant'] as String,
      approver: json['approver'] as String,
      status: ApprovalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApprovalStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      approvedBy: json['approvedBy'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        applicant,
        approver,
        status,
        createdAt,
        notes,
        approvedAt,
        approvedBy,
      ];
}
