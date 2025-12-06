# Flutter 图书馆管理系统 - 实现指南

## 概述

本指南提供了如何在现有 Flutter 项目框架基础上完成剩余功能实现的详细说明。该项目已经完成了基础架构和 UI 框架的搭建，现在需要实现具体的业务逻辑和数据交互。

## 目录

1. [已完成的部分](#已完成的部分)
2. [待实现的功能](#待实现的功能)
3. [实现路径](#实现路径)
4. [集成 API](#集成-api)
5. [状态管理](#状态管理)
6. [本地存储](#本地存储)
7. [测试](#测试)

## 已完成的部分

### 架构层面

- ✅ 应用基础配置（AppConfig）
- ✅ 路由配置（GoRouter）
- ✅ 主题配置（Material Design 主题）
- ✅ HTTP 客户端（Dio + 拦截器）
- ✅ 错误处理机制（ApiException）

### 数据层面

- ✅ 数据模型类
  - User（用户）
  - Book（图书）
  - BorrowRecord（借阅记录）
  - Category（分类）
  - Notification（通知）
  - ApiResponse（API 响应包装）
  
- ✅ API 服务类（ApiService）
  - 用户认证接口
  - 用户信息接口
  - 图书相关接口
  - 借阅管理接口
  - 通知接口

### 界面层面

- ✅ 启动屏幕（SplashScreen）
- ✅ 登录屏幕（LoginScreen）
- ✅ 注册屏幕（RegisterScreen）
- ✅ 主页面框架（HomeScreen）
- ✅ 首页（HomePage）
- ✅ 图书浏览页（BooksPage）
- ✅ 借阅管理页（BorrowsPage）
- ✅ 消息页（MessagesPage）
- ✅ 个人中心页（ProfilePage）

### 工具层面

- ✅ 常量定义（AppConstants、ErrorMessages、SuccessMessages）
- ✅ 数据验证（Validators）
- ✅ 字符串扩展（StringValidation）

## 待实现的功能

### 1. 用户认证功能

**位置**: `lib/presentation/screens/auth/`

**任务**:
- [ ] 实现登录业务逻辑
  - 调用 ApiService.login()
  - 存储返回的 token 和用户信息
  - 处理登录错误
  - 自动导航到首页

- [ ] 实现注册业务逻辑
  - 调用 ApiService.register()
  - 验证所有输入字段
  - 处理注册错误
  - 成功后导航到登录页

- [ ] 实现自动登录
  - 启动屏检查本地存储的 token
  - 验证 token 是否有效
  - 自动跳转或导航到登录页

**代码示例**:
```dart
Future<void> _handleLogin() async {
  // 验证输入
  if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
    _showError('Please fill in all fields');
    return;
  }

  setState(() => _isLoading = true);
  try {
    // 调用 API
    final response = await ApiService().login(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (response.isSuccess && response.data != null) {
      // 保存 token
      final token = response.data!['token'];
      await _saveToken(token);

      // 导航到首页
      if (mounted) context.go('/home');
    } else {
      _showError(response.message);
    }
  } on ApiException catch (e) {
    _showError(e.message);
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

### 2. 本地数据存储

**位置**: `lib/data/repositories/` 或 `lib/utils/storage/`

**任务**:
- [ ] 创建 Token 管理器
  - 存储访问令牌
  - 存储刷新令牌
  - 处理令牌刷新
  - 清除过期令牌

- [ ] 创建用户信息缓存
  - 缓存当前用户信息
  - 更新缓存数据
  - 清除用户数据

- [ ] 创建应用偏好设置
  - 主题偏好（亮/暗）
  - 语言偏好
  - 其他用户偏好

**代码示例**:
```dart
// lib/utils/storage/token_storage.dart
class TokenStorage {
  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveToken(String token) async {
    final box = Hive.box<String>('tokens');
    await box.put(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final box = Hive.box<String>('tokens');
    return box.get(_tokenKey);
  }

  Future<void> clearToken() async {
    final box = Hive.box<String>('tokens');
    await box.delete(_tokenKey);
    await box.delete(_refreshTokenKey);
  }
}
```

### 3. 状态管理

**位置**: `lib/presentation/providers/`

**任务**:
- [ ] 创建认证提供者
  ```dart
  final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
    return AuthNotifier();
  });
  ```

- [ ] 创建用户信息提供者
  ```dart
  final userProvider = FutureProvider<User>((ref) async {
    return ApiService().getUserProfile();
  });
  ```

- [ ] 创建图书列表提供者
  ```dart
  final booksProvider = FutureProvider.family<List<Book>, int>((ref, page) async {
    return ApiService().getBooks(page: page);
  });
  ```

- [ ] 创建借阅管理提供者
  ```dart
  final currentBorrowsProvider = FutureProvider<List<BorrowRecord>>((ref) async {
    return ApiService().getCurrentBorrows();
  });
  ```

### 4. 图书浏览功能

**位置**: `lib/presentation/screens/home/pages/books_page.dart`

**任务**:
- [ ] 实现分页加载
  - 初始加载第一页
  - 下拉刷新重置页数
  - 上拉加载下一页

- [ ] 实现搜索功能
  - 搜索输入防抖
  - 调用搜索 API
  - 显示搜索结果

- [ ] 实现图书详情页面
  - 创建 BookDetailScreen
  - 显示完整的图书信息
  - 实现借阅按钮

**代码示例**:
```dart
class BooksPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = useState(1);
    final searchQuery = useState('');
    final booksAsync = ref.watch(
      searchQuery.value.isEmpty
          ? booksProvider(page.value)
          : searchBooksProvider(searchQuery.value),
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          page.value = 1;
          ref.refresh(booksProvider(1));
        },
        child: booksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error: $err')),
          data: (books) => ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) => BookTile(book: books[index]),
          ),
        ),
      ),
    );
  }
}
```

### 5. 借阅管理功能

**位置**: `lib/presentation/screens/home/pages/borrows_page.dart`

**任务**:
- [ ] 实现当前借阅页签
  - 加载当前借阅列表
  - 显示借阅信息和到期日期
  - 实现续借功能
  - 实现归还功能

- [ ] 实现借阅历史页签
  - 加载借阅历史
  - 分页显示历史记录
  - 显示已归还和逾期状态

- [ ] 实现借阅/续借/归还 API 调用
  - 处理成功响应
  - 处理错误情况
  - 更新本地状态

### 6. 个人中心功能

**位置**: `lib/presentation/screens/home/pages/profile_page.dart`

**任务**:
- [ ] 加载用户信息
  - 从 API 获取最新用户信息
  - 显示用户头像
  - 显示借阅统计

- [ ] 实现编辑个人信息
  - 创建编辑个人信息屏幕
  - 调用更新 API
  - 更新本地缓存

- [ ] 实现修改密码
  - 创建修改密码对话框
  - 验证旧密码
  - 验证新密码强度

- [ ] 实现退出登录
  - 清除本地 token
  - 清除用户缓存
  - 导航到登录页

### 7. 通知功能

**位置**: `lib/presentation/screens/home/pages/messages_page.dart`

**任务**:
- [ ] 加载通知列表
  - 获取用户通知
  - 分页显示
  - 按类型筛选

- [ ] 标记通知已读
  - 点击通知时标记已读
  - 更新 UI
  - 调用 API

- [ ] 实现通知详情
  - 创建通知详情屏幕
  - 显示完整通知内容
  - 处理通知操作

## 实现路径

### 第 1 阶段：完成认证流程 (1-2 天)

1. 完成 TokenStorage 类
2. 实现 LoginScreen 的登录逻辑
3. 实现 RegisterScreen 的注册逻辑
4. 实现 SplashScreen 的自动登录检查
5. 添加路由保护（未登录用户不能访问受保护页面）

**关键文件**:
- `lib/utils/storage/token_storage.dart` (新建)
- `lib/presentation/screens/auth/login_screen.dart` (修改)
- `lib/presentation/screens/auth/register_screen.dart` (修改)
- `lib/presentation/screens/splash/splash_screen.dart` (修改)
- `lib/config/router_config.dart` (修改)

### 第 2 阶段：实现状态管理 (1-2 天)

1. 创建 AuthNotifier 和 AuthState
2. 创建各个功能的 Riverpod Provider
3. 集成状态管理到屏幕中
4. 处理加载和错误状态

**关键文件**:
- `lib/presentation/providers/auth_provider.dart` (新建)
- `lib/presentation/providers/user_provider.dart` (新建)
- `lib/presentation/providers/book_provider.dart` (新建)
- `lib/presentation/providers/borrow_provider.dart` (新建)
- `lib/presentation/providers/notification_provider.dart` (新建)

### 第 3 阶段：完成主要功能屏幕 (2-3 天)

1. 实现 BooksPage 完整功能
2. 实现 BorrowsPage 完整功能
3. 实现 ProfilePage 完整功能
4. 实现 MessagesPage 完整功能
5. 创建详情屏幕（图书详情、通知详情等）

### 第 4 阶段：添加高级功能 (1-2 天)

1. 实现下拉刷新和上拉加载
2. 实现搜索功能
3. 实现图片缓存
4. 实现骨架屏加载效果
5. 实现错误重试机制

### 第 5 阶段：测试和优化 (1-2 天)

1. 编写单元测试
2. 编写 Widget 测试
3. 性能优化
4. Bug 修复

## 集成 API

### 设置 API 基础 URL

```dart
// lib/config/app_config.dart
class AppConfig {
  // 根据需要修改
  static const String apiBaseUrl = 'https://api.library.com';
  static const String devApiUrl = 'http://dev-api.library.com';
  static const String testApiUrl = 'http://test-api.library.com';
}
```

### 设置请求拦截器

```dart
// lib/data/network/http_client.dart
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 获取并添加 token
    final token = TokenStorage().getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

### 处理 401 响应

```dart
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // 清除 token，导航到登录页
      TokenStorage().clearToken();
      // TODO: 导航到登录页
    }
    handler.next(err);
  }
}
```

## 状态管理

### 创建状态类

```dart
// lib/presentation/providers/auth_provider.dart

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isLoggedIn;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isLoggedIn = false,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  final apiService = ApiService();

  AuthNotifier() : super(const AuthState());

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await apiService.login(
        username: username,
        password: password,
      );
      if (response.isSuccess && response.data != null) {
        // 保存 token
        final token = response.data!['token'];
        // 保存用户信息
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
```

## 本地存储

### 使用 Hive 存储数据

```dart
// 打开 box
final userBox = Hive.box<User>('users');

// 存储数据
await userBox.put('currentUser', user);

// 读取数据
final user = userBox.get('currentUser');

// 删除数据
await userBox.delete('currentUser');

// 清空 box
await userBox.clear();
```

### 使用 SharedPreferences

```dart
// 存储简单数据
final prefs = await SharedPreferences.getInstance();
await prefs.setString('theme', 'dark');
await prefs.setInt('page_size', 20);

// 读取数据
final theme = prefs.getString('theme');
final pageSize = prefs.getInt('page_size');
```

## 测试

### 单元测试示例

```dart
// test/data/services/api_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:library_management/data/services/api_service.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('login should return response', () async {
      // TODO: Mock Dio
      // final response = await apiService.login(
      //   username: 'testuser',
      //   password: 'password123',
      // );
      // expect(response.isSuccess, true);
    });
  });
}
```

### Widget 测试示例

```dart
// test/presentation/screens/login_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('should display login form', (WidgetTester tester) async {
      // await tester.pumpWidget(
      //   const MaterialApp(home: LoginScreen()),
      // );
      // expect(find.byType(TextField), findsWidgets);
      // expect(find.text('Login'), findsOneWidget);
    });
  });
}
```

## 下一步

1. 确认 API 服务器地址和相关接口
2. 按照实现路径逐步完成各个阶段
3. 定期测试和调试
4. 根据用户反馈进行优化

---

**创建于**: 2024年
**最后更新**: 2024年
