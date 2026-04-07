import 'package:equatable/equatable.dart';
import '../models/approval_item.dart';

abstract class ApprovalEvent extends Equatable {
  const ApprovalEvent();

  @override
  List<Object?> get props => [];
}

class LoadApprovals extends ApprovalEvent {}

class CreateApproval extends ApprovalEvent {
  final String id;
  final String title;
  final String applicant;
  final String approver;
  final String? notes;

  const CreateApproval({
    required this.id,
    required this.title,
    required this.applicant,
    required this.approver,
    this.notes,
  });

  @override
  List<Object?> get props => [id, title, applicant, approver, notes];
}

class ApproveApproval extends ApprovalEvent {
  final String approvalId;
  final String approver;

  const ApproveApproval({
    required this.approvalId,
    required this.approver,
  });

  @override
  List<Object?> get props => [approvalId, approver];
}

class RejectApproval extends ApprovalEvent {
  final String approvalId;
  final String approver;

  const RejectApproval({
    required this.approvalId,
    required this.approver,
  });

  @override
  List<Object?> get props => [approvalId, approver];
}

class DeleteApproval extends ApprovalEvent {
  final String approvalId;

  const DeleteApproval({required this.approvalId});

  @override
  List<Object?> get props => [approvalId];
}

class GetPendingCount extends ApprovalEvent {}
