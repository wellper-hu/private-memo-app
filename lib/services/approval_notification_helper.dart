import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'approval_service.dart';
import 'approval_notification_service.dart';
import '../database/database_helper.dart';
import '../models/approval_item.dart';

/// 审批通知助手
class ApprovalNotificationHelper {
  static final ApprovalNotificationService _notificationService =
      ApprovalNotificationService();

  /// 检查并显示待审批通知
  static Future<void> checkPendingApprovals(BuildContext context) async {
    final databaseHelper = DatabaseHelper.instance;

    try {
      // 获取待审批数量
      final pendingCount = await databaseHelper.getPendingApprovalCount();

      if (pendingCount > 0) {
        // 显示通知
        await _notificationService.showPendingApprovalNotification(
          '待审批事项',
          '您有 $pendingCount 项审批待处理',
        );

        // 显示应用内通知
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('您有 $pendingCount 项审批待处理'),
              action: SnackBarAction(
                label: '查看',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ApprovalCenterScreen(),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('检查审批通知失败: $e');
    }
  }

  /// 创建审批时发送通知
  static Future<void> notifyApprovalCreated(ApprovalItem approval) async {
    try {
      await _notificationService.showPendingApprovalNotification(
        '新审批',
        '您有新的审批事项: ${approval.title}',
      );
    } catch (e) {
      debugPrint('发送审批通知失败: $e');
    }
  }

  /// 审批通过时发送通知
  static Future<void> notifyApprovalApproved(ApprovalItem approval) async {
    try {
      await _notificationService.showPendingApprovalNotification(
        '审批通过',
        '您的审批已通过: ${approval.title}',
      );
    } catch (e) {
      debugPrint('发送审批通知失败: $e');
    }
  }

  /// 审批拒绝时发送通知
  static Future<void> notifyApprovalRejected(ApprovalItem approval) async {
    try {
      await _notificationService.showPendingApprovalNotification(
        '审批被拒绝',
        '您的审批被拒绝: ${approval.title}',
      );
    } catch (e) {
      debugPrint('发送审批通知失败: $e');
    }
  }

  /// 初始化通知权限
  static Future<bool> initializeNotifications() async {
    try {
      await _notificationService.initialize();
      final hasPermission = await _notificationService.requestPermission();
      return hasPermission;
    } catch (e) {
      debugPrint('初始化通知失败: $e');
      return false;
    }
  }
}
