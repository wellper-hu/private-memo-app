import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/repayment_item.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class RepaymentScreen extends StatefulWidget {
  const RepaymentScreen({super.key});

  @override
  State<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends State<RepaymentScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<RepaymentItem> _repayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRepayments();
  }

  Future<void> _loadRepayments() async {
    setState(() => _isLoading = true);
    final list = await _dbHelper.getAllRepayments();
    setState(() {
      _repayments = list;
      _isLoading = false;
    });
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<RepaymentItem>(
      context: context,
      builder: (context) => const AddRepaymentDialog(),
    );

    if (result != null) {
      await _dbHelper.insertRepayment(result);
      _loadRepayments();
    }
  }

  Future<void> _showEditDialog(RepaymentItem item) async {
    final result = await showDialog<RepaymentItem>(
      context: context,
      builder: (context) => EditRepaymentDialog(item: item),
    );

    if (result != null) {
      await _dbHelper.updateRepayment(result);
      _loadRepayments();
    }
  }

  Future<void> _deleteItem(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个还款项吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.deleteRepayment(id);
      _loadRepayments();
    }
  }

  Future<void> _toggleComplete(String id) async {
    await _dbHelper.toggleCompleteRepayment(id);
    _loadRepayments();
  }

  Future<void> _updatePaidAmount(String id, double amount) async {
    await _dbHelper.updatePaidAmount(id, amount);
    _loadRepayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('还款提醒'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _repayments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '暂无还款',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '点击右上角添加',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _repayments.length,
                  itemBuilder: (context, index) {
                    final item = _repayments[index];
                    return _buildRepaymentCard(item);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('添加还款'),
      ),
    );
  }

  Widget _buildRepaymentCard(RepaymentItem item) {
    final isOverdue = item.isOverdue;
    final isCompleted = item.isCompleted;
    final progress = item.progressPercentage;

    Color? bgColor;
    if (isCompleted) {
      bgColor = Colors.green.shade50;
    } else if (isOverdue) {
      bgColor = Colors.red.shade50;
    } else if (progress > 0 && progress < 100) {
      bgColor = Colors.blue.shade50;
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _toggleComplete(item.id),
            backgroundColor: isCompleted ? Colors.grey : Colors.green,
            foregroundColor: Colors.white,
            icon: isCompleted ? Icons.check_circle : Icons.check_circle_outline,
            label: isCompleted ? '已完成' : '标记完成',
          ),
          SlidableAction(
            onPressed: (context) => _showEditDialog(item),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: '编辑',
          ),
          SlidableAction(
            onPressed: (context) => _deleteItem(item.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isCompleted
                        ? Colors.green
                        : isOverdue
                            ? Colors.red
                            : Colors.blue,
                    child: Icon(
                      isCompleted
                          ? Icons.check
                          : isOverdue
                              ? Icons.error
                              : Icons.account_balance_wallet,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          item.lenderName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '¥${item.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isOverdue ? Colors.red : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '到期: ${DateFormat('yyyy-MM-dd').format(item.dueDate)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const Spacer(),
                  if (isCompleted)
                    const Text(
                      '已完成',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else if (isOverdue)
                    const Text(
                      '已逾期',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      '剩余${item.getDaysRemaining()}天',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              if (!isCompleted && progress > 0) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                ),
                const SizedBox(height: 4),
                Text(
                  '已还: ¥${(item.paidAmount ?? 0).toStringAsFixed(2)} / ¥${item.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '备注: ${item.notes}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AddRepaymentDialog extends StatefulWidget {
  const AddRepaymentDialog({super.key});

  @override
  State<AddRepaymentDialog> createState() => _AddRepaymentDialogState();
}

class _AddRepaymentDialogState extends State<AddRepaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _lenderNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _repaymentMethodController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDueDate;
  bool _isReminderEnabled = true;
  int? _reminderOffsetDays;

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择到期日期')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金额必须大于0')),
      );
      return;
    }

    final item = RepaymentItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      lenderName: _lenderNameController.text,
      amount: amount,
      dueDate: _selectedDueDate!,
      repaymentMethod: _repaymentMethodController.text.isEmpty
          ? null
          : _repaymentMethodController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      isReminderEnabled: _isReminderEnabled,
      reminderOffsetDays: _reminderOffsetDays,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加还款'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '标题'),
                validator: (value) =>
                    value?.isEmpty ?? true ? '请输入标题' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lenderNameController,
                decoration: const InputDecoration(labelText: '债权人'),
                validator: (value) =>
                    value?.isEmpty ?? true ? '请输入债权人' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: '金额',
                  prefixText: '¥',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) return '请输入金额';
                  final num = double.tryParse(value!);
                  if (num == null || num <= 0) return '金额必须大于0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dueDateController,
                decoration: const InputDecoration(
                  labelText: '到期日期',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDueDate,
                validator: (value) =>
                    value?.isEmpty ?? true ? '请选择日期' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _repaymentMethodController,
                decoration: const InputDecoration(labelText: '还款方式'),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('启用提醒'),
                value: _isReminderEnabled,
                onChanged: (value) {
                  setState(() => _isReminderEnabled = value);
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(
                  text: _reminderOffsetDays?.toString() ?? '1',
                ),
                decoration: const InputDecoration(
                  labelText: '提前提醒天数',
                  hintText: '默认提前1天提醒',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _reminderOffsetDays = int.tryParse(value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: '备注'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class EditRepaymentDialog extends StatefulWidget {
  final RepaymentItem item;

  const EditRepaymentDialog({super.key, required this.item});

  @override
  State<EditRepaymentDialog> createState() => _EditRepaymentDialogState();
}

class _EditRepaymentDialogState extends State<EditRepaymentDialog> {
  late final _titleController;
  late final _lenderNameController;
  late final _amountController;
  late final _dueDateController;
  late final _repaymentMethodController;
  late final _notesController;
  late bool _isReminderEnabled;
  late int? _reminderOffsetDays;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _lenderNameController = TextEditingController(text: widget.item.lenderName);
    _amountController = TextEditingController(
      text: widget.item.amount.toStringAsFixed(2),
    );
    _dueDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.item.dueDate),
    );
    _repaymentMethodController = TextEditingController(
      text: widget.item.repaymentMethod ?? '',
    );
    _notesController = TextEditingController(text: widget.item.notes ?? '');
    _isReminderEnabled = widget.item.isReminderEnabled;
    _reminderOffsetDays = widget.item.reminderOffsetDays;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _lenderNameController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    _repaymentMethodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.item.dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金额必须大于0')),
      );
      return;
    }

    final updated = widget.item.copyWith(
      title: _titleController.text,
      lenderName: _lenderNameController.text,
      amount: amount,
      dueDate: DateFormat('yyyy-MM-dd').parse(_dueDateController.text),
      repaymentMethod:
          _repaymentMethodController.text.isEmpty ? null : _repaymentMethodController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      isReminderEnabled: _isReminderEnabled,
      reminderOffsetDays: _reminderOffsetDays,
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑还款'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '标题'),
                validator: (value) =>
                    value?.isEmpty ?? true ? '请输入标题' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lenderNameController,
                decoration: const InputDecoration(labelText: '债权人'),
                validator: (value) =>
                    value?.isEmpty ?? true ? '请输入债权人' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: '金额',
                  prefixText: '¥',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) return '请输入金额';
                  final num = double.tryParse(value!);
                  if (num == null || num <= 0) return '金额必须大于0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dueDateController,
                decoration: const InputDecoration(
                  labelText: '到期日期',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDueDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _repaymentMethodController,
                decoration: const InputDecoration(labelText: '还款方式'),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('启用提醒'),
                value: _isReminderEnabled,
                onChanged: (value) {
                  setState(() => _isReminderEnabled = value);
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(
                  text: _reminderOffsetDays?.toString() ?? '1',
                ),
                decoration: const InputDecoration(
                  labelText: '提前提醒天数',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _reminderOffsetDays = int.tryParse(value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: '备注'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('保存'),
        ),
      ],
    );
  }
}
