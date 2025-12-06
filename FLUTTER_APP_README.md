# Flutter 图书馆管理系统 - 移动端应用

这是基于项目需求文档开发的完整 Flutter 应用程序。

## 📁 项目结构

```
lib/
├── main.dart                      # 应用入口
├── config/                        # 应用配置
│   ├── app_config.dart           # 应用基础配置
│   ├── router_config.dart        # 路由配置
│   └── theme_config.dart         # 主题配置
├── data/                         # 数据层
│   ├── models/                   # 数据模型
│   │   ├── user_model.dart
│   │   ├── book_model.dart
│   │   ├── borrow_record_model.dart
│   │   ├── category_model.dart
│   │   ├── notification_model.dart
│   │   └── api_response.dart
│   ├── network/                  # 网络层
│   │   └── http_client.dart
│   └── services/                 # API 服务
│       └── api_service.dart
├── presentation/                 # 界面层
│   └── screens/
│       ├── splash/               # 启动屏
│       ├── auth/                 # 认证相关
│       │   ├── login_screen.dart
│       │   └── register_screen.dart
│       └── home/                 # 主页面
│           ├── home_screen.dart
│           └── pages/
│               ├── home_page.dart
│               ├── books_page.dart
│               ├── borrows_page.dart
│               ├── messages_page.dart
│               └── profile_page.dart
```

## 🚀 快速开始

### 前置要求

- Flutter SDK 3.x
- Dart 3.0+
- iOS 11.0+
- Android 5.0+ (API 21+)

### 安装依赖

```bash
flutter pub get
```

### 生成模型文件

本项目使用 `json_serializable` 生成 JSON 序列化代码：

```bash
flutter pub run build_runner build
```

观看模式（开发时）：

```bash
flutter pub run build_runner watch
```

### 运行应用

开发模式：

```bash
flutter run
```

发布模式：

```bash
flutter run --release
```

## 📦 核心功能

### 已实现的功能

#### 1. 认证模块
- ✅ 用户登录界面
- ✅ 用户注册界面
- ✅ 密码切换显示
- ✅ 表单验证
- ✅ API 集成准备

#### 2. 主页面
- ✅ 底部导航栏（5个标签页）
  - 首页
  - 图书浏览
  - 借阅管理
  - 消息通知
  - 个人中心
- ✅ 响应式布局

#### 3. 首页 (Home Page)
- ✅ 搜索栏
- ✅ 推荐图书轮播
- ✅ 图书分类网格
- ✅ 新书推荐列表

#### 4. 图书浏览 (Books Page)
- ✅ 图书列表展示
- ✅ 搜索功能 UI
- ✅ 图书评分展示
- ✅ 可用状态指示

#### 5. 借阅管理 (Borrows Page)
- ✅ 当前借阅标签页
- ✅ 借阅历史标签页
- ✅ 续借按钮
- ✅ 归还按钮
- ✅ 借阅信息展示

#### 6. 消息通知 (Messages Page)
- ✅ 通知列表
- ✅ 未读状态指示
- ✅ 通知类型分类
- ✅ 时间显示

#### 7. 个人中心 (Profile Page)
- ✅ 用户信息展示
- ✅ 统计信息卡片
- ✅ 个人信息编辑选项
- ✅ 密码修改选项
- ✅ 借阅历史查看
- ✅ 帮助和关于
- ✅ 退出登录

### 待实现的功能

- [ ] 网络请求集成（连接到实际 API）
- [ ] 用户认证和令牌管理
- [ ] 本地数据持久化
- [ ] 状态管理（Riverpod 集成）
- [ ] 图片加载和缓存
- [ ] 下拉刷新和上拉加载
- [ ] 深色模式完整支持
- [ ] 多语言支持
- [ ] 推送通知
- [ ] 二维码扫描
- [ ] 单元测试
- [ ] 集成测试

## 🎨 设计系统

### 颜色方案

| 类型 | 浅色模式 | 深色模式 |
|------|----------|----------|
| 主色 | #2196F3 | #2196F3 |
| 次级色 | #FF9800 | #FF9800 |
| 成功 | #4CAF50 | #4CAF50 |
| 警告 | #FFC107 | #FFC107 |
| 错误 | #F44336 | #F44336 |
| 背景 | #FAFAFA | #121212 |

### 字体

- 标题 (H1): 32sp
- 标题 (H2): 28sp
- 标题 (H3): 24sp
- 正文 (Body): 16sp
- 说明 (Caption): 12sp

## 🔧 配置

### API 配置

编辑 `lib/config/app_config.dart`：

```dart
static const String apiBaseUrl = 'https://api.library.com';
static const int connectionTimeout = 30000; // ms
static const int receiveTimeout = 30000; // ms
```

### 环境变量

复制 `.env.example` 到 `.env` 并配置：

```bash
cp .env.example .env
```

## 📡 API 集成

项目已为所有必需的 API 端点做好准备：

### 认证 API
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/logout` - 用户登出

### 用户 API
- `GET /api/user/profile` - 获取用户信息
- `PUT /api/user/profile` - 更新用户信息

### 图书 API
- `GET /api/books` - 获取图书列表
- `GET /api/books/:id` - 获取图书详情
- `POST /api/books/search` - 搜索图书
- `GET /api/categories` - 获取分类

### 借阅 API
- `POST /api/borrow` - 借阅图书
- `POST /api/return` - 归还图书
- `GET /api/borrow/history` - 借阅历史
- `GET /api/borrow/current` - 当前借阅
- `POST /api/borrow/renew` - 续借

### 通知 API
- `GET /api/notifications` - 获取通知
- `PUT /api/notifications/:id` - 标记已读

## 📦 依赖项

### 状态管理
- `riverpod` - 声明式状态管理
- `flutter_riverpod` - Riverpod 的 Flutter 集成

### 网络请求
- `dio` - HTTP 客户端
- `retrofit` - 类型安全的 HTTP 客户端

### 本地存储
- `shared_preferences` - 轻量级键值对存储
- `hive` - 快速本地数据库
- `hive_flutter` - Hive 的 Flutter 集成
- `flutter_secure_storage` - 安全的数据存储

### 路由
- `go_router` - 声明式路由

### UI
- `cached_network_image` - 网络图片缓存
- `pull_to_refresh` - 下拉刷新
- `shimmer` - 骨架屏加载效果

### 其他
- `json_serializable` - JSON 序列化代码生成
- `intl` - 国际化

## 🧪 测试

运行测试：

```bash
flutter test
```

运行特定测试文件：

```bash
flutter test test/specific_test.dart
```

## 🏗️ 构建

### Android

调试版本：

```bash
flutter build apk --debug
```

发布版本：

```bash
flutter build apk --release
```

### iOS

调试版本：

```bash
flutter build ios --debug
```

发布版本：

```bash
flutter build ios --release
```

## 📝 代码规范

- 遵循 Flutter 官方代码风格指南
- 使用有意义的类名和变量名
- 添加必要的文档注释
- 每个文件单一职责
- 使用 const 构造函数

## 🔐 安全性

- 所有敏感信息使用 `flutter_secure_storage` 存储
- 使用 HTTPS 进行所有 API 通信
- 实现 Token 刷新机制
- 验证用户输入

## 📊 性能考虑

- 使用 `const` 构造函数减少重建
- 列表项使用 `ListView.builder`
- 图片使用 `cached_network_image`
- 分页加载数据
- 使用 Hive 缓存本地数据

## 🐛 调试

启用详细日志：

在 `lib/data/network/http_client.dart` 中启用 `_LoggingInterceptor`。

## 📚 文档

详细的项目需求文档位于项目根目录：

- `REQUIREMENTS.md` - 完整需求规范
- `API_SPECIFICATION_TEMPLATE.md` - API 接口文档
- `DATA_MODELS_TEMPLATE.md` - 数据模型文档
- `UI_DESIGN_REQUIREMENTS.md` - UI/UX 设计规范

## 🚢 部署

### 准备

1. 在 `pubspec.yaml` 中更新版本号
2. 生成密钥库文件（Android）
3. 配置签名配置文件（iOS）
4. 更新应用图标和启动画面

### 发布

Android Play Store：

```bash
flutter build appbundle --release
```

iOS App Store：

```bash
flutter build ios --release
```

## 📞 支持

如有问题，请参考：

- Flutter 官方文档: https://flutter.dev
- Dart 文档: https://dart.dev
- 项目需求文档: 项目根目录

## 📄 许可证

MIT License

---

**最后更新**: 2024年
**开发者**: Flutter Development Team
**版本**: 1.0.0
