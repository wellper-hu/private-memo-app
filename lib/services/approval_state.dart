import 'package:equatable/equatable.dart';
import '../models/approval_item.dart';

abstract class ApprovalState extends Equatable {
  const ApprovalState();

  @override
  List<Object?> get props => [];
}

class ApprovalInitial extends ApprovalState {}

class ApprovalLoading extends ApprovalState {}

class ApprovalLoaded extends ApprovalState {
  final List<ApprovalItem> approvals;

  const ApprovalLoaded({required this.approvals});

  @override
  List<Object?> get props => [approvals];
}

class ApprovalCreated extends ApprovalState {
  final ApprovalItem approval;

  const ApprovalCreated({required this.approval});

  @override
  List<Object?> get props => [approval];
}

class ApprovalApproved extends ApprovalState {
  final String approvalId;

  const ApprovalApproved({required this.approvalId});

  @override
  List<Object?> get props => [approvalId];
}

class ApprovalRejected extends ApprovalState {
  final String approvalId;

  const ApprovalRejected({required this.approvalId});

  @override
  List<Object?> get props => [approvalId];
}

class ApprovalDeleted extends ApprovalState {
  final String approvalId;

  const ApprovalDeleted({required this.approvalId});

  @override
  List<Object?> get props => [approvalId];
}

class PendingCountLoaded extends ApprovalState {
  final int count;

  const PendingCountLoaded({required this.count});

  @override
  List<Object?> get props => [count];
}

class ApprovalError extends ApprovalState {
  final String message;

  const ApprovalError({required this.message});

  @override
  List<Object?> get props => [message];
}
