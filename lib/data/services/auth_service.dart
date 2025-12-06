import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:library_management/config/app_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient get _supabase => AppConfig.supabase;

  // 获取当前用户
  User? get currentUser => _supabase.auth.currentUser;

  // 获取当前会话
  Session? get currentSession => _supabase.auth.currentSession;

  // 监听认证状态变化
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // 使用邮箱和密码登录
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 使用邮箱和密码注册
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  // 登出
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // 获取用户资料（从 users 表）
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('users')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();

    return response;
  }

  // 创建或更新用户资料
  Future<void> upsertUserProfile(Map<String, dynamic> profile) async {
    await _supabase.from('users').upsert(profile);
  }

  // 发送找回密码邮件
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // 检查是否已登录
  bool get isAuthenticated => currentUser != null;
}
