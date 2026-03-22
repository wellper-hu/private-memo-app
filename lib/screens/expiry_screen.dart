import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/expiry_item.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class ExpiryScreen extends StatefulWidget {
  const ExpiryScreen({super.key});

  @override
  State<ExpiryScreen> createState() => _ExpiryScreenState();
}

class _ExpiryScreenState extends State<ExpiryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<ExpiryItem> _expiries = [];
  bool _isLoading = true;
  String _selectedCategory = '全部';

  final List<String> _categories = [
    '全部',
    '食品',
    '药品',
    '化妆品',
    '证件',
    '会员卡',
    '保险',
    '合同',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    _loadExpiries();
  }

  Future<void> _loadExpiries() async {
    setState(() => _isLoading = true);
    final list = await _dbHelper.getAllExpiries();
    setState(() {
      _expiries = _selectedCategory == '全部'
          ? list
          : list.where((e) => e.category == _selectedCategory).toList();
      _isLoading = false;
    });
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<ExpiryItem>(
      context: context,
      builder: (context) => const AddExpiryDialog(),
    );

    if (result != null) {
      await _dbHelper.insertExpiry(result);
      _loadExpiries();
    }
  }

  Future<void> _showEditDialog(ExpiryItem item) async {
    final result = await showDialog<ExpiryItem>(
      context: context,
      builder: (context) => EditExpiryDialog(item: item),
    );

    if (result != null) {
      await _dbHelper.updateExpiry(result);
      _loadExpiries();
    }
  }

  Future<void> _deleteItem(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个有效期项吗？'),
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
      await _dbHelper.deleteExpiry(id);
      _loadExpiries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('有效期提醒'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类筛选
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                          _loadExpiries();
                        });
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // 列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _expiries.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timer_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              '暂无有效期提醒',
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
                        itemCount: _expiries.length,
                        itemBuilder: (context, index) {
                          final item = _expiries[index];
                          return _buildExpiryCard(item);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('添加提醒'),
      ),
    );
  }

  Widget _buildExpiryCard(ExpiryItem item) {
    final isExpired = item.isExpired;
    final isExpiringSoon = item.isExpiringSoon;

    Color? bgColor;
    if (isExpired) {
      bgColor = Colors.red.shade50;
    } else if (isExpiringSoon) {
      bgColor = Colors.orange.shade50;
    }

    IconData categoryIcon;
    switch (item.category) {
      case '食品':
        categoryIcon = Icons.restaurant;
        break;
      case '药品':
        categoryIcon = Icons.local_pharmacy;
        break;
      case '化妆品':
        categoryIcon = Icons.face;
        break;
      case '证件':
        categoryIcon = Icons.badge;
        break;
      case '会员卡':
        categoryIcon = Icons.card_membership;
        break;
      case '保险':
        categoryIcon = Icons.health_and_safety;
        break;
      case '合同':
        categoryIcon = Icons.description;
        break;
      default:
        categoryIcon = Icons.timer;
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
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
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isExpired
                ? Colors.red
                : isExpiringSoon
                    ? Colors.orange
                    : Colors.green,
            child: Icon(
              isExpired
                  ? Icons.error
                  : isExpiringSoon
                      ? Icons.warning
                      : categoryIcon,
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
              Text('分类: ${item.category}'),
              Text(
                '过期日期: ${DateFormat('yyyy-MM-dd').format(item.expiryDate)}',
              ),
              if (item.location != null) Text('存放位置: ${item.location}'),
              if (isExpired)
                Text(
                  '已过期',
                  style: const TextStyle(color: Colors.red),
                )
              else if (isExpiringSoon)
                Text(
                  '即将过期（${item.getDaysRemaining()}天）',
                  style: const TextStyle(color: Colors.orange),
                )
              else
                Text(
                  '剩余${item.getDaysRemaining()}天',
                  style: const TextStyle(color: Colors.green),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddExpiryDialog extends StatefulWidget {
  const AddExpiryDialog({super.key});

  @override
  State<AddExpiryDialog> createState() => _AddExpiryDialogState();
}

class _AddExpiryDialogState extends State<AddExpiryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = '其他';
  DateTime? _selectedExpiryDate;
  bool _isReminderEnabled = true;
  int? _reminderOffsetDays = 7;

  final List<String> _categories = [
    '食品',
    '药品',
    '化妆品',
    '证件',
    '会员卡',
    '保险',
    '合同',
    '其他',
  ];

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
        _expiryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择过期日期')),
      );
      return;
    }

    final item = ExpiryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      category: _selectedCategory,
      expiryDate: _selectedExpiryDate!,
      location: _locationController.text.isEmpty
          ? null
          : _locationController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      isReminderEnabled: _isReminderEnabled,
      reminderOffsetDays: _reminderOffsetDays,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加有效期提醒'),
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
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: '分类'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: '过期日期',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectExpiryDate,
                validator: (value) =>
                    value?.isEmpty ?? true ? '请选择日期' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: '存放位置'),
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
                  text: _reminderOffsetDays?.toString() ?? '7',
                ),
                decoration: const InputDecoration(
                  labelText: '提前提醒天数',
                  hintText: '默认提前7天提醒',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _reminderOffsetDays = int.tryParse(value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '描述'),
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

class EditExpiryDialog extends StatefulWidget {
  final ExpiryItem item;

  const EditExpiryDialog({super.key, required this.item});

  @override
  State<EditExpiryDialog> createState() => _EditExpiryDialogState();
}

class _EditExpiryDialogState extends State<EditExpiryDialog> {
  late final _titleController;
  late final _expiryDateController;
  late final _locationController;
  late final _descriptionController;
  late String _selectedCategory;
  late bool _isReminderEnabled;
  late int? _reminderOffsetDays;

  final List<String> _categories = [
    '食品',
    '药品',
    '化妆品',
    '证件',
    '会员卡',
    '保险',
    '合同',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _expiryDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.item.expiryDate),
    );
    _locationController = TextEditingController(text: widget.item.location ?? '');
    _descriptionController = TextEditingController(text: widget.item.description ?? '');
    _selectedCategory = widget.item.category;
    _isReminderEnabled = widget.item.isReminderEnabled;
    _reminderOffsetDays = widget.item.reminderOffsetDays;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _expiryDateController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.item.expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
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
      category: _selectedCategory,
      expiryDate: DateFormat('yyyy-MM-dd').parse(_expiryDateController.text),
      location: _locationController.text.isEmpty ? null : _locationController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      isReminderEnabled: _isReminderEnabled,
      reminderOffsetDays: _reminderOffsetDays,
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑有效期提醒'),
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
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: '分类'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: '过期日期',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectExpiryDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: '存放位置'),
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
                  text: _reminderOffsetDays?.toString() ?? '7',
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
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '描述'),
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