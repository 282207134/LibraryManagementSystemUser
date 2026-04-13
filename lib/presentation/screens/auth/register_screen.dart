import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:library_management/data/services/auth_service.dart';
import 'package:library_management/localization/app_localization.dart';
import 'package:library_management/presentation/widgets/language_switch_button.dart';
import 'package:library_management/utils/error_localization.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密码不匹配')),
        );
      }
      return;
    }

    if (!_agreeToTerms) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请同意服务条款')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 注册用户
      final response = await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'name': _usernameController.text.trim(),
        },
      );

      // 如果用户创建成功，尝试创建用户资料
      if (response.user != null) {
        try {
          // 创建用户资料（即使失败也不影响注册流程）
          await _authService.upsertUserProfile({
            'id': response.user!.id,
            'email': _emailController.text.trim(),
            'full_name': _usernameController.text.trim(),
            'role': 'user',
          });
        } catch (profileError) {
          // 用户资料创建失败不影响注册，只在控制台记录
          debugPrint('注册时创建用户信息失败: $profileError');
        }

        if (!mounted) return;
        
        // 检查用户是否已经自动登录（邮件确认被禁用时）
        final session = _authService.currentSession;
        if (session != null) {
          // 用户已自动登录（邮件确认被禁用的情况）
          // 但仍然提示用户，因为通常应该启用邮件验证
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('注册成功！已自动登录。'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // 清空表单
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          if (mounted) {
            setState(() => _agreeToTerms = false);
          }
          
          // 跳转到主页
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            context.go('/home');
          }
        } else {
          // 需要邮件验证，提示用户检查邮箱
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('注册成功！请检查邮箱以验证您的账户，验证后即可登录。'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 6),
            ),
          );
          
          // 清空表单
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          if (mounted) {
            setState(() => _agreeToTerms = false);
          }
          
          // 延迟后跳转到登录页面
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            context.go('/login');
          }
        }
      } else {
        throw Exception('注册失败：未收到用户信息');
      }
    } catch (e) {
      if (!mounted) return;
      
      final errorMessage = ErrorLocalization.getLocalizedErrorMessage(e);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('注册失败: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalization.tr('register')),
        elevation: 0,
        actions: const [LanguageSwitchButton()],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                AppLocalization.tr('create_account'),
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalization.tr('register_start'),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: AppLocalization.tr('username'),
                        prefixIcon: const Icon(Icons.person),
                        hintText: AppLocalization.tr('username'),
                      ),
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入用户名';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: AppLocalization.tr('email'),
                        prefixIcon: const Icon(Icons.email),
                        hintText: AppLocalization.tr('email'),
                      ),
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入邮箱';
                        }
                        if (!value.contains('@')) {
                          return '请输入有效的邮箱地址';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: AppLocalization.tr('password'),
                        prefixIcon: const Icon(Icons.lock),
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
                        hintText: AppLocalization.tr('password'),
                      ),
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入密码';
                        }
                        if (value.length < 6) {
                          return '密码至少需要6个字符';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: AppLocalization.tr('confirm_password'),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword,
                            );
                          },
                        ),
                        hintText: AppLocalization.tr('confirm_password'),
                      ),
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请确认密码';
                        }
                        if (value != _passwordController.text) {
                          return '密码不匹配';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() => _agreeToTerms = value ?? false);
                          },
                  ),
                  Expanded(
                    child: Text(
                      '我已阅读并同意服务条款',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(AppLocalization.tr('register')),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalization.tr('no_account'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => context.go('/login'),
                    child: Text(AppLocalization.tr('go_login')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
