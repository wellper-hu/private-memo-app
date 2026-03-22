import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// 登录/设置密码页面
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSettingPassword = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  bool _hasPassword = false;

  @override
  void initState() {
    super.initState();
    _checkHasPassword();
  }

  Future<void> _checkHasPassword() async {
    final hasPwd = await AuthService().hasPassword();
    setState(() => _hasPassword = hasPwd);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _setPassword() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 6) {
      setState(() => _errorMessage = '密码长度至少6位');
      return;
    }

    if (password != confirm) {
      setState(() => _errorMessage = '两次输入的密码不一致');
      return;
    }

    setState(() {
      _isSettingPassword = true;
      _errorMessage = null;
    });

    await AuthService().setMasterPassword(password);

    setState(() => _isSettingPassword = false);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _login() async {
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() => _errorMessage = '请输入密码');
      return;
    }

    setState(() {
      _isSettingPassword = true;
      _errorMessage = null;
    });

    final isValid = await AuthService().verifyPassword(password);

    setState(() => _isSettingPassword = false);

    if (isValid) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() => _errorMessage = '密码错误');
    }
  }

  Future<void> _useBiometric() async {
    final success = await AuthService().authenticateWithBiometric();
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A73E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: Color(0xFF1A73E8),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 标题
                Text(
                  _hasPassword ? '欢迎回来' : '设置主密码',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _hasPassword 
                      ? '请输入密码解锁应用' 
                      : '请设置一个强密码保护您的数据',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                
                // 密码卡片
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // 密码输入
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: _hasPassword ? '密码' : '设置密码',
                          prefixIcon: const Icon(Icons.password_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorText: _errorMessage,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 确认密码（仅设置时显示）
                      if (!_hasPassword)
                        TextField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: '确认密码',
                            prefixIcon: const Icon(Icons.password_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm 
                                    ? Icons.visibility_off 
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() => _obscureConfirm = !_obscureConfirm);
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      
                      if (!_hasPassword) const SizedBox(height: 16),
                      
                      // 主按钮
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSettingPassword 
                              ? null 
                              : (_hasPassword ? _login : _setPassword),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSettingPassword
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _hasPassword ? '解锁' : '设置并进入',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      
                      // 生物识别按钮（仅登录时显示）
                      if (_hasPassword) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _useBiometric,
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('使用指纹/面容解锁'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1A73E8),
                              side: const BorderSide(color: Color(0xFF1A73E8)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 安全提示
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.white70,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '您的数据已加密存储在本地',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
