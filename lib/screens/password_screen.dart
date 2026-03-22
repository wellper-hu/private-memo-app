import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/memo_item.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<PasswordItem> _passwords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    setState(() => _isLoading = true);
    final passwords = await _dbHelper.getAllPasswords();
    setState(() {
      _passwords = passwords;
      _isLoading = false;
    });
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<PasswordItem>(
      context: context,
      builder: (context) => const AddPasswordDialog(),
    );

    if (result != null) {
      await _dbHelper.insertPassword(result);
      _loadPasswords();
    }
  }

  Future<void> _showEditDialog(PasswordItem item) async {
    final result = await showDialog<PasswordItem>(
      context: context,
      builder: (context) => EditPasswordDialog(item: item),
    );

    if (result != null) {
      await _dbHelper.updatePassword(result);
      _loadPasswords();
    }
  }

  Future<void> _toggleFavorite(String id) async {
    await _dbHelper.toggleFavoritePassword(id);
    _loadPasswords();
  }

  Future<void> _deleteItem(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个密码项吗？'),
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
      await _dbHelper.deletePassword(id);
      _loadPasswords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('密码本'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 搜索功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _passwords.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_open, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        '暂无密码',
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
                  itemCount: _passwords.length,
                  itemBuilder: (context, index) {
                    final item = _passwords[index];
                    return _buildPasswordCard(item);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('添加密码'),
      ),
    );
  }

  Widget _buildPasswordCard(PasswordItem item) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _toggleFavorite(item.id),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            icon: item.isFavorite ? Icons.star : Icons.star_border,
            label: '收藏',
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
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: item.isFavorite ? Colors.amber : Colors.blue,
            child: Icon(
              item.isFavorite ? Icons.star : Icons.lock,
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
              Text('用户名: ${item.username}'),
              if (item.url != null) Text('链接: ${item.url}'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.visibility_off),
            onPressed: () {
              // 显示密码
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('密码'),
                  content: Text(
                    item.password,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AddPasswordDialog extends StatefulWidget {
  const AddPasswordDialog({super.key});

  @override
  State<AddPasswordDialog> createState() => _AddPasswordDialogState();
}

class _AddPasswordDialogState extends State<AddPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final item = PasswordItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      url: _urlController.text.isEmpty ? null : _urlController.text,
      category: _categoryController.text.isEmpty ? null : _categoryController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加密码'),
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
                controller: _usernameController,
                decoration: const InputDecoration(labelText: '用户名'),
                validator: (value) =>
                    value?.isEmpty ?? true ? '请输入用户名' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '密码'),
                validator: (value) =>
                    value?.isEmpty ?? true ? '请输入密码' : null,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: '网址'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: '分类'),
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

class EditPasswordDialog extends StatefulWidget {
  final PasswordItem item;

  const EditPasswordDialog({super.key, required this.item});

  @override
  State<EditPasswordDialog> createState() => _EditPasswordDialogState();
}

class _EditPasswordDialogState extends State<EditPasswordDialog> {
  late final _titleController;
  late final _usernameController;
  late final _passwordController;
  late final _urlController;
  late final _categoryController;
  late final _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _usernameController = TextEditingController(text: widget.item.username);
    _passwordController = TextEditingController(text: widget.item.password);
    _urlController = TextEditingController(text: widget.item.url ?? '');
    _categoryController = TextEditingController(text: widget.item.category ?? '');
    _notesController = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
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
      username: _usernameController.text,
      password: _passwordController.text,
      url: _urlController.text.isEmpty ? null : _urlController.text,
      category: _categoryController.text.isEmpty ? null : _categoryController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑密码'),
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
                controller: _usernameController,
                decoration: const InputDecoration(labelText: '用户名'),
                validator: (value) =>
                    value?.isEmpty ?? true ? '请输入用户名' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '密码'),
                validator: (value) =>
                    value?.isEmpty ?? true ? '请输入密码' : null,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: '网址'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: '分类'),
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
