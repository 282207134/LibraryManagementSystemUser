import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:library_management/data/services/auth_service.dart';
import 'package:library_management/data/services/borrowing_service.dart';
import 'package:library_management/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  final _borrowingService = BorrowingService();
  
  User? _user;
  Map<String, dynamic>? _userProfile;
  int _totalBorrows = 0;
  int _currentBorrows = 0;
  int _historyBorrows = 0;
  int _favoritesCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _loading = true);
    try {
      final user = _authService.currentUser;
      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      setState(() => _user = user);

      // 获取用户详细信息
      final profileResponse = await AppConfig.supabase
          .from('users')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (profileResponse != null) {
        setState(() => _userProfile = profileResponse as Map<String, dynamic>);
      }

      // 获取借阅统计
      final borrowings = await _borrowingService.getUserBorrowings(user.id);
      final totalBorrows = borrowings.length;
      final currentBorrows = borrowings
          .where((b) => b.status == 'borrowed' || b.status == 'overdue')
          .length;
      final historyBorrows = borrowings
          .where((b) => b.status == 'returned')
          .length;

      // 获取收藏统计
      final favoritesResponse = await AppConfig.supabase
          .from('book_favorites')
          .select('id')
          .eq('user_id', user.id);

      setState(() {
        _totalBorrows = totalBorrows;
        _currentBorrows = currentBorrows;
        _historyBorrows = historyBorrows;
        _favoritesCount = (favoritesResponse as List).length;
        _loading = false;
      });
    } catch (e) {
      print('加载用户资料失败: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '未知';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}年${date.month}月${date.day}日';
    } catch (e) {
      return dateString;
    }
  }

  String _getAvatarText() {
    // 优先使用full_name的第一个字符
    final fullName = _userProfile?['full_name'] as String?;
    if (fullName != null && fullName.isNotEmpty) {
      // 如果full_name是邮箱格式，使用email的第一个字符
      if (fullName.contains('@') && fullName.contains('.')) {
        final email = _user!.email;
        if (email != null && email.isNotEmpty) {
          return email[0].toUpperCase();
        }
      }
      // 否则使用full_name的第一个字符（支持中文）
      return fullName[0].toUpperCase();
    }
    // 如果没有full_name，使用邮箱的第一个字符
    final email = _user!.email;
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'U';
  }

  String _getFullName() {
    // 优先使用full_name，但如果它是邮箱格式，则使用email
    final fullName = _userProfile?['full_name'] as String?;
    if (fullName != null && fullName.isNotEmpty) {
      // 如果full_name是邮箱格式，使用email作为全名
      if (fullName.contains('@') && fullName.contains('.')) {
        final email = _user!.email;
        if (email != null && email.isNotEmpty) {
          return email;
        }
        // 如果email也不存在，返回full_name（虽然它看起来像邮箱）
        return fullName;
      }
      // 如果full_name不是邮箱格式，直接返回full_name
      return fullName;
    }
    // 如果没有full_name，使用email作为全名
    final email = _user!.email;
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return '未设置姓名';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('个人中心'),
          elevation: 0,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('个人中心'),
          elevation: 0,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('未登录'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('去登录'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置功能开发中')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 用户信息头部
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Text(
                      _getAvatarText(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getFullName(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user!.email ?? '未知邮箱',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('总借阅', '$_totalBorrows', Colors.blue),
                      _buildStatCard('当前借阅', '$_currentBorrows', Colors.orange),
                      _buildStatCard('历史借阅', '$_historyBorrows', Colors.green),
                      _buildStatCard('我的收藏', '$_favoritesCount', Colors.purple),
                    ],
                  ),
                ],
              ),
            ),

            // 账户信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '账户信息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('邮箱地址', _user!.email ?? '未知'),
                  _buildInfoRow(
                    '用户角色',
                    _userProfile?['role'] == 'admin' ? '管理员' : '普通用户',
                  ),
                  if (_userProfile?['member_since'] != null)
                    _buildInfoRow(
                      '注册时间',
                      _formatDate(_userProfile!['member_since'] as String?),
                    ),
                  if (_userProfile?['max_borrow_limit'] != null)
                    _buildInfoRow(
                      '借阅上限',
                      '${_userProfile!['max_borrow_limit']} 本',
                    ),
                ],
              ),
            ),

            // 个人信息
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '个人信息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    '姓名',
                    _getFullName(),
                  ),
                  _buildInfoRow(
                    '电话',
                    _userProfile?['phone'] as String? ?? '未设置',
                  ),
                  _buildInfoRow(
                    '地址',
                    _userProfile?['address'] as String? ?? '未设置',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 操作按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuTile(
                    context,
                    Icons.edit,
                    '编辑资料',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('编辑功能开发中')),
                      );
                    },
                  ),
                  _buildMenuTile(
                    context,
                    Icons.lock,
                    '修改密码',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('修改密码功能开发中')),
                      );
                    },
                  ),
                  _buildMenuTile(
                    context,
                    Icons.history,
                    '借阅历史',
                    () {
                      // 导航到借阅页面
                    },
                  ),
                  _buildMenuTile(
                    context,
                    Icons.logout,
                    '退出登录',
                    _handleLogout,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
