import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('管理界面'),
        elevation: 0,
        backgroundColor: isDark ? colorScheme.surface : null,
        foregroundColor: isDark ? colorScheme.onSurface : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            context,
            icon: Icons.library_books,
            title: '图书管理',
            subtitle: '新增、编辑与维护图书信息（即将开放）',
          ),
          _buildCard(
            context,
            icon: Icons.assignment_return,
            title: '借阅管理',
            subtitle: '处理借阅、归还与逾期记录（即将开放）',
          ),
          _buildCard(
            context,
            icon: Icons.people,
            title: '用户管理',
            subtitle: '管理用户资料与权限角色（即将开放）',
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
