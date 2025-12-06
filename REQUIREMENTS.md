# Flutter图书馆管理系统 - 需求文档

## 项目概述
为图书馆管理系统开发跨平台的Flutter移动应用，用户可以通过手机端浏览图书、借阅归还、查看记录等。

---

## 📋 需要提供的信息清单

### 1. 后端API信息

#### 1.1 服务器配置
- [ ] **API Base URL**: 后端服务器地址（例如：`https://api.library.com`）
- [ ] **API版本**: 使用的API版本（例如：v1, v2）
- [ ] **通信协议**: REST API / GraphQL / gRPC
- [ ] **数据格式**: JSON / XML / Protobuf

#### 1.2 认证方式
- [ ] **认证机制**: JWT Token / Session / OAuth 2.0
- [ ] **Token存储位置**: Header / Cookie / Body
- [ ] **Token刷新机制**: 是否支持refresh token
- [ ] **登录方式**: 
  - [ ] 用户名+密码
  - [ ] 邮箱+密码
  - [ ] 手机号+验证码
  - [ ] 第三方登录（微信、QQ等）

#### 1.3 核心API接口列表

**用户相关**
```
POST /api/auth/register      - 用户注册
POST /api/auth/login         - 用户登录
POST /api/auth/logout        - 用户登出
GET  /api/user/profile       - 获取用户信息
PUT  /api/user/profile       - 更新用户信息
POST /api/user/change-password - 修改密码
```

**图书相关**
```
GET  /api/books              - 获取图书列表（分页、搜索、筛选）
GET  /api/books/:id          - 获取图书详情
POST /api/books/search       - 搜索图书
GET  /api/categories         - 获取图书分类
```

**借阅相关**
```
POST /api/borrow             - 借阅图书
POST /api/return             - 归还图书
GET  /api/borrow/history     - 借阅历史
GET  /api/borrow/current     - 当前借阅
POST /api/borrow/renew       - 续借
```

**通知相关**
```
GET  /api/notifications      - 获取通知列表
PUT  /api/notifications/:id  - 标记已读
```

请提供每个接口的详细信息：
- 请求方法（GET/POST/PUT/DELETE）
- 请求参数（Query/Body/Path）
- 请求示例
- 响应格式
- 响应示例
- 错误码定义

---

### 2. 数据模型

#### 2.1 用户模型 (User)
```json
{
  "id": "string/number",
  "username": "string",
  "email": "string",
  "phone": "string",
  "avatar": "string (URL)",
  "role": "string (user/admin)",
  "studentId": "string",
  "department": "string",
  "createdAt": "datetime",
  "borrowLimit": "number",
  "currentBorrowCount": "number"
}
```

#### 2.2 图书模型 (Book)
```json
{
  "id": "string/number",
  "isbn": "string",
  "title": "string",
  "author": "string",
  "publisher": "string",
  "publishDate": "date",
  "category": "string/object",
  "coverImage": "string (URL)",
  "description": "string",
  "totalCopies": "number",
  "availableCopies": "number",
  "location": "string",
  "tags": ["string"]
}
```

#### 2.3 借阅记录模型 (BorrowRecord)
```json
{
  "id": "string/number",
  "userId": "string/number",
  "bookId": "string/number",
  "borrowDate": "datetime",
  "dueDate": "datetime",
  "returnDate": "datetime (nullable)",
  "status": "string (borrowed/returned/overdue)",
  "renewCount": "number",
  "fine": "number"
}
```

请确认或调整这些数据模型的字段。

---

### 3. 功能需求详细说明

#### 3.1 用户端功能

**必须提供的信息：**

**A. 注册登录**
- [ ] 注册需要哪些必填字段？
- [ ] 是否需要邮箱/手机验证？
- [ ] 密码强度要求（最小长度、特殊字符等）
- [ ] 是否支持找回密码功能？

**B. 图书浏览**
- [ ] 默认排序方式（最新、热门、分类）
- [ ] 支持哪些筛选条件（分类、作者、出版社等）
- [ ] 搜索支持哪些字段（书名、作者、ISBN等）
- [ ] 每页显示多少条数据？
- [ ] 是否支持收藏功能？

**C. 图书借阅**
- [ ] 单次可借阅数量限制
- [ ] 借阅期限（默认多少天）
- [ ] 可续借次数
- [ ] 是否支持预约功能？
- [ ] 逾期罚款规则

**D. 个人中心**
- [ ] 可修改哪些个人信息？
- [ ] 是否支持头像上传？
- [ ] 是否显示借阅统计信息？

#### 3.2 管理员功能（如果需要）
- [ ] 是否需要管理员功能？
- [ ] 图书管理（增删改查）
- [ ] 用户管理
- [ ] 借阅记录管理
- [ ] 数据统计报表

---

### 4. UI/UX设计要求

#### 4.1 设计规范
- [ ] **主题颜色**: 
  - 主色调：#______
  - 辅助色：#______
  - 背景色：#______
- [ ] **是否支持深色模式**: 是 / 否
- [ ] **字体**: 默认系统字体 / 自定义字体
- [ ] **是否有设计稿**: 提供Figma/Sketch/PSD链接或文件

#### 4.2 页面结构
- [ ] 首页展示内容（推荐图书、分类导航、搜索等）
- [ ] 底部导航栏包含哪些tab？
  - [ ] 首页
  - [ ] 分类
  - [ ] 借阅
  - [ ] 我的
  - [ ] 其他：_______

#### 4.3 交互要求
- [ ] 下拉刷新和上拉加载
- [ ] 骨架屏/加载动画样式
- [ ] 错误提示样式
- [ ] 空状态展示

---

### 5. 技术要求

#### 5.1 Flutter版本
- [ ] **Flutter SDK版本**: 建议使用最新稳定版（目前3.x）
- [ ] **Dart版本**: 对应的Dart版本
- [ ] **最低支持系统版本**:
  - Android: _______
  - iOS: _______

#### 5.2 第三方服务
- [ ] **图片加载**: 图片服务器地址，是否需要认证
- [ ] **推送通知**: 
  - 使用什么推送服务（Firebase、极光、个推等）
  - 推送key和配置信息
- [ ] **统计分析**: 是否需要（Google Analytics、友盟等）
- [ ] **崩溃监控**: 是否需要（Sentry、Bugly等）

#### 5.3 网络请求
- [ ] **请求超时时间**: _______秒
- [ ] **重试机制**: 是否自动重试
- [ ] **缓存策略**: 哪些数据需要缓存
- [ ] **请求头配置**: 是否需要特殊的header

---

### 6. 安全要求

- [ ] **数据加密**: 敏感数据是否需要加密存储
- [ ] **HTTPS**: 是否强制使用HTTPS
- [ ] **证书校验**: 是否需要SSL Pinning
- [ ] **Token安全**: Token存储方式（SharedPreferences/FlutterSecureStorage）
- [ ] **密码传输**: 是否需要前端加密

---

### 7. 测试要求

- [ ] **测试账号**: 提供测试用户账号密码
- [ ] **测试数据**: 是否有测试环境和测试数据
- [ ] **测试环境**: 测试服务器地址
- [ ] **Beta测试**: 是否需要内测版本

---

### 8. 部署发布

#### 8.1 Android
- [ ] **应用包名**: com.example.library
- [ ] **应用名称**: 图书馆管理系统
- [ ] **应用图标**: 提供1024x1024的图标文件
- [ ] **签名证书**: 是否已准备keystore文件
- [ ] **发布渠道**: Google Play / 国内应用市场 / 企业分发

#### 8.2 iOS
- [ ] **Bundle ID**: com.example.library
- [ ] **开发者账号**: 是否已有Apple开发者账号
- [ ] **发布渠道**: App Store / TestFlight / 企业签名

---

## 📱 建议的App功能模块

### 核心功能
1. **用户认证模块**
   - 登录/注册
   - 忘记密码
   - 自动登录

2. **图书模块**
   - 图书列表（分页）
   - 图书搜索
   - 图书详情
   - 图书分类

3. **借阅模块**
   - 借阅图书
   - 归还图书
   - 借阅历史
   - 当前借阅
   - 续借功能

4. **个人中心**
   - 个人信息展示
   - 信息修改
   - 密码修改
   - 借阅统计

5. **通知模块**
   - 到期提醒
   - 系统通知

### 扩展功能（可选）
- [ ] 扫码借还（扫描图书二维码/条形码）
- [ ] 图书评价和评论
- [ ] 图书推荐系统
- [ ] 图书收藏
- [ ] 阅读笔记
- [ ] 社交功能（读书分享）
- [ ] 离线模式
- [ ] 多语言支持

---

## 🛠️ 推荐的技术栈

### 状态管理
- Provider / Riverpod / Bloc / GetX

### 网络请求
- Dio + Retrofit

### 本地存储
- SharedPreferences (轻量数据)
- Hive / SQLite (复杂数据)
- FlutterSecureStorage (敏感数据)

### 路由管理
- Go Router / Auto Route

### UI组件
- Material Design / Cupertino

---

## 📝 提交材料清单

请准备并提供以下文档：

1. **API接口文档** （Swagger/Postman/文档链接）
2. **数据库设计文档** 或 数据模型说明
3. **原型设计图** 或 UI设计稿
4. **功能需求文档** 详细说明每个功能的业务逻辑
5. **测试账号** 和 **测试环境信息**
6. **品牌资源**：Logo、图标、配色方案
7. **第三方服务配置**：推送、统计等的key

---

## 📞 联系方式

如有任何问题，请及时沟通：
- 技术问题
- 需求变更
- 接口调试
- 设计确认

---

## 🚀 开发计划

### 第一阶段：基础框架（1-2周）
- 项目初始化
- 基础架构搭建
- 网络请求封装
- 路由配置
- 主题配置

### 第二阶段：核心功能（2-3周）
- 用户认证
- 图书浏览
- 图书搜索
- 图书详情

### 第三阶段：借阅功能（1-2周）
- 借阅管理
- 借阅历史
- 通知功能

### 第四阶段：个人中心（1周）
- 个人信息
- 设置功能

### 第五阶段：测试优化（1-2周）
- 功能测试
- 性能优化
- Bug修复

### 第六阶段：发布上线（1周）
- 打包签名
- 上架准备
- 文档整理

---

## ✅ 确认步骤

请按照以下步骤确认需求：

1. ✅ 阅读本文档所有内容
2. ✅ 勾选或填写所有 [ ] 标记的项目
3. ✅ 准备并提供所有必需的文档和资源
4. ✅ 确认功能优先级和开发周期
5. ✅ 确认开发开始时间

---

**备注**: 提供的信息越详细，开发过程越顺利，产品质量越高！
