import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/anniversary_item.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:lunar/lunar.dart';

class AnniversaryScreen extends StatefulWidget {
  const AnniversaryScreen({super.key});

  @override
  State<AnniversaryScreen> createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends State<AnniversaryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<AnniversaryItem> _anniversaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnniversaries();
  }

  Future<void> _loadAnniversaries() async {
    setState(() => _isLoading = true);
    final list = await _dbHelper.getAllAnniversaries();
    setState(() {
      _anniversaries = list;
      _isLoading = false;
    });
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<AnniversaryItem>(
      context: context,
      builder: (context) => const AddAnniversaryDialog(),
    );

    if (result != null) {
      await _dbHelper.insertAnniversary(result);
      _loadAnniversaries();
    }
  }

  Future<void> _showEditDialog(AnniversaryItem item) async {
    final result = await showDialog<AnniversaryItem>(
      context: context,
      builder: (context) => EditAnniversaryDialog(item: item),
    );

    if (result != null) {
      await _dbHelper.updateAnniversary(result);
      _loadAnniversaries();
    }
  }

  Future<void> _deleteItem(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个纪念日吗？'),
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
      await _dbHelper.deleteAnniversary(id);
      _loadAnniversaries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('纪念日'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _anniversaries.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cake, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '暂无纪念日',
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
                  itemCount: _anniversaries.length,
                  itemBuilder: (context, index) {
                    final item = _anniversaries[index];
                    return _buildAnniversaryCard(item);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('添加纪念日'),
      ),
    );
  }

  Widget _buildAnniversaryCard(AnniversaryItem item) {
    final daysDiff = item.getDaysDifference();
    final lunarDate = Lunar.fromDate(item.date);
    final lunarMonth = lunarDate.getMonth();
    final lunarDay = lunarDate.getDay();

    Color? bgColor;
    if (daysDiff == 0) {
      bgColor = Colors.red.shade50;
    } else if (daysDiff <= 7) {
      bgColor = Colors.orange.shade50;
    } else if (daysDiff <= 30) {
      bgColor = Colors.blue.shade50;
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _deleteItem(item.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
          SlidableAction(
            onPressed: (context) => _showEditDialog(item),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: '编辑',
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        color: bgColor,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: daysDiff == 0 ? Colors.red : Colors.purple,
            child: Icon(
              daysDiff == 0 ? Icons.cake : Icons.event,
              color: Colors.white,
            ),
          ),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('农历: ${lunarMonth}月${lunarDay}日'),
              Text('距离: ${daysDiff}天后'),
              if (daysDiff <= 30)
                Text(
                  daysDiff == 0 ? '🎉 今天就是！' : '即将到来！',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddAnniversaryDialog extends StatefulWidget {
  const AddAnniversaryDialog({super.key});

  @override
  State<AddAnniversaryDialog> createState() => _AddAnniversaryDialogState();
}

class _AddAnniversaryDialogState extends State<AddAnniversaryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _repeatDaysController = TextEditingController(text: '365');
  final _notesController = TextEditingController();
  bool _reminderEnabled = true;
  int? _reminderOffsetDays;

  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择日期')),
      );
      return;
    }

    final item = AnniversaryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      date: _selectedDate!,
      repeatDays: int.tryParse(_repeatDaysController.text) ?? 365,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      isReminderEnabled: _reminderEnabled,
      reminderOffsetDays: _reminderOffsetDays,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加纪念日'),
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
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: '日期',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) =>
                    value?.isEmpty ?? true ? '请选择日期' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _repeatDaysController,
                decoration: const InputDecoration(labelText: '重复间隔（天）'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('启用提醒'),
                value: _reminderEnabled,
                onChanged: (value) {
                  setState(() => _reminderEnabled = value);
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

class EditAnniversaryDialog extends StatefulWidget {
  final AnniversaryItem item;

  const EditAnniversaryDialog({super.key, required this.item});

  @override
  State<EditAnniversaryDialog> createState() => _EditAnniversaryDialogState();
}

class _EditAnniversaryDialogState extends State<EditAnniversaryDialog> {
  late final _titleController;
  late final _dateController;
  late final _repeatDaysController;
  late final _notesController;
  late bool _reminderEnabled;
  late int? _reminderOffsetDays;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.item.date),
    );
    _repeatDaysController =
        TextEditingController(text: widget.item.repeatDays.toString());
    _notesController = TextEditingController(text: widget.item.notes ?? '');
    _reminderEnabled = widget.item.isReminderEnabled;
    _reminderOffsetDays = widget.item.reminderOffsetDays;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _repeatDaysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.item.date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
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

    final updated = widget.item.copyWith(
      title: _titleController.text,
      date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
      repeatDays: int.tryParse(_repeatDaysController.text) ?? 365,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      isReminderEnabled: _reminderEnabled,
      reminderOffsetDays: _reminderOffsetDays,
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑纪念日'),
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
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: '日期',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _repeatDaysController,
                decoration: const InputDecoration(labelText: '重复间隔（天）'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('启用提醒'),
                value: _reminderEnabled,
                onChanged: (value) {
                  setState(() => _reminderEnabled = value);
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
