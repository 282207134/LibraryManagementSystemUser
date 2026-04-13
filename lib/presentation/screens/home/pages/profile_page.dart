import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_management/data/services/auth_service.dart';
import 'package:library_management/data/services/borrowing_service.dart';
import 'package:library_management/config/app_config.dart';
import 'package:library_management/localization/app_localization.dart';
import 'package:library_management/providers/theme_mode_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
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
        setState(() => _userProfile = profileResponse);
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
        title: Text(AppLocalization.tr('logout')),
        content: Text(AppLocalization.tr('confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalization.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalization.tr('confirm')),
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

  Future<void> _handleEditProfile() async {
    final user = _user;
    if (user == null) return;

    final nameController = TextEditingController(text: _getFullName());
    final phoneController = TextEditingController(
      text: _userProfile?['phone'] as String? ?? '',
    );
    final addressController = TextEditingController(
      text: _userProfile?['address'] as String? ?? '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalization.tr('edit_profile')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: AppLocalization.tr('name')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: AppLocalization.tr('phone')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: AppLocalization.tr('address')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalization.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalization.tr('save')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await AppConfig.supabase.from('users').update({
        'full_name': nameController.text.trim(),
        'phone': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        'address': addressController.text.trim().isEmpty ? null : addressController.text.trim(),
      }).eq('id', user.id);

      await _loadUserProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalization.tr('save'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalization.tr('operation_failed')}: $e')),
      );
    }
  }

  Future<void> _handleChangePassword() async {
    final email = _user?.email;
    if (email == null || email.isEmpty) return;

    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalization.tr('change_password')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: InputDecoration(labelText: AppLocalization.tr('password')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: InputDecoration(labelText: AppLocalization.tr('password')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(labelText: AppLocalization.tr('confirm_password')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalization.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalization.tr('update')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final currentPassword = currentController.text;
    final newPassword = newController.text;
    final confirmPassword = confirmController.text;

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalization.tr('password_length_error'))),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalization.tr('new_password_mismatch'))),
      );
      return;
    }

    try {
      await _authService.signInWithEmail(email: email, password: currentPassword);
      await AppConfig.supabase.auth.updateUser(UserAttributes(password: newPassword));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalization.tr('password_changed_relogin'))),
      );
      await _authService.signOut();
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalization.tr('operation_failed')}: $e')),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return AppLocalization.tr('unknown');
    try {
      final date = DateTime.parse(dateString);
      final language = AppLocalization.notifier.value;
      switch (language) {
        case AppLanguage.zh:
          return '${date.year}年${date.month}月${date.day}日';
        case AppLanguage.en:
          return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        case AppLanguage.ja:
          return '${date.year}/${date.month}/${date.day}';
      }
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
    return AppLocalization.tr('not_set');
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return AppLocalization.tr('theme_system');
      case ThemeMode.light:
        return AppLocalization.tr('theme_light');
      case ThemeMode.dark:
        return AppLocalization.tr('theme_dark');
    }
  }

  String _roleLabel(dynamic rawRole) {
    final role = (rawRole ?? '').toString().toLowerCase().trim();
    if (role == 'admin' || rawRole == '管理员' || rawRole == '管理者') {
      return AppLocalization.tr('admin_role');
    }
    return AppLocalization.tr('normal_user');
  }

  Future<void> _showLanguagePicker() async {
    final current = AppLocalization.notifier.value;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  AppLocalization.tr('language'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...AppLanguage.values.map(
                  (lang) => RadioListTile<AppLanguage>(
                    value: lang,
                    groupValue: current,
                    title: Text(AppLocalization.languageLabel(lang)),
                    onChanged: (v) async {
                      if (v == null) return;
                      await AppLocalization.setLanguage(v);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showThemeModePicker() async {
    final current = ref.read(themeModeProvider);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  AppLocalization.tr('theme_mode'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: current,
                  title: Text(AppLocalization.tr('theme_system')),
                  onChanged: (v) async {
                    if (v == null) return;
                    await ref.read(themeModeProvider.notifier).setThemeMode(v);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: current,
                  title: Text(AppLocalization.tr('theme_light')),
                  onChanged: (v) async {
                    if (v == null) return;
                    await ref.read(themeModeProvider.notifier).setThemeMode(v);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: current,
                  title: Text(AppLocalization.tr('theme_dark')),
                  onChanged: (v) async {
                    if (v == null) return;
                    await ref.read(themeModeProvider.notifier).setThemeMode(v);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalization.tr('profile')),
          elevation: 0,
          backgroundColor: isDark ? colorScheme.surface : null,
          foregroundColor: isDark ? colorScheme.onSurface : null,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalization.tr('profile')),
          elevation: 0,
          backgroundColor: isDark ? colorScheme.surface : null,
          foregroundColor: isDark ? colorScheme.onSurface : null,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(AppLocalization.tr('login')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: Text(AppLocalization.tr('go_login')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalization.tr('profile')),
        elevation: 0,
        backgroundColor: isDark ? colorScheme.surface : null,
        foregroundColor: isDark ? colorScheme.onSurface : null,
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
                    _user!.email ?? AppLocalization.tr('unknown'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(AppLocalization.tr('total_borrows'), '$_totalBorrows', Colors.blue),
                      _buildStatCard(AppLocalization.tr('current_borrows'), '$_currentBorrows', Colors.orange),
                      _buildStatCard(AppLocalization.tr('history_borrows'), '$_historyBorrows', Colors.green),
                      _buildStatCard(AppLocalization.tr('favorites'), '$_favoritesCount', Colors.purple),
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
                  Text(
                    AppLocalization.tr('account_info'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(AppLocalization.tr('email_address'), _user!.email ?? AppLocalization.tr('unknown')),
                  _buildInfoRow(
                    AppLocalization.tr('user_role'),
                    _roleLabel(_userProfile?['role']),
                  ),
                  if (_userProfile?['member_since'] != null)
                    _buildInfoRow(
                      AppLocalization.tr('registered_at'),
                      _formatDate(_userProfile!['member_since'] as String?),
                    ),
                  if (_userProfile?['max_borrow_limit'] != null)
                    _buildInfoRow(
                      AppLocalization.tr('borrow_limit'),
                      '${_userProfile!['max_borrow_limit']} ${AppLocalization.tr('book_unit')}',
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
                  Text(
                    AppLocalization.tr('personal_info'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    AppLocalization.tr('name'),
                    _getFullName(),
                  ),
                  _buildInfoRow(
                    AppLocalization.tr('phone'),
                    _userProfile?['phone'] as String? ?? AppLocalization.tr('not_set'),
                  ),
                  _buildInfoRow(
                    AppLocalization.tr('address'),
                    _userProfile?['address'] as String? ?? AppLocalization.tr('not_set'),
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
                    Icons.palette_outlined,
                    AppLocalization.tr('theme_mode'),
                    _showThemeModePicker,
                    subtitle: _themeModeLabel(themeMode),
                  ),
                  _buildMenuTile(
                    context,
                    Icons.language,
                    AppLocalization.tr('language'),
                    _showLanguagePicker,
                    subtitle: AppLocalization.languageLabel(AppLocalization.notifier.value),
                  ),
                  _buildMenuTile(
                    context,
                    Icons.edit,
                    AppLocalization.tr('edit_profile'),
                    _handleEditProfile,
                  ),
                  _buildMenuTile(
                    context,
                    Icons.lock,
                    AppLocalization.tr('change_password'),
                    _handleChangePassword,
                  ),
                  _buildMenuTile(
                    context,
                    Icons.history,
                    AppLocalization.tr('borrow_history'),
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalization.tr('check_borrows_hint'))),
                      );
                    },
                  ),
                  _buildMenuTile(
                    context,
                    Icons.logout,
                    AppLocalization.tr('logout'),
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
    String? subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
