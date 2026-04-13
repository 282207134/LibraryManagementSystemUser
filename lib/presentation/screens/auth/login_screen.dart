import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:library_management/data/services/auth_service.dart';
import 'package:library_management/localization/app_localization.dart';
import 'package:library_management/presentation/widgets/language_switch_button.dart';
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
        title: Text(AppLocalization.tr('forgot_password')),
        content: Form(
          key: dialogFormKey,
          child: TextFormField(
            controller: _resetEmailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppLocalization.tr('email'),
              hintText: AppLocalization.tr('search_book_author'),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalization.tr('email');
              }
              if (!value.contains('@')) {
                return AppLocalization.tr('email');
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalization.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (dialogFormKey.currentState?.validate() ?? false) {
                Navigator.pop(context, _resetEmailController.text.trim());
              }
            },
            child: Text(AppLocalization.tr('save')),
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
        SnackBar(content: Text(AppLocalization.tr('forgot_password'))),
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
        title: Text(AppLocalization.tr('login')),
        elevation: 0,
        actions: const [LanguageSwitchButton()],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Image.asset(
                'assets/logos/app_logo.png',
                height: 92,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              Text(
                AppLocalization.tr('welcome_library'),
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalization.tr('login_continue'),
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
                      decoration: InputDecoration(
                        labelText: AppLocalization.tr('email'),
                        prefixIcon: const Icon(Icons.email),
                        hintText: AppLocalization.tr('email'),
                      ),
                      enabled: !_isBusy,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalization.tr('email');
                        }
                        if (!value.contains('@')) {
                          return AppLocalization.tr('email');
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
                      enabled: !_isBusy,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalization.tr('password');
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
                    : Text(AppLocalization.tr('login')),
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
                    : Text(AppLocalization.tr('forgot_password')),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalization.tr('no_account'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: _isBusy
                        ? null
                        : () => context.go('/register'),
                    child: Text(AppLocalization.tr('go_register')),
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
