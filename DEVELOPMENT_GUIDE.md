# Flutter 图书馆管理系统 - 开发指南

## 目录

1. [项目设置](#项目设置)
2. [开发环境](#开发环境)
3. [项目结构](#项目结构)
4. [代码规范](#代码规范)
5. [开发工作流](#开发工作流)
6. [常见任务](#常见任务)
7. [调试和测试](#调试和测试)
8. [性能优化](#性能优化)

## 项目设置

### 克隆项目

```bash
git clone <repository-url>
cd library_management
```

### 安装依赖

```bash
flutter clean
flutter pub get
```

### 生成生成的文件

```bash
# 一次性构建
flutter pub run build_runner build

# 观看模式
flutter pub run build_runner watch

# 清除生成的文件
flutter pub run build_runner clean
```

## 开发环境

### 系统要求

- **OS**: macOS, Windows, Linux, Chrome OS
- **Flutter SDK**: 3.0.0 及以上
- **Dart SDK**: 3.0 及以上
- **IDE**: VS Code, Android Studio, 或 IntelliJ IDEA

### 推荐的 IDE 插件

- **VS Code**:
  - Flutter
  - Dart
  - Awesome Flutter Snippets
  - Dart Data Class Generator

- **Android Studio/IntelliJ**:
  - Flutter
  - Dart
  - Material Theme UI

### 运行应用

#### 在模拟器上运行

```bash
# 启动 iOS 模拟器
flutter run -d "iPhone 15"

# 启动 Android 模拟器
flutter run -d emulator
```

#### 在真机上运行

```bash
# 连接设备后列出可用设备
flutter devices

# 在特定设备上运行
flutter run -d <device-id>
```

#### 发布模式运行

```bash
flutter run --release
```

## 项目结构

### 基本结构

```
lib/
├── main.dart                          # 应用入口
├── config/                            # 应用配置
│   ├── app_config.dart               # 基础配置
│   ├── router_config.dart            # 路由配置
│   └── theme_config.dart             # 主题配置
├── data/                             # 数据层（数据源、仓储）
│   ├── models/                       # 数据模型
│   ├── network/                      # 网络层
│   └── services/                     # 业务服务
├── presentation/                     # 表现层（UI）
│   ├── screens/                      # 屏幕/页面
│   ├── widgets/                      # 可复用组件
│   └── providers/                    # Riverpod 提供者
└── utils/                            # 工具类
    ├── extensions/                   # 扩展方法
    ├── constants/                    # 常量
    └── helpers/                      # 辅助方法
```

### 文件命名规范

- **文件名**: 使用蛇形命名法 `file_name.dart`
- **类名**: 使用帕斯卡命名法 `ClassName`
- **常量**: 使用驼峰命名法 `const String appName = 'App';`
- **变量**: 使用驼峰命名法 `var userName = 'John';`

## 代码规范

### 1. 代码风格

遵循 Effective Dart 风格指南：

```dart
// ✅ 好的命名
class UserProfile extends StatelessWidget {
  final String userId;
  final int pageNumber;
  
  const UserProfile({
    required this.userId,
    required this.pageNumber,
  });

  @override
  Widget build(BuildContext context) {
    // 实现
  }
}

// ❌ 不好的命名
class UP extends StatelessWidget {
  final String uid;
  final int page;
  // ...
}
```

### 2. 使用 const 构造函数

```dart
// ✅ 好的做法
const SizedBox(height: 16),

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Hello'));
  }
}

// ❌ 不好的做法
SizedBox(height: 16),

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Hello'));
  }
}
```

### 3. 空安全性

```dart
// ✅ 正确的空安全处理
String? getUserName() => null;
final userName = getUserName() ?? 'Unknown';

String getDisplayName(String? name) {
  return name?.isEmpty ?? true ? 'Guest' : name!;
}

// ❌ 避免强制解包
final userName = getUserName()!;  // 危险！
```

### 4. 异常处理

```dart
// ✅ 正确的异常处理
try {
  final result = await apiService.fetchBooks();
  setState(() => books = result);
} on ApiException catch (e) {
  _showErrorDialog(e.message);
} catch (e) {
  _showErrorDialog('Unexpected error occurred');
}

// ❌ 避免吞掉异常
try {
  final result = await apiService.fetchBooks();
} catch (e) {
  // 不做任何事
}
```

### 5. 文档注释

```dart
/// 获取用户信息
/// 
/// 从服务器获取指定用户的详细信息
/// 
/// 参数:
/// - [userId]: 用户 ID
/// 
/// 返回:
/// - Future<User>: 包含用户信息的 Future
/// 
/// 异常:
/// - ApiException: 如果 API 请求失败
Future<User> getUser(String userId) async {
  // 实现
}
```

## 开发工作流

### 1. 创建新的屏幕

```dart
// lib/presentation/screens/new_feature/new_feature_screen.dart

import 'package:flutter/material.dart';

class NewFeatureScreen extends StatefulWidget {
  const NewFeatureScreen({Key? key}) : super(key: key);

  @override
  State<NewFeatureScreen> createState() => _NewFeatureScreenState();
}

class _NewFeatureScreenState extends State<NewFeatureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Feature'),
      ),
      body: Center(
        child: Text('Content goes here'),
      ),
    );
  }
}
```

### 2. 添加新的数据模型

```dart
// lib/data/models/my_model.dart

import 'package:json_serializable/json_serializable.dart';

part 'my_model.g.dart';

@JsonSerializable()
class MyModel {
  final String id;
  final String name;
  final String? description;

  MyModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory MyModel.fromJson(Map<String, dynamic> json) =>
      _$MyModelFromJson(json);

  Map<String, dynamic> toJson() => _$MyModelToJson(this);
}
```

然后运行代码生成：

```bash
flutter pub run build_runner build
```

### 3. 添加 API 端点

在 `lib/data/services/api_service.dart` 中添加新方法：

```dart
Future<ApiResponse<List<MyModel>>> getMyModels() async {
  try {
    final response = await _dio.get('/api/my-models');
    return ApiResponse.fromJson(
      response.data,
      (json) => (json as List)
          .map((e) => MyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  } on DioException catch (e) {
    throw ApiException(
      code: e.response?.statusCode,
      message: e.message ?? 'Failed to fetch models',
      originalError: e,
    );
  }
}
```

### 4. 添加 Riverpod Provider

```dart
// lib/presentation/providers/my_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_management/data/services/api_service.dart';
import 'package:library_management/data/models/my_model.dart';

final myModelProvider = FutureProvider<List<MyModel>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.getMyModels();
  if (response.isSuccess && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.message);
  }
});
```

### 5. 在界面中使用 Provider

```dart
class MyWidget extends ConsumerWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myModelsAsync = ref.watch(myModelProvider);

    return myModelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (models) => ListView.builder(
        itemCount: models.length,
        itemBuilder: (context, index) {
          final model = models[index];
          return ListTile(title: Text(model.name));
        },
      ),
    );
  }
}
```

## 常见任务

### 添加新的页面

1. 在 `lib/presentation/screens/` 中创建文件夹
2. 创建新的屏幕类
3. 在 `lib/config/router_config.dart` 中添加路由
4. 从其他屏幕导航到新屏幕

### 更改应用主题

编辑 `lib/config/theme_config.dart` 中的 `AppColors` 类或 `ThemeConfig` 的 `lightTheme` 和 `darkTheme`。

### 添加本地化

1. 安装 `intl` 包
2. 在 `pubspec.yaml` 中配置
3. 创建翻译文件
4. 在应用中使用 `MaterialApp.localizationsDelegates`

### 配置推送通知

1. 安装 `firebase_messaging` 包
2. 配置 Firebase 项目
3. 实现消息处理
4. 集成到应用中

## 调试和测试

### 调试技巧

#### 启用详细日志

```dart
// 在 main() 中
void main() {
  // 启用 Riverpod 日志
  _riverpodLogger();
  
  // 启用 HTTP 日志
  HttpClient().dio.interceptors.add(_LoggingInterceptor());
  
  runApp(const ProviderScope(child: MyApp()));
}

void _riverpodLogger() {
  // 使用 riverpod_logger 包
}
```

#### 使用 Flutter DevTools

```bash
flutter pub global activate devtools
devtools
```

### 单元测试

创建 `test/` 目录中的测试文件：

```dart
// test/data/models/user_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:library_management/data/models/user_model.dart';

void main() {
  group('User Model', () {
    test('should create User from JSON', () {
      final json = {
        'id': '1',
        'username': 'testuser',
        'email': 'test@example.com',
        'role': 'user',
        'borrowLimit': 5,
        'currentBorrowCount': 0,
        'status': 'active',
        'createdAt': '2024-01-01T00:00:00Z',
      };

      final user = User.fromJson(json);

      expect(user.id, '1');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
    });
  });
}
```

运行测试：

```bash
flutter test
flutter test test/data/models/user_model_test.dart
```

### Widget 测试

```dart
// test/presentation/screens/login_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_management/presentation/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen has username and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );

    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
  });
}
```

## 性能优化

### 1. 使用 const 构造函数

```dart
// 减少不必要的重建
const Text('Hello'), // ✅ 推荐
Text('Hello'),       // ❌ 避免
```

### 2. 优化列表性能

```dart
// 使用 ListView.builder 而不是 ListView
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemTile(item: items[index]),
)
```

### 3. 缓存数据

```dart
// 使用 Hive 或 SharedPreferences 缓存
final cachedData = await Hive.box<String>('cache').get('key');
```

### 4. 分页加载

```dart
// 不要一次加载所有数据
Future<List<Book>> getBooks({
  int page = 1,
  int pageSize = 20,
}) => apiService.getBooks(page: page, pageSize: pageSize);
```

### 5. 图片优化

```dart
// 使用缓存的网络图片
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => const Shimmer(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

## 常见问题

### Q: 如何处理 API 错误？

A: 使用 try-catch 和异常类：

```dart
try {
  final data = await apiService.fetchBooks();
} on ApiException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message)),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Unexpected error')),
  );
}
```

### Q: 如何实现下拉刷新？

A: 使用 `RefreshIndicator`：

```dart
RefreshIndicator(
  onRefresh: () async {
    // 刷新逻辑
    await Future.delayed(const Duration(seconds: 2));
  },
  child: ListView(
    children: items,
  ),
)
```

### Q: 如何存储敏感信息？

A: 使用 `flutter_secure_storage`：

```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'token', value: token);
final token = await storage.read(key: 'token');
```

---

**更新于**: 2024年
**最后更新者**: 开发团队
