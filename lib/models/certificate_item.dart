import 'package:equatable/equatable.dart';

/// 证书模型
class CertificateItem extends Equatable {
  final String id;
  final String title;
  final String issuer;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String? certificateNumber;
  final String? location;
  final String? imageUrl;
  final String? notes;
  final bool isVerified;

  const CertificateItem({
    required this.id,
    required this.title,
    required this.issuer,
    required this.issueDate,
    required this.expiryDate,
    this.certificateNumber,
    this.location,
    this.imageUrl,
    this.notes,
    this.isVerified = false,
  });

  CertificateItem copyWith({
    String? id,
    String? title,
    String? issuer,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? certificateNumber,
    String? location,
    String? imageUrl,
    String? notes,
    bool? isVerified,
  }) {
    return CertificateItem(
      id: id ?? this.id,
      title: title ?? this.title,
      issuer: issuer ?? this.issuer,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  /// 检查证书是否过期
  bool get isExpired {
    return DateTime.now().isAfter(expiryDate);
  }

  /// 检查证书是否即将过期（30天内）
  bool get isExpiringSoon {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    return daysLeft > 0 && daysLeft <= 30;
  }

  /// 获取剩余天数
  int getDaysRemaining() {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'issuer': issuer,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'certificateNumber': certificateNumber,
      'location': location,
      'imageUrl': imageUrl,
      'notes': notes,
      'isVerified': isVerified,
    };
  }

  factory CertificateItem.fromJson(Map<String, dynamic> json) {
    return CertificateItem(
      id: json['id'] as String,
      title: json['title'] as String,
      issuer: json['issuer'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      certificateNumber: json['certificateNumber'] as String?,
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String?,
      notes: json['notes'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        issuer,
        issueDate,
        expiryDate,
        certificateNumber,
        location,
        imageUrl,
        notes,
        isVerified,
      ];
}
