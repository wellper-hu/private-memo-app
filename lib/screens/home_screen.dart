import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'password_screen.dart';
import 'anniversary_screen.dart';
import 'certificate_screen.dart';
import 'repayment_screen.dart';
import 'expiry_screen.dart';
import 'approval_center_screen.dart';
import '../services/approval_service.dart';
import '../database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PasswordScreen(),
    const AnniversaryScreen(),
    const CertificateScreen(),
    const RepaymentScreen(),
    const ExpiryScreen(),
  ];

  final List<String> _titles = [
    '密码本',
    '纪念日',
    '证书管理',
    '还款提醒',
    '有效期提醒',
  ];

  final List<IconData> _icons = [
    Icons.lock,
    Icons.cake,
    Icons.verified_user,
    Icons.account_balance_wallet,
    Icons.timer,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApprovalBloc(DatabaseHelper.instance)
        ..add(const LoadApprovals())
        ..add(const GetPendingCount()),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: List.generate(
            _titles.length,
            (index) => NavigationDestination(
              icon: Icon(_icons[index]),
              label: _titles[index],
            ),
          ),
        ),
      ),
    );
  }
}

/// 快捷入口卡片
class QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount;

  const QuickAccessCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: Colors.white,
                  ),
                  if (badgeCount != null && badgeCount! > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 首页仪表板
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('私密备忘录'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 设置页面
            },
          ),
        ],
      ),
      body: BlocBuilder<ApprovalBloc, ApprovalState>(
        builder: (context, state) {
          int pendingCount = 0;
          if (state is PendingCountLoaded) {
            pendingCount = state.count;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '快捷入口',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      QuickAccessCard(
                        title: '密码本',
                        icon: Icons.lock,
                        color: Colors.blue,
                        onTap: () => _navigateTo(context, const PasswordScreen()),
                      ),
                      QuickAccessCard(
                        title: '纪念日',
                        icon: Icons.cake,
                        color: Colors.purple,
                        onTap: () => _navigateTo(context, const AnniversaryScreen()),
                      ),
                      QuickAccessCard(
                        title: '证书管理',
                        icon: Icons.verified_user,
                        color: Colors.green,
                        onTap: () => _navigateTo(context, const CertificateScreen()),
                      ),
                      QuickAccessCard(
                        title: '还款提醒',
                        icon: Icons.account_balance_wallet,
                        color: Colors.orange,
                        onTap: () => _navigateTo(context, const RepaymentScreen()),
                      ),
                      QuickAccessCard(
                        title: '有效期提醒',
                        icon: Icons.timer,
                        color: Colors.red,
                        onTap: () => _navigateTo(context, const ExpiryScreen()),
                      ),
                      QuickAccessCard(
                        title: '审批中心',
                        icon: Icons.approval,
                        color: Colors.teal,
                        onTap: () => _navigateTo(context, const ApprovalCenterScreen()),
                        badgeCount: pendingCount > 0 ? pendingCount : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
