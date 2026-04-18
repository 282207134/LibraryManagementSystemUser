# 图书馆管理系统 - 项目架构文档

## 📋 目录
- [项目概述](#项目概述)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [架构设计](#架构设计)
- [核心模块](#核心模块)
- [数据流](#数据流)
- [设计模式](#设计模式)

---

## 项目概述

**Library Management System** 是一个基于 Flutter 开发的跨平台图书馆管理移动应用,支持 iOS 和 Android 平台。该系统为用户提供图书浏览、借阅管理、收藏、消息通知等功能,同时提供管理员界面进行图书和用户管理。

### 核心功能
- 👤 **用户认证**: 注册、登录、邮箱验证、密码重置
- 📚 **图书浏览**: 分类浏览、搜索、详情查看、评分评论
- 📖 **借阅管理**: 借书、还书、续借、逾期提醒
- ⭐ **收藏系统**: 收藏喜欢的图书
- 🔔 **消息通知**: 借阅提醒、系统通知
- 👨‍💼 **管理后台**: 图书管理、用户管理、借阅统计

---

## 技术栈

### 核心框架
- **Flutter**: ^3.0.0 - 跨平台UI框架
- **Dart**: >=3.0.0 <4.0.0 - 编程语言

### 状态管理
- **Riverpod**: ^2.4.0 - 响应式状态管理
- **Provider**: ^6.0.0 - 依赖注入

### 后端服务
- **Supabase**: ^2.0.0 - Backend as a Service
  - 身份认证 (Auth)
  - 数据库 (PostgreSQL)
  - 存储 (Storage)
  - 实时订阅 (Realtime)

### 网络请求
- **Dio**: ^5.3.0 - HTTP客户端
- **Retrofit**: ^4.0.0 - REST API代码生成

### 本地存储
- **Hive**: ^2.2.0 - 轻量级NoSQL数据库
- **Shared Preferences**: ^2.2.0 - 键值对存储
- **Flutter Secure Storage**: ^9.0.0 - 安全存储(令牌等敏感信息)

### 路由管理
- **Go Router**: ^11.0.0 - 声明式路由

### UI组件
- **Cached Network Image**: ^3.3.0 - 图片缓存
- **Pull to Refresh**: ^2.0.0 - 下拉刷新
- **Shimmer**: ^3.0.0 - 加载动画
- **Image Picker**: ^1.1.2 - 图片选择

### 工具库
- **JSON Annotation**: ^4.9.0 - JSON序列化注解
- **Intl**: ^0.19.0 - 国际化支持

---

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── config/                      # 配置层
│   ├── app_config.dart          # 应用配置(Supabase、API地址等)
│   ├── router_config.dart       # 路由配置
│   └── theme_config.dart        # 主题配置(浅色/深色主题)
├── data/                        # 数据层
│   ├── models/                  # 数据模型
│   │   ├── api_response.dart    # API响应模型
│   │   ├── book_model.dart      # 图书模型
│   │   ├── user_model.dart      # 用户模型
│   │   ├── borrow_record_model.dart  # 借阅记录模型
│   │   ├── category_model.dart  # 分类模型
│   │   ├── notification_model.dart   # 通知模型
│   │   └── review_model.dart    # 评论模型
│   ├── network/                 # 网络层
│   │   └── http_client.dart     # HTTP客户端(Dio封装)
│   └── services/                # 服务层
│       ├── api_service.dart     # API服务
│       ├── auth_service.dart    # 认证服务
│       ├── book_service.dart    # 图书服务
│       ├── borrowing_service.dart    # 借阅服务
│       ├── home_service.dart    # 首页服务
│       └── review_service.dart  # 评论服务
├── presentation/                # 表示层(UI)
│   ├── screens/                 # 页面
│   │   ├── auth/                # 认证相关页面
│   │   │   ├── login_screen.dart       # 登录页
│   │   │   └── register_screen.dart    # 注册页
│   │   ├── book/                # 图书相关页面
│   │   │   └── book_detail_screen.dart # 图书详情页
│   │   ├── home/                # 主页
│   │   │   ├── home_screen.dart        # 主容器页
│   │   │   └── pages/                  # 子页面
│   │   │       ├── home_page.dart      # 首页
│   │   │       ├── books_page.dart     # 图书列表页
│   │   │       ├── borrows_page.dart   # 借阅记录页
│   │   │       ├── favorites_page.dart # 收藏页
│   │   │       ├── messages_page.dart  # 消息页
│   │   │       ├── profile_page.dart   # 个人中心页
│   │   │       └── admin_page.dart     # 管理后台页
│   │   └── splash/              # 启动页
│   │       └── splash_screen.dart        # 启动屏
│   └── widgets/                 # 可复用组件
│       ├── star_rating.dart            # 星级评分组件
│       └── language_switch_button.dart # 语言切换按钮
├── providers/                   # 状态管理层
│   └── theme_mode_provider.dart # 主题模式提供者
├── localization/                # 国际化
│   └── app_localization.dart    # 多语言支持(中文/英文/日文)
└── utils/                       # 工具类
    ├── constants.dart           # 常量定义
    ├── validators.dart          # 表单验证器
    ├── image_helper.dart        # 图片处理辅助
    └── error_localization.dart  # 错误消息本地化
```

---

## 架构设计

### 分层架构 (Layered Architecture)

本项目采用经典的**三层架构**模式,清晰分离关注点:

```
┌─────────────────────────────────────┐
│     Presentation Layer (表示层)      │
│  - Screens (页面)                    │
│  - Widgets (组件)                    │
│  - Providers (状态管理)              │
└──────────────┬──────────────────────┘
               │ 调用
┌──────────────▼──────────────────────┐
│       Data Layer (数据层)            │
│  - Services (业务逻辑)               │
│  - Models (数据模型)                 │
│  - Network (网络请求)                │
└──────────────┬──────────────────────┘
               │ 访问
┌──────────────▼──────────────────────┐
│      External Services (外部服务)    │
│  - Supabase (后端服务)               │
│  - Local Storage (本地存储)          │
└─────────────────────────────────────┘
```

### 各层职责

#### 1. Presentation Layer (表示层)
- **职责**: 负责UI展示和用户交互
- **包含**:
  - `screens/`: 完整的页面组件
  - `widgets/`: 可复用的UI小组件
  - `providers/`: Riverpod状态管理
- **特点**: 
  - 无业务逻辑
  - 通过Provider监听状态变化
  - 调用Service层执行业务操作

#### 2. Data Layer (数据层)
- **职责**: 处理数据获取、缓存和业务逻辑
- **包含**:
  - `models/`: 数据模型定义,负责JSON序列化/反序列化
  - `services/`: 业务逻辑封装,调用Supabase或本地存储
  - `network/`: HTTP客户端封装
- **特点**:
  - 独立于UI层
  - 可单独测试
  - 处理数据转换和错误处理

#### 3. Config & Utils (配置和工具层)
- **职责**: 提供全局配置和通用工具
- **包含**:
  - `config/`: 应用配置、路由、主题
  - `utils/`: 验证器、常量、辅助函数
  - `localization/`: 多语言支持

---

## 核心模块

### 1. 认证模块 (Authentication)

**文件**: `data/services/auth_service.dart`

**功能**:
- 用户注册 (邮箱+密码)
- 用户登录
- 邮箱验证
- 密码重置
- 会话管理

**流程**:
```
用户输入 → 表单验证 → AuthService → Supabase Auth → 保存Token → 跳转主页
```

### 2. 图书模块 (Book Management)

**文件**: 
- `data/models/book_model.dart`
- `data/services/book_service.dart`
- `presentation/screens/book/book_detail_screen.dart`

**功能**:
- 图书列表查询(支持分页、搜索、筛选)
- 图书详情查看
- 图书分类浏览
- 封面图片管理(Supabase Storage)

**数据流**:
```
BookService → Supabase Database → Book Model → UI展示
```

### 3. 借阅模块 (Borrowing System)

**文件**:
- `data/models/borrow_record_model.dart`
- `data/services/borrowing_service.dart`
- `presentation/screens/home/pages/borrows_page.dart`

**功能**:
- 借阅图书
- 归还图书
- 续借(最多3次)
- 逾期罚款计算
- 借阅历史记录

**业务规则**:
- 最大借阅数量: 5本
- 默认借阅天数: 30天
- 最大续借次数: 3次
- 逾期罚款: 1元/天

### 4. 评论评分模块 (Review & Rating)

**文件**:
- `data/models/review_model.dart`
- `data/services/review_service.dart`
- `presentation/widgets/star_rating.dart`

**功能**:
- 用户对图书评分(1-5星)
- 撰写评论
- 查看图书平均评分
- 评分分布统计

### 5. 通知模块 (Notifications)

**文件**: `data/models/notification_model.dart`

**功能**:
- 借阅到期提醒
- 逾期通知
- 图书可借通知
- 系统公告

### 6. 主题与国际化 (Theme & i18n)

**文件**:
- `config/theme_config.dart`
- `providers/theme_mode_provider.dart`
- `localization/app_localization.dart`

**功能**:
- 浅色/深色主题切换
- 跟随系统主题
- 多语言支持(中文、英文、日文)
- 语言持久化存储

---

## 数据流

### 典型数据流示例: 用户登录

```
┌──────────┐      ┌──────────────┐      ┌─────────────┐      ┌──────────┐
│  UI层    │      │ Provider层   │      │ Service层   │      │Supabase  │
│LoginScreen│────▶│ AuthProvider │────▶│AuthService  │────▶│   Auth   │
└──────────┘      └──────────────┘      └─────────────┘      └──────────┘
     ▲                    │                     │                    │
     │                    │                     │                    │
     │              状态更新                   │              返回结果
     │                    │                     │                    │
     └────────────────────┴─────────────────────┴────────────────────┘
                        显示成功/失败消息
```

### 数据持久化策略

1. **临时数据**: 内存中(Riverpod State)
2. **用户偏好**: Hive (`app_config` box)
   - 主题模式
   - 语言设置
3. **敏感信息**: Flutter Secure Storage
   - Access Token
   - Refresh Token
4. **缓存数据**: Hive
   - 用户信息缓存
   - Token缓存

---

## 设计模式

### 1. 单例模式 (Singleton)
- **HttpClient**: 确保全局只有一个Dio实例
- **AppConfig**: 集中管理配置

### 2. 工厂模式 (Factory)
- **数据模型**: `fromJson()` 工厂方法创建对象
- **Service层**: 封装复杂的对象创建逻辑

### 3. 观察者模式 (Observer)
- **Riverpod**: 状态变化自动通知UI更新
- **ValueNotifier**: 语言切换监听

### 4. 仓储模式 (Repository Pattern)
- **Service层**: 抽象数据源,统一接口
- 隐藏数据来源(Supabase/本地缓存)

### 5. 依赖注入 (Dependency Injection)
- **Riverpod Provider**: 管理依赖关系
- 提高可测试性

---

## 关键技术实现

### 1. Supabase集成

```dart
// 初始化
await Supabase.initialize(
  url: AppConfig.supabaseUrl,
  anonKey: AppConfig.supabaseAnonKey,
);

// 使用
final supabase = AppConfig.supabase;
final response = await supabase
  .from('books')
  .select()
  .eq('available_quantity', 1);
```

### 2. Riverpod状态管理

```dart
// 定义Provider
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new
);

// 在UI中使用
final themeMode = ref.watch(themeModeProvider);
ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
```

### 3. JSON序列化

```dart
@JsonSerializable()
class Book {
  final String id;
  final String title;
  
  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
  Map<String, dynamic> toJson() => _$BookToJson(this);
}
```

### 4. 路由管理

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
    ],
  );
});
```

---

## 安全性

### 1. 认证安全
- 使用Supabase Auth进行身份验证
- JWT Token自动刷新
- Token存储在Secure Storage中

### 2. 数据安全
- RLS (Row Level Security) 保护数据库访问
- 敏感操作需要重新认证
- 输入验证防止注入攻击

### 3. 网络安全
- HTTPS通信
- Request/Response拦截器
- 错误处理和日志记录

---

## 性能优化

### 1. 图片优化
- CachedNetworkImage缓存网络图片
- 懒加载列表项
- 图片压缩和格式优化

### 2. 列表优化
- ListView.builder按需加载
- 分页加载避免一次性加载大量数据
- KeepAlive保持列表状态

### 3. 状态管理优化
- Riverpod自动取消订阅
- 细粒度的状态更新
- 避免不必要的重建

---

## 测试策略

### 1. 单元测试
- Service层业务逻辑测试
- 数据模型序列化测试
- 工具函数测试

### 2. Widget测试
- UI组件渲染测试
- 用户交互测试

### 3. 集成测试
- 完整业务流程测试
- 端到端测试

---

## 部署与发布

### iOS
- Xcode构建
- Code Signing配置
- App Store Connect上传

### Android
- Gradle构建
- Keystore签名
- Google Play Console上传

---

## 未来扩展

### 可能的改进方向
1. **离线支持**: 增强离线数据同步
2. **推送通知**: Firebase Cloud Messaging
3. **扫码借书**: 二维码/条形码扫描
4. **社交功能**: 分享、书友圈
5. **数据分析**: 阅读习惯分析
6. **多租户**: 支持多个图书馆

---

## 开发规范

### 代码风格
- 遵循 Dart Style Guide
- 使用 lints 进行代码检查
- 统一的命名规范

### 提交规范
- 清晰的commit message
- 功能分支开发
- Code Review流程

### 文档维护
- 及时更新API文档
- 代码注释完善
- CHANGELOG维护

---

## 联系方式

- **项目名称**: Library Management System
- **版本**: 1.0.0
- **开发团队**: [Your Team]
- **文档最后更新**: 2026-04-16

---

*本文档随项目迭代持续更新*
