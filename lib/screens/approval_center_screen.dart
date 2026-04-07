import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/approval_service.dart';
import '../models/approval_item.dart';

class ApprovalCenterScreen extends StatefulWidget {
  const ApprovalCenterScreen({super.key});

  @override
  State<ApprovalCenterScreen> createState() => _ApprovalCenterScreenState();
}

class _ApprovalCenterScreenState extends State<ApprovalCenterScreen> {
  String _filter = 'all'; // all, pending, approved, rejected

  @override
  void initState() {
    super.initState();
    context.read<ApprovalBloc>().add(const LoadApprovals());
  }

  List<ApprovalItem> _getFilteredApprovals(List<ApprovalItem> approvals) {
    if (_filter == 'all') return approvals;
    return approvals.where((item) => item.status == _getFilterStatus()).toList();
  }

  ApprovalStatus _getFilterStatus() {
    switch (_filter) {
      case 'pending':
        return ApprovalStatus.pending;
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      default:
        return ApprovalStatus.pending;
    }
  }

  void _showApprovalDetail(ApprovalItem approval) {
    showDialog(
      context: context,
      builder: (context) => ApprovalDetailDialog(approval: approval),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('审批中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          BlocBuilder<ApprovalBloc, ApprovalState>(
            builder: (context, state) {
              if (state is PendingCountLoaded) {
                return Badge(
                  label: Text(state.count.toString()),
                  child: const Icon(Icons.notifications),
                );
              }
              return const Icon(Icons.notifications);
            },
          ),
        ],
      ),
      body: BlocBuilder<ApprovalBloc, ApprovalState>(
        builder: (context, state) {
          if (state is ApprovalLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApprovalError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ApprovalBloc>().add(const LoadApprovals());
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (state is ApprovalLoaded) {
            final approvals = _getFilteredApprovals(state.approvals);

            if (approvals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _filter == 'all' ? Icons.inbox : Icons.filter_none,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _filter == 'all'
                          ? '暂无审批事项'
                          : '该分类下暂无审批事项',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ApprovalBloc>().add(const LoadApprovals());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: approvals.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: approvals[index].status.color,
                        child: Text(
                          approvals[index].status.displayName[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        approvals[index].title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('申请人: ${approvals[index].applicant}'),
                          Text(
                            '创建时间: ${_formatDateTime(approvals[index].createdAt)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (approvals[index].notes != null)
                            Text(
                              '备注: ${approvals[index].notes}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (approvals[index].status == ApprovalStatus.pending)
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => _approveApproval(approvals[index]),
                            ),
                          IconButton(
                            icon: Icon(Icons.info_outline, color: Colors.blue),
                            onPressed: () => _showApprovalDetail(approvals[index]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteApproval(approvals[index]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateApprovalDialog(),
        icon: const Icon(Icons.add),
        label: const Text('新建审批'),
      ),
    );
  }

  void _approveApproval(ApprovalItem approval) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认审批'),
        content: Text('确认通过审批: ${approval.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ApprovalBloc>().add(
                    ApproveApproval(
                      approvalId: approval.id,
                      approver: '当前用户',
                    ),
                  );
            },
            child: const Text('通过'),
          ),
        ],
      ),
    );
  }

  void _deleteApproval(ApprovalItem approval) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除审批: ${approval.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ApprovalBloc>().add(
                    DeleteApproval(approvalId: approval.id),
                  );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showCreateApprovalDialog() {
    final titleController = TextEditingController();
    final approverController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建审批'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '审批标题',
                  hintText: '请输入审批标题',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: approverController,
                decoration: const InputDecoration(
                  labelText: '审批人',
                  hintText: '请输入审批人姓名',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '请输入备注信息（可选）',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || approverController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写必填项')),
                );
                return;
              }

              final approvalId = DateTime.now().millisecondsSinceEpoch.toString();
              context.read<ApprovalBloc>().add(
                    CreateApproval(
                      id: approvalId,
                      title: titleController.text,
                      applicant: '当前用户',
                      approver: approverController.text,
                      notes: notesController.text.isEmpty ? null : notesController.text,
                    ),
                  );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('审批创建成功')),
              );
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选审批'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('全部'),
              value: 'all',
              groupValue: _filter,
              onChanged: (value) {
                setState(() {
                  _filter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('待审批'),
              value: 'pending',
              groupValue: _filter,
              onChanged: (value) {
                setState(() {
                  _filter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('已通过'),
              value: 'approved',
              groupValue: _filter,
              onChanged: (value) {
                setState(() {
                  _filter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('已拒绝'),
              value: 'rejected',
              groupValue: _filter,
              onChanged: (value) {
                setState(() {
                  _filter = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';

    return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class ApprovalDetailDialog extends StatelessWidget {
  final ApprovalItem approval;

  const ApprovalDetailDialog({super.key, required this.approval});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(approval.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildDetailRow('申请人', approval.applicant),
            _buildDetailRow('审批人', approval.approver),
            _buildDetailRow('状态', approval.status.displayName),
            _buildDetailRow(
              '创建时间',
              '${approval.createdAt.month}月${approval.createdAt.day}日 ${approval.createdAt.hour.toString().padLeft(2, '0')}:${approval.createdAt.minute.toString().padLeft(2, '0')}',
            ),
            if (approval.approvedAt != null)
              _buildDetailRow(
                '审批时间',
                '${approval.approvedAt!.month}月${approval.approvedAt!.day}日 ${approval.approvedAt!.hour.toString().padLeft(2, '0')}:${approval.approvedAt!.minute.toString().padLeft(2, '0')}',
              ),
            if (approval.approvedBy != null)
              _buildDetailRow('审批人', approval.approvedBy!),
            if (approval.notes != null) ...[
              const SizedBox(height: 16),
              const Text(
                '备注',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(approval.notes!),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
        if (approval.status == ApprovalStatus.pending)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ApprovalBloc>().add(
                    ApproveApproval(
                      approvalId: approval.id,
                      approver: '当前用户',
                    ),
                  );
            },
            child: const Text('通过'),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
