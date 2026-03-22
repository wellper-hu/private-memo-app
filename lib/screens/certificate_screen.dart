import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/certificate_item.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<CertificateItem> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);
    final list = await _dbHelper.getAllCertificates();
    setState(() {
      _certificates = list;
      _isLoading = false;
    });
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<CertificateItem>(
      context: context,
      builder: (context) => const AddCertificateDialog(),
    );

    if (result != null) {
      await _dbHelper.insertCertificate(result);
      _loadCertificates();
    }
  }

  Future<void> _showEditDialog(CertificateItem item) async {
    final result = await showDialog<CertificateItem>(
      context: context,
      builder: (context) => EditCertificateDialog(item: item),
    );

    if (result != null) {
      await _dbHelper.updateCertificate(result);
      _loadCertificates();
    }
  }

  Future<void> _deleteItem(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个证书吗？'),
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
      await _dbHelper.deleteCertificate(id);
      _loadCertificates();
    }
  }

  Future<void> _toggleVerified(String id) async {
    final item = _certificates.firstWhere((e) => e.id == id);
    final updated = item.copyWith(isVerified: !item.isVerified);
    await _dbHelper.updateCertificate(updated);
    _loadCertificates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('证书管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _certificates.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '暂无证书',
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
                  itemCount: _certificates.length,
                  itemBuilder: (context, index) {
                    final item = _certificates[index];
                    return _buildCertificateCard(item);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('添加证书'),
      ),
    );
  }

  Widget _buildCertificateCard(CertificateItem item) {
    final isExpired = item.isExpired;
    final isExpiringSoon = item.isExpiringSoon;

    Color? bgColor;
    if (isExpired) {
      bgColor = Colors.red.shade50;
    } else if (isExpiringSoon) {
      bgColor = Colors.orange.shade50;
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _toggleVerified(item.id),
            backgroundColor: item.isVerified ? Colors.green : Colors.amber,
            foregroundColor: Colors.white,
            icon: item.isVerified ? Icons.verified : Icons.verified_user,
            label: item.isVerified ? '已验证' : '验证',
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
                      : Icons.verified,
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
              Text('颁发机构: ${item.issuer}'),
              if (item.certificateNumber != null)
                Text('证书号: ${item.certificateNumber}'),
              Text(
                '有效期: ${DateFormat('yyyy-MM-dd').format(item.issueDate)} - ${DateFormat('yyyy-MM-dd').format(item.expiryDate)}',
              ),
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

class AddCertificateDialog extends StatefulWidget {
  const AddCertificateDialog({super.key});

  @override
  State<AddCertificateDialog> createState() => _AddCertificateDialogState();
}

class _AddCertificateDialogState extends State<AddCertificateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _issuerController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _certificateNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedIssueDate;
  DateTime? _selectedExpiryDate;

  Future<void> _selectIssueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedIssueDate = picked;
        _issueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(1900),
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

    if (_selectedIssueDate == null || _selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择日期')),
      );
      return;
    }

    final item = CertificateItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      issuer: _issuerController.text,
      issueDate: _selectedIssueDate!,
      expiryDate: _selectedExpiryDate!,
      certificateNumber: _certificateNumberController.text.isEmpty
          ? null
          : _certificateNumberController.text,
      location: _locationController.text.isEmpty
          ? null
          : _locationController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加证书'),
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
                controller: _issuerController,
                decoration: const InputDecoration(labelText: '颁发机构'),
                validator: (value) =>
                    value?.isEmpty ?? true ? '请输入颁发机构' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _issueDateController,
                decoration: const InputDecoration(
                  labelText: '颁发日期',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectIssueDate,
                validator: (value) =>
                    value?.isEmpty ?? true ? '请选择日期' : null,
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
                controller: _certificateNumberController,
                decoration: const InputDecoration(labelText: '证书号'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: '存放位置'),
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

class EditCertificateDialog extends StatefulWidget {
  final CertificateItem item;

  const EditCertificateDialog({super.key, required this.item});

  @override
  State<EditCertificateDialog> createState() => _EditCertificateDialogState();
}

class _EditCertificateDialogState extends State<EditCertificateDialog> {
  late final _titleController;
  late final _issuerController;
  late final _issueDateController;
  late final _expiryDateController;
  late final _certificateNumberController;
  late final _locationController;
  late final _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _issuerController = TextEditingController(text: widget.item.issuer);
    _issueDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.item.issueDate),
    );
    _expiryDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.item.expiryDate),
    );
    _certificateNumberController =
        TextEditingController(text: widget.item.certificateNumber ?? '');
    _locationController = TextEditingController(text: widget.item.location ?? '');
    _notesController = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _issuerController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    _certificateNumberController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectIssueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.item.issueDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _issueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.item.expiryDate,
      firstDate: DateTime(1900),
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
      issuer: _issuerController.text,
      issueDate: DateFormat('yyyy-MM-dd').parse(_issueDateController.text),
      expiryDate: DateFormat('yyyy-MM-dd').parse(_expiryDateController.text),
      certificateNumber:
          _certificateNumberController.text.isEmpty ? null : _certificateNumberController.text,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑证书'),
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
                controller: _issuerController,
                decoration: const InputDecoration(labelText: '颁发机构'),
                validator: (value) =>
                    value?.isEmpty ?? true ? '请输入颁发机构' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _issueDateController,
                decoration: const InputDecoration(
                  labelText: '颁发日期',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectIssueDate,
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
                controller: _certificateNumberController,
                decoration: const InputDecoration(labelText: '证书号'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: '存放位置'),
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
