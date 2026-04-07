import 'dart:io';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/memo_item.dart';
import '../models/anniversary_item.dart';
import '../models/certificate_item.dart';
import '../models/repayment_item.dart';
import '../models/expiry_item.dart';
import '../models/approval_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // 表名
  static const String _tablePasswords = 'passwords';
  static const String _tableAnniversaries = 'anniversaries';
  static const String _tableCertificates = 'certificates';
  static const String _tableRepayments = 'repayments';
  static const String _tableExpiries = 'expiries';
  static const String _tableApprovals = 'approvals';

  // 加密密钥（实际应用中应该从安全存储中获取）
  static const String _key = 'your-32-byte-secret-key-1234567890abcdef';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('private_memo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // 加密数据库
    final secretKey = Key.fromUtf8(_key);
    final secretIV = IV.fromLength(16);

    final database = await openDatabase(
      path,
      version: 1,
      password: _key, // 使用密码加密数据库
      onCreate: _createDB,
    );

    return database;
  }

  Future<void> _createDB(Database db, int version) async {
    // 密码本表
    await db.execute('''
      CREATE TABLE $_tablePasswords (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        url TEXT,
        category TEXT,
        notes TEXT,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 纪念日表
    await db.execute('''
      CREATE TABLE $_tableAnniversaries (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        repeatDays INTEGER DEFAULT 365,
        notes TEXT,
        isReminderEnabled INTEGER DEFAULT 1,
        lastReminderDate TEXT,
        reminderOffsetDays INTEGER
      )
    ''');

    // 证书表
    await db.execute('''
      CREATE TABLE $_tableCertificates (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        issuer TEXT NOT NULL,
        issueDate TEXT NOT NULL,
        expiryDate TEXT NOT NULL,
        certificateNumber TEXT,
        location TEXT,
        imageUrl TEXT,
        notes TEXT,
        isVerified INTEGER DEFAULT 0
      )
    ''');

    // 还款提醒表
    await db.execute('''
      CREATE TABLE $_tableRepayments (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        lenderName TEXT NOT NULL,
        amount REAL NOT NULL,
        dueDate TEXT NOT NULL,
        paidAmount REAL,
        repaymentMethod TEXT,
        notes TEXT,
        isCompleted INTEGER DEFAULT 0,
        isReminderEnabled INTEGER DEFAULT 1,
        lastReminderDate TEXT,
        reminderOffsetDays INTEGER
      )
    ''');

    // 有效期提醒表
    await db.execute('''
      CREATE TABLE $_tableExpiries (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        expiryDate TEXT NOT NULL,
        location TEXT,
        description TEXT,
        imageUrl TEXT,
        isReminderEnabled INTEGER DEFAULT 1,
        reminderOffsetDays INTEGER DEFAULT 7
      )
    ''');

    // 审批表
    await db.execute('''
      CREATE TABLE $_tableApprovals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        applicant TEXT NOT NULL,
        approver TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        notes TEXT,
        approvedAt TEXT,
        approvedBy TEXT
      )
    ''');
  }

  // ==================== 密码本 ====================
  Future<List<PasswordItem>> getAllPasswords() async {
    final db = await instance.database;
    final result = await db.query(
      _tablePasswords,
      orderBy: 'isFavorite DESC, updatedAt DESC',
    );
    return result.map((json) => PasswordItem.fromJson(json)).toList();
  }

  Future<PasswordItem?> getPasswordById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      _tablePasswords,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return PasswordItem.fromJson(result.first);
  }

  Future<int> insertPassword(PasswordItem item) async {
    final db = await instance.database;
    return db.insert(_tablePasswords, item.toJson());
  }

  Future<int> updatePassword(PasswordItem item) async {
    final db = await instance.database;
    return db.update(
      _tablePasswords,
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deletePassword(String id) async {
    final db = await instance.database;
    return db.delete(
      _tablePasswords,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavoritePassword(String id) async {
    final db = await instance.database;
    final item = await getPasswordById(id);
    if (item == null) return 0;
    final updated = item.copyWith(isFavorite: !item.isFavorite);
    return updatePassword(updated);
  }

  // ==================== 纪念日 ====================
  Future<List<AnniversaryItem>> getAllAnniversaries() async {
    final db = await instance.database;
    final result = await db.query(
      _tableAnniversaries,
      orderBy: 'date ASC',
    );
    return result.map((json) => AnniversaryItem.fromJson(json)).toList();
  }

  Future<AnniversaryItem?> getAnniversaryById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      _tableAnniversaries,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return AnniversaryItem.fromJson(result.first);
  }

  Future<int> insertAnniversary(AnniversaryItem item) async {
    final db = await instance.database;
    return db.insert(_tableAnniversaries, item.toJson());
  }

  Future<int> updateAnniversary(AnniversaryItem item) async {
    final db = await instance.database;
    return db.update(
      _tableAnniversaries,
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteAnniversary(String id) async {
    final db = await instance.database;
    return db.delete(
      _tableAnniversaries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 证书 ====================
  Future<List<CertificateItem>> getAllCertificates() async {
    final db = await instance.database;
    final result = await db.query(
      _tableCertificates,
      orderBy: 'expiryDate ASC',
    );
    return result.map((json) => CertificateItem.fromJson(json)).toList();
  }

  Future<CertificateItem?> getCertificateById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      _tableCertificates,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return CertificateItem.fromJson(result.first);
  }

  Future<int> insertCertificate(CertificateItem item) async {
    final db = await instance.database;
    return db.insert(_tableCertificates, item.toJson());
  }

  Future<int> updateCertificate(CertificateItem item) async {
    final db = await instance.database;
    return db.update(
      _tableCertificates,
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteCertificate(String id) async {
    final db = await instance.database;
    return db.delete(
      _tableCertificates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 还款提醒 ====================
  Future<List<RepaymentItem>> getAllRepayments() async {
    final db = await instance.database;
    final result = await db.query(
      _tableRepayments,
      orderBy: 'dueDate ASC',
    );
    return result.map((json) => RepaymentItem.fromJson(json)).toList();
  }

  Future<RepaymentItem?> getRepaymentById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      _tableRepayments,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return RepaymentItem.fromJson(result.first);
  }

  Future<int> insertRepayment(RepaymentItem item) async {
    final db = await instance.database;
    return db.insert(_tableRepayments, item.toJson());
  }

  Future<int> updateRepayment(RepaymentItem item) async {
    final db = await instance.database;
    return db.update(
      _tableRepayments,
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteRepayment(String id) async {
    final db = await instance.database;
    return db.delete(
      _tableRepayments,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleCompleteRepayment(String id) async {
    final db = await instance.database;
    final item = await getRepaymentById(id);
    if (item == null) return 0;
    final updated = item.copyWith(isCompleted: !item.isCompleted);
    return updateRepayment(updated);
  }

  Future<int> updatePaidAmount(String id, double amount) async {
    final db = await instance.database;
    final item = await getRepaymentById(id);
    if (item == null) return 0;
    final updated = item.copyWith(paidAmount: amount);
    return updateRepayment(updated);
  }

  // ==================== 有效期提醒 ====================
  Future<List<ExpiryItem>> getAllExpiries() async {
    final db = await instance.database;
    final result = await db.query(
      _tableExpiries,
      orderBy: 'expiryDate ASC',
    );
    return result.map((json) => ExpiryItem.fromJson(json)).toList();
  }

  Future<ExpiryItem?> getExpiryById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      _tableExpiries,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return ExpiryItem.fromJson(result.first);
  }

  Future<int> insertExpiry(ExpiryItem item) async {
    final db = await instance.database;
    return db.insert(_tableExpiries, item.toJson());
  }

  Future<int> updateExpiry(ExpiryItem item) async {
    final db = await instance.database;
    return db.update(
      _tableExpiries,
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteExpiry(String id) async {
    final db = await instance.database;
    return db.delete(
      _tableExpiries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 审批 ====================
  Future<List<ApprovalItem>> getAllApprovals() async {
    final db = await instance.database;
    final result = await db.query(
      _tableApprovals,
      orderBy: 'createdAt DESC',
    );
    return result.map((json) => ApprovalItem.fromJson(json)).toList();
  }

  Future<ApprovalItem?> getApprovalById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      _tableApprovals,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return ApprovalItem.fromJson(result.first);
  }

  Future<int> insertApproval(ApprovalItem item) async {
    final db = await instance.database;
    return db.insert(_tableApprovals, item.toJson());
  }

  Future<int> updateApproval(ApprovalItem item) async {
    final db = await instance.database;
    return db.update(
      _tableApprovals,
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteApproval(String id) async {
    final db = await instance.database;
    return db.delete(
      _tableApprovals,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateApprovalStatus(String id, ApprovalStatus status, {String? approver}) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    return db.update(
      _tableApprovals,
      {
        'status': status.name,
        'approvedAt': now,
        'approvedBy': approver,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 审批统计 ====================
  Future<int> getPendingApprovalCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableApprovals WHERE status = ?',
      ['pending'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getApprovedCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableApprovals WHERE status = ?',
      ['approved'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getRejectedCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableApprovals WHERE status = ?',
      ['rejected'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<ApprovalItem>> getPendingApprovals() async {
    final db = await instance.database;
    final result = await db.query(
      _tableApprovals,
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'createdAt ASC',
    );
    return result.map((json) => ApprovalItem.fromJson(json)).toList();
  }

  // ==================== 清空所有数据 ====================
  Future<void> clearAllTables() async {
    final db = await instance.database;
    await db.delete(_tablePasswords);
    await db.delete(_tableAnniversaries);
    await db.delete(_tableCertificates);
    await db.delete(_tableRepayments);
    await db.delete(_tableExpiries);
    await db.delete(_tableApprovals);
  }

  // ==================== 数据库迁移 ====================
  Future<void> migrate() async {
    final db = await instance.database;
    // 可以在这里添加版本迁移逻辑
  }
}
