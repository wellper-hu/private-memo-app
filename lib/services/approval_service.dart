import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/approval_item.dart';
import '../database/database_helper.dart';

part 'approval_event.dart';
part 'approval_state.dart';

class ApprovalBloc extends Bloc<ApprovalEvent, ApprovalState> {
  final DatabaseHelper _databaseHelper;

  ApprovalBloc(this._databaseHelper) : super(ApprovalInitial()) {
    on<LoadApprovals>(_onLoadApprovals);
    on<CreateApproval>(_onCreateApproval);
    on<ApproveApproval>(_onApproveApproval);
    on<RejectApproval>(_onRejectApproval);
    on<DeleteApproval>(_onDeleteApproval);
    on<GetPendingCount>(_onGetPendingCount);
  }

  Future<void> _onLoadApprovals(LoadApprovals event, Emitter<ApprovalState> emit) async {
    emit(ApprovalLoading());
    try {
      final approvals = await _databaseHelper.getAllApprovals();
      emit(ApprovalLoaded(approvals: approvals));
    } catch (e) {
      emit(ApprovalError(message: e.toString()));
    }
  }

  Future<void> _onCreateApproval(CreateApproval event, Emitter<ApprovalState> emit) async {
    try {
      final now = DateTime.now();
      final approval = ApprovalItem(
        id: event.id,
        title: event.title,
        applicant: event.applicant,
        approver: event.approver,
        status: ApprovalStatus.pending,
        createdAt: now,
        notes: event.notes,
      );

      await _databaseHelper.insertApproval(approval);
      emit(ApprovalCreated(approval));
    } catch (e) {
      emit(ApprovalError(message: e.toString()));
    }
  }

  Future<void> _onApproveApproval(ApproveApproval event, Emitter<ApprovalState> emit) async {
    try {
      await _databaseHelper.updateApprovalStatus(
        event.approvalId,
        ApprovalStatus.approved,
        approver: event.approver,
      );

      // 触发重新加载
      add(const LoadApprovals());
      emit(ApprovalApproved(approvalId: event.approvalId));
    } catch (e) {
      emit(ApprovalError(message: e.toString()));
    }
  }

  Future<void> _onRejectApproval(RejectApproval event, Emitter<ApprovalState> emit) async {
    try {
      await _databaseHelper.updateApprovalStatus(
        event.approvalId,
        ApprovalStatus.rejected,
        approver: event.approver,
      );

      // 触发重新加载
      add(const LoadApprovals());
      emit(ApprovalRejected(approvalId: event.approvalId));
    } catch (e) {
      emit(ApprovalError(message: e.toString()));
    }
  }

  Future<void> _onDeleteApproval(DeleteApproval event, Emitter<ApprovalState> emit) async {
    try {
      await _databaseHelper.deleteApproval(event.approvalId);
      // 触发重新加载
      add(const LoadApprovals());
      emit(ApprovalDeleted(approvalId: event.approvalId));
    } catch (e) {
      emit(ApprovalError(message: e.toString()));
    }
  }

  Future<void> _onGetPendingCount(GetPendingCount event, Emitter<ApprovalState> emit) async {
    try {
      final count = await _databaseHelper.getPendingApprovalCount();
      emit(PendingCountLoaded(count: count));
    } catch (e) {
      emit(ApprovalError(message: e.toString()));
    }
  }
}
