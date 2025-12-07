import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:library_management/data/services/auth_service.dart';
import 'package:library_management/utils/error_localization.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _resetEmailController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSendingReset = false;
  bool _obscurePassword = true;
  final _authService = AuthService();

  bool get _isBusy => _isLoading || _isSendingReset;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _resetEmailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        if (!mounted) return;
        context.go('/home');
      } else {
        throw Exception('登录失败：未收到用户信息');
      }
    } catch (e) {
      if (!mounted) return;
      
      final errorMessage = ErrorLocalization.getLocalizedErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登录失败: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final dialogFormKey = GlobalKey<FormState>();
    _resetEmailController.text = _emailController.text.trim();

    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('找回密码'),
        content: Form(
          key: dialogFormKey,
          child: TextFormField(
            controller: _resetEmailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '邮箱',
              hintText: '请输入注册邮箱',
            ),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (dialogFormKey.currentState?.validate() ?? false) {
                Navigator.pop(context, _resetEmailController.text.trim());
              }
            },
            child: const Text('发送重置邮件'),
          ),
        ],
      ),
    );

    if (email == null || !mounted) return;

    setState(() => _isSendingReset = true);
    try {
      await _authService.resetPassword(email);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已发送重置密码邮件，请查收邮箱')),
      );
    } catch (e) {
      if (!mounted) return;

      final errorMessage = ErrorLocalization.getLocalizedErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('发送失败: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingReset = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(
                Icons.library_books,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),
              Text(
                '欢迎来到图书馆',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '请登录以继续',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: '邮箱',
                        prefixIcon: Icon(Icons.email),
                        hintText: '请输入邮箱',
                      ),
                      enabled: !_isBusy,
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
                        labelText: '密码',
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
                        hintText: '请输入密码',
                      ),
                      enabled: !_isBusy,
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
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isBusy ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('登录'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isBusy ? null : _handleForgotPassword,
                child: _isSendingReset
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('忘记密码？'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '还没有账号？',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: _isBusy
                        ? null
                        : () => context.go('/register'),
                    child: const Text('去注册'),
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
