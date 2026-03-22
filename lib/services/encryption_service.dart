import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 加密服务 - 处理所有数据加密解密
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _secureStorage = const FlutterSecureStorage();
  
  late encrypt.Key _masterKey;
  late encrypt.IV _iv;
  late encrypt.Encrypter _encrypter;
  
  bool _initialized = false;
  
  /// 初始化加密服务
  Future<void> init() async {
    if (_initialized) return;
    
    // 检查是否已存在主密钥
    String? storedKey = await _secureStorage.read(key: 'master_key');
    String? storedIv = await _secureStorage.read(key: 'iv');
    
    if (storedKey != null && storedIv != null) {
      // 恢复已有密钥
      _masterKey = encrypt.Key(base64Decode(storedKey));
      _iv = encrypt.IV(base64Decode(storedIv));
    } else {
      // 生成新密钥
      _masterKey = encrypt.Key.fromSecureRandom(32); // AES-256
      _iv = encrypt.IV.fromSecureRandom(16);
      
      // 安全存储密钥
      await _secureStorage.write(
        key: 'master_key', 
        value: base64Encode(_masterKey.bytes)
      );
      await _secureStorage.write(
        key: 'iv', 
        value: base64Encode(_iv.bytes)
      );
    }
    
    _encrypter = encrypt.Encrypter(
      encrypt.AES(_masterKey, mode: encrypt.AESMode.gcm)
    );
    
    _initialized = true;
  }
  
  /// 使用用户密码派生密钥
  Future<void> deriveKeyFromPassword(String password, String salt) async {
    // PBKDF2 密钥派生
    final pbkdf2 = _PBKDF2();
    final keyBytes = await pbkdf2.deriveKey(
      password: password,
      salt: salt,
      iterations: 100000,
      keyLength: 32,
    );
    
    _masterKey = encrypt.Key(keyBytes);
    _encrypter = encrypt.Encrypter(
      encrypt.AES(_masterKey, mode: encrypt.AESMode.gcm)
    );
    
    _initialized = true;
  }
  
  /// 加密数据
  String encrypt(String plainText) {
    if (!_initialized) throw Exception('EncryptionService not initialized');
    
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }
  
  /// 解密数据
  String decrypt(String encryptedText) {
    if (!_initialized) throw Exception('EncryptionService not initialized');
    
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      throw Exception('解密失败: $e');
    }
  }
  
  /// 加密字节数据
  Uint8List encryptBytes(Uint8List data) {
    if (!_initialized) throw Exception('EncryptionService not initialized');
    
    final encrypted = _encrypter.encryptBytes(data, iv: _iv);
    return Uint8List.fromList(encrypted.bytes);
  }
  
  /// 解密字节数据
  Uint8List decryptBytes(Uint8List encryptedData) {
    if (!_initialized) throw Exception('EncryptionService not initialized');
    
    final encrypted = encrypt.Encrypted(encryptedData);
    return Uint8List.fromList(_encrypter.decryptBytes(encrypted, iv: _iv));
  }
  
  /// 生成随机盐值
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }
  
  /// 哈希密码（用于验证）
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// 清除所有密钥
  Future<void> clearKeys() async {
    await _secureStorage.deleteAll();
    _initialized = false;
  }
}

/// PBKDF2 密钥派生实现
class _PBKDF2 {
  Future<Uint8List> deriveKey({
    required String password,
    required String salt,
    required int iterations,
    required int keyLength,
  }) async {
    // 简化的 PBKDF2 实现
    // 实际项目中应使用更完善的实现或原生插件
    final passwordBytes = utf8.encode(password);
    final saltBytes = base64Decode(salt);
    
    var block = Uint8List.fromList([...passwordBytes, ...saltBytes]);
    var result = Uint8List(0);
    
    final blocksNeeded = (keyLength + 31) ~/ 32;
    
    for (var i = 1; i <= blocksNeeded; i++) {
      var blockResult = _hmacSha256(block, Uint8List.fromList([i]));
      var u = blockResult;
      
      for (var j = 1; j < iterations; j++) {
        u = _hmacSha256(block, u);
        for (var k = 0; k < blockResult.length; k++) {
          blockResult[k] ^= u[k];
        }
      }
      
      result = Uint8List.fromList([...result, ...blockResult]);
    }
    
    return Uint8List.sublistView(result, 0, keyLength);
  }
  
  Uint8List _hmacSha256(Uint8List key, Uint8List message) {
    // 简化的 HMAC-SHA256
    final innerPad = Uint8List(64);
    final outerPad = Uint8List(64);
    
    for (var i = 0; i < key.length && i < 64; i++) {
      innerPad[i] = key[i] ^ 0x36;
      outerPad[i] = key[i] ^ 0x5c;
    }
    
    final innerHash = sha256.convert([...innerPad, ...message]).bytes;
    final outerHash = sha256.convert([...outerPad, ...innerHash]).bytes;
    
    return Uint8List.fromList(outerHash);
  }
}
