import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'encryption_service.dart';

/// 认证服务 - 处理安装验证、登录、生物识别
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _secureStorage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  
  bool _initialized = false;
  bool _isFirstInstall = false;
  bool _isLoggedIn = false;
  
  /// 初始化
  Future<void> init() async {
    if (_initialized) return;
    
    // 检查是否首次安装
    final prefs = await SharedPreferences.getInstance();
    _isFirstInstall = prefs.getBool('installed') ?? true;
    _isLoggedIn = prefs.getBool('logged_in') ?? false;
    
    _initialized = true;
  }
  
  /// 是否首次安装
  bool get isFirstInstall => _isFirstInstall;
  
  /// 是否已登录
  bool get isLoggedIn => _isLoggedIn;
  
  /// 验证安装验证码
  /// 格式: wellper + 年月日时分 (如 wellper202512091127)
  Future<bool> verifyInstallCode(String code) async {
    final now = DateTime.now();
    final expectedCode = 'wellper${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    
    // 同时验证前后2分钟的时间窗口
    for (int i = -2; i <= 2; i++) {
      final checkTime = now.add(Duration(minutes: i));
      final checkCode = 'wellper${checkTime.year}${checkTime.month.toString().padLeft(2, '0')}${checkTime.day.toString().padLeft(2, '0')}${checkTime.hour.toString().padLeft(2, '0')}${checkTime.minute.toString().padLeft(2, '0')}';
      
      if (code == checkCode) {
        // 验证通过，标记已安装
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('installed', true);
        _isFirstInstall = false;
        return true;
      }
    }
    
    return false;
  }
  
  /// 设置主密码
  Future<void> setMasterPassword(String password) async {
    final salt = EncryptionService().generateSalt();
    final passwordHash = EncryptionService().hashPassword(password, salt);
    
    await _secureStorage.write(key: 'password_hash', value: passwordHash);
    await _secureStorage.write(key: 'password_salt', value: salt);
    
    // 派生加密密钥
    await EncryptionService().deriveKeyFromPassword(password, salt);
  }
  
  /// 验证主密码
  Future<bool> verifyPassword(String password) async {
    final storedHash = await _secureStorage.read(key: 'password_hash');
    final salt = await _secureStorage.read(key: 'password_salt');
    
    if (storedHash == null || salt == null) {
      return false;
    }
    
    final inputHash = EncryptionService().hashPassword(password, salt);
    
    if (inputHash == storedHash) {
      // 密码正确，派生密钥
      await EncryptionService().deriveKeyFromPassword(password, salt);
      
      // 标记已登录
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged_in', true);
      _isLoggedIn = true;
      
      return true;
    }
    
    return false;
  }
  
  /// 检查是否已设置密码
  Future<bool> hasPassword() async {
    final storedHash = await _secureStorage.read(key: 'password_hash');
    return storedHash != null;
  }
  
  /// 启用生物识别
  Future<bool> enableBiometric() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    if (!canCheck) return false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', true);
    return true;
  }
  
  /// 生物识别登录
  Future<bool> authenticateWithBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('biometric_enabled') ?? false;
    
    if (!enabled) return false;
    
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: '请验证身份以解锁私密备忘录',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      
      if (authenticated) {
        await prefs.setBool('logged_in', true);
        _isLoggedIn = true;
      }
      
      return authenticated;
    } catch (e) {
      return false;
    }
  }
  
  /// 检查是否支持生物识别
  Future<bool> isBiometricAvailable() async {
    return await _localAuth.canCheckBiometrics;
  }
  
  /// 登出
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', false);
    _isLoggedIn = false;
  }
  
  /// 锁定应用
  Future<void> lock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', false);
    _isLoggedIn = false;
  }
  
  /// 获取当前时间验证码（用于管理员生成）
  String getCurrentVerifyCode() {
    final now = DateTime.now();
    return 'wellper${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }
}
