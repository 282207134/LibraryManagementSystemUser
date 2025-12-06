# 数据模型模板

## 请确认或修改以下数据模型结构

---

## 1. 用户模型 (User)

### 字段定义

| 字段名 | 类型 | 可空 | 说明 | 示例 |
|--------|------|------|------|------|
| id | String/Int | 否 | 用户唯一标识 | "10001" |
| username | String | 否 | 用户名 | "zhangsan" |
| email | String | 否 | 邮箱地址 | "zhangsan@example.com" |
| phone | String | 是 | 手机号 | "13800138000" |
| avatar | String | 是 | 头像URL | "https://example.com/avatar.jpg" |
| role | String | 否 | 用户角色 | "user" / "admin" |
| studentId | String | 是 | 学号 | "2021001" |
| department | String | 是 | 院系/部门 | "计算机科学与技术" |
| realName | String | 是 | 真实姓名 | "张三" |
| gender | String | 是 | 性别 | "male" / "female" |
| birthDate | Date | 是 | 出生日期 | "1998-01-01" |
| address | String | 是 | 地址 | "北京市海淀区" |
| borrowLimit | Int | 否 | 可借阅数量上限 | 5 |
| currentBorrowCount | Int | 否 | 当前借阅数量 | 2 |
| totalBorrowCount | Int | 否 | 累计借阅次数 | 50 |
| creditScore | Int | 是 | 信用分 | 100 |
| status | String | 否 | 账户状态 | "active" / "suspended" / "banned" |
| createdAt | DateTime | 否 | 创建时间 | "2023-01-01T00:00:00Z" |
| updatedAt | DateTime | 否 | 更新时间 | "2023-12-01T00:00:00Z" |
| lastLoginAt | DateTime | 是 | 最后登录时间 | "2023-12-01T10:00:00Z" |

### JSON示例

```json
{
  "id": "10001",
  "username": "zhangsan",
  "email": "zhangsan@example.com",
  "phone": "13800138000",
  "avatar": "https://example.com/avatar.jpg",
  "role": "user",
  "studentId": "2021001",
  "department": "计算机科学与技术",
  "realName": "张三",
  "gender": "male",
  "birthDate": "1998-01-01",
  "address": "北京市海淀区",
  "borrowLimit": 5,
  "currentBorrowCount": 2,
  "totalBorrowCount": 50,
  "creditScore": 100,
  "status": "active",
  "createdAt": "2023-01-01T00:00:00Z",
  "updatedAt": "2023-12-01T00:00:00Z",
  "lastLoginAt": "2023-12-01T10:00:00Z"
}
```

---

## 2. 图书模型 (Book)

### 字段定义

| 字段名 | 类型 | 可空 | 说明 | 示例 |
|--------|------|------|------|------|
| id | String/Int | 否 | 图书唯一标识 | "1001" |
| isbn | String | 是 | ISBN号 | "9787115123456" |
| title | String | 否 | 书名 | "算法导论" |
| subtitle | String | 是 | 副标题 | "第三版" |
| author | String | 否 | 作者 | "Thomas H. Cormen" |
| translator | String | 是 | 译者 | "张三" |
| publisher | String | 否 | 出版社 | "机械工业出版社" |
| publishDate | Date | 是 | 出版日期 | "2020-01-01" |
| edition | String | 是 | 版本 | "第3版" |
| pages | Int | 是 | 页数 | 800 |
| price | Decimal | 是 | 价格 | 128.00 |
| category | Object/String | 是 | 分类 | 见Category模型 |
| categoryId | String | 是 | 分类ID | "tech" |
| coverImage | String | 是 | 封面图URL | "https://example.com/cover.jpg" |
| images | Array<String> | 是 | 其他图片 | ["url1", "url2"] |
| description | String | 是 | 简介 | "经典算法教材..." |
| contentIntro | String | 是 | 目录/内容简介 | "第一章..." |
| language | String | 是 | 语言 | "zh-CN" / "en" |
| totalCopies | Int | 否 | 馆藏总数 | 10 |
| availableCopies | Int | 否 | 可借数量 | 5 |
| borrowedCopies | Int | 否 | 已借出数量 | 5 |
| location | String | 是 | 馆藏位置 | "A区3层" |
| callNumber | String | 是 | 索书号 | "TP301.6/C828" |
| tags | Array<String> | 是 | 标签 | ["算法", "计算机"] |
| keywords | Array<String> | 是 | 关键词 | ["算法", "数据结构"] |
| rating | Decimal | 是 | 评分 | 4.5 |
| reviewCount | Int | 是 | 评论数 | 120 |
| viewCount | Int | 是 | 浏览次数 | 5000 |
| borrowCount | Int | 是 | 借阅次数 | 500 |
| status | String | 否 | 状态 | "available" / "unavailable" |
| createdAt | DateTime | 否 | 创建时间 | "2023-01-01T00:00:00Z" |
| updatedAt | DateTime | 否 | 更新时间 | "2023-12-01T00:00:00Z" |

### JSON示例

```json
{
  "id": "1001",
  "isbn": "9787115123456",
  "title": "算法导论",
  "subtitle": "第三版",
  "author": "Thomas H. Cormen, Charles E. Leiserson",
  "translator": "殷建平",
  "publisher": "机械工业出版社",
  "publishDate": "2020-01-01",
  "edition": "第3版",
  "pages": 800,
  "price": 128.00,
  "category": {
    "id": "tech",
    "name": "计算机技术"
  },
  "categoryId": "tech",
  "coverImage": "https://example.com/cover1.jpg",
  "images": ["https://example.com/img1.jpg", "https://example.com/img2.jpg"],
  "description": "这本书深入浅出地介绍了算法的基础知识...",
  "contentIntro": "第一部分 基础知识\n第一章 算法在计算中的作用...",
  "language": "zh-CN",
  "totalCopies": 10,
  "availableCopies": 5,
  "borrowedCopies": 5,
  "location": "A区3层",
  "callNumber": "TP301.6/C828",
  "tags": ["算法", "计算机", "教材"],
  "keywords": ["算法", "数据结构", "计算复杂性"],
  "rating": 4.5,
  "reviewCount": 120,
  "viewCount": 5000,
  "borrowCount": 500,
  "status": "available",
  "createdAt": "2023-01-01T00:00:00Z",
  "updatedAt": "2023-12-01T00:00:00Z"
}
```

---

## 3. 图书分类模型 (Category)

### 字段定义

| 字段名 | 类型 | 可空 | 说明 | 示例 |
|--------|------|------|------|------|
| id | String/Int | 否 | 分类唯一标识 | "tech" |
| name | String | 否 | 分类名称 | "计算机技术" |
| parentId | String | 是 | 父分类ID | "science" |
| icon | String | 是 | 图标URL | "https://example.com/icon.png" |
| description | String | 是 | 描述 | "计算机相关书籍" |
| bookCount | Int | 否 | 图书数量 | 1500 |
| sortOrder | Int | 是 | 排序顺序 | 1 |
| level | Int | 是 | 层级 | 1 |
| path | String | 是 | 路径 | "science/tech" |
| status | String | 否 | 状态 | "active" / "inactive" |

### JSON示例

```json
{
  "id": "tech",
  "name": "计算机技术",
  "parentId": "science",
  "icon": "https://example.com/icon-tech.png",
  "description": "包含编程、算法、人工智能等计算机相关书籍",
  "bookCount": 1500,
  "sortOrder": 1,
  "level": 2,
  "path": "science/tech",
  "status": "active"
}
```

---

## 4. 借阅记录模型 (BorrowRecord)

### 字段定义

| 字段名 | 类型 | 可空 | 说明 | 示例 |
|--------|------|------|------|------|
| id | String/Int | 否 | 借阅记录ID | "B20231201001" |
| userId | String/Int | 否 | 用户ID | "10001" |
| user | Object | 是 | 用户信息 | 见User模型 |
| bookId | String/Int | 否 | 图书ID | "1001" |
| book | Object | 是 | 图书信息 | 见Book模型 |
| borrowDate | DateTime | 否 | 借阅日期 | "2023-12-01T10:00:00Z" |
| dueDate | DateTime | 否 | 应还日期 | "2023-12-31T23:59:59Z" |
| returnDate | DateTime | 是 | 实际归还日期 | "2023-12-25T14:30:00Z" |
| renewCount | Int | 否 | 续借次数 | 1 |
| maxRenewCount | Int | 否 | 最大续借次数 | 2 |
| status | String | 否 | 状态 | "borrowed" / "returned" / "overdue" |
| isOverdue | Boolean | 否 | 是否逾期 | false |
| overdueDays | Int | 是 | 逾期天数 | 0 |
| fine | Decimal | 是 | 罚款金额 | 0.00 |
| isPaid | Boolean | 是 | 是否已支付罚款 | true |
| borrowLocation | String | 是 | 借阅地点 | "总馆" |
| returnLocation | String | 是 | 归还地点 | "分馆" |
| operator | String | 是 | 操作员 | "admin01" |
| remarks | String | 是 | 备注 | "无损坏" |
| createdAt | DateTime | 否 | 创建时间 | "2023-12-01T10:00:00Z" |
| updatedAt | DateTime | 否 | 更新时间 | "2023-12-25T14:30:00Z" |

### JSON示例

```json
{
  "id": "B20231201001",
  "userId": "10001",
  "user": {
    "id": "10001",
    "username": "zhangsan",
    "studentId": "2021001"
  },
  "bookId": "1001",
  "book": {
    "id": "1001",
    "title": "算法导论",
    "author": "Thomas H. Cormen",
    "coverImage": "https://example.com/cover1.jpg"
  },
  "borrowDate": "2023-12-01T10:00:00Z",
  "dueDate": "2023-12-31T23:59:59Z",
  "returnDate": "2023-12-25T14:30:00Z",
  "renewCount": 1,
  "maxRenewCount": 2,
  "status": "returned",
  "isOverdue": false,
  "overdueDays": 0,
  "fine": 0.00,
  "isPaid": true,
  "borrowLocation": "总馆",
  "returnLocation": "总馆",
  "operator": "admin01",
  "remarks": "图书完好无损",
  "createdAt": "2023-12-01T10:00:00Z",
  "updatedAt": "2023-12-25T14:30:00Z"
}
```

---

## 5. 通知模型 (Notification)

### 字段定义

| 字段名 | 类型 | 可空 | 说明 | 示例 |
|--------|------|------|------|------|
| id | String/Int | 否 | 通知ID | "N001" |
| userId | String/Int | 否 | 用户ID | "10001" |
| type | String | 否 | 通知类型 | "due_reminder" |
| title | String | 否 | 标题 | "还书提醒" |
| content | String | 否 | 内容 | "您借阅的《算法导论》..." |
| isRead | Boolean | 否 | 是否已读 | false |
| readAt | DateTime | 是 | 阅读时间 | "2023-12-02T10:00:00Z" |
| relatedData | Object | 是 | 相关数据 | {"borrowId": "B001"} |
| priority | String | 是 | 优先级 | "high" / "normal" / "low" |
| expiresAt | DateTime | 是 | 过期时间 | "2023-12-31T23:59:59Z" |
| createdAt | DateTime | 否 | 创建时间 | "2023-12-01T10:00:00Z" |

### 通知类型说明

| 类型 | 说明 |
|------|------|
| due_reminder | 还书提醒 |
| overdue_notice | 逾期通知 |
| return_success | 归还成功 |
| renew_success | 续借成功 |
| book_available | 图书可借提醒 |
| system_notice | 系统通知 |

### JSON示例

```json
{
  "id": "N001",
  "userId": "10001",
  "type": "due_reminder",
  "title": "还书提醒",
  "content": "您借阅的《算法导论》将在3天后到期，请及时归还",
  "isRead": false,
  "readAt": null,
  "relatedData": {
    "borrowId": "B20231201001",
    "bookId": "1001",
    "bookTitle": "算法导论",
    "dueDate": "2023-12-31T23:59:59Z"
  },
  "priority": "high",
  "expiresAt": "2023-12-31T23:59:59Z",
  "createdAt": "2023-12-01T10:00:00Z"
}
```

---

## 6. 评论模型 (Review)

### 字段定义

| 字段名 | 类型 | 可空 | 说明 | 示例 |
|--------|------|------|------|------|
| id | String/Int | 否 | 评论ID | "R001" |
| userId | String/Int | 否 | 用户ID | "10001" |
| user | Object | 是 | 用户信息 | 见User模型 |
| bookId | String/Int | 否 | 图书ID | "1001" |
| rating | Int | 否 | 评分(1-5) | 5 |
| content | String | 是 | 评论内容 | "非常好的书..." |
| likeCount | Int | 否 | 点赞数 | 10 |
| isLiked | Boolean | 是 | 当前用户是否点赞 | false |
| status | String | 否 | 状态 | "approved" / "pending" |
| createdAt | DateTime | 否 | 创建时间 | "2023-12-01T10:00:00Z" |
| updatedAt | DateTime | 否 | 更新时间 | "2023-12-01T10:00:00Z" |

### JSON示例

```json
{
  "id": "R001",
  "userId": "10001",
  "user": {
    "id": "10001",
    "username": "zhangsan",
    "avatar": "https://example.com/avatar.jpg"
  },
  "bookId": "1001",
  "rating": 5,
  "content": "非常好的算法教材，讲解清晰，案例丰富，强烈推荐！",
  "likeCount": 10,
  "isLiked": false,
  "status": "approved",
  "createdAt": "2023-12-01T10:00:00Z",
  "updatedAt": "2023-12-01T10:00:00Z"
}
```

---

## 7. 收藏模型 (Favorite)

### 字段定义

| 字段名 | 类型 | 可空 | 说明 | 示例 |
|--------|------|------|------|------|
| id | String/Int | 否 | 收藏ID | "F001" |
| userId | String/Int | 否 | 用户ID | "10001" |
| bookId | String/Int | 否 | 图书ID | "1001" |
| book | Object | 是 | 图书信息 | 见Book模型 |
| tags | Array<String> | 是 | 自定义标签 | ["想读", "必读"] |
| note | String | 是 | 笔记 | "待阅读" |
| createdAt | DateTime | 否 | 创建时间 | "2023-12-01T10:00:00Z" |

### JSON示例

```json
{
  "id": "F001",
  "userId": "10001",
  "bookId": "1001",
  "book": {
    "id": "1001",
    "title": "算法导论",
    "author": "Thomas H. Cormen",
    "coverImage": "https://example.com/cover1.jpg"
  },
  "tags": ["想读", "必读书单"],
  "note": "推荐阅读，准备考研使用",
  "createdAt": "2023-12-01T10:00:00Z"
}
```

---

## 8. 预约模型 (Reservation)

### 字段定义

| 字段名 | 类型 | 可空 | 说明 | 示例 |
|--------|------|------|------|------|
| id | String/Int | 否 | 预约ID | "R001" |
| userId | String/Int | 否 | 用户ID | "10001" |
| bookId | String/Int | 否 | 图书ID | "1001" |
| book | Object | 是 | 图书信息 | 见Book模型 |
| status | String | 否 | 状态 | "pending" / "ready" / "expired" |
| reserveDate | DateTime | 否 | 预约日期 | "2023-12-01T10:00:00Z" |
| expireDate | DateTime | 否 | 过期日期 | "2023-12-08T23:59:59Z" |
| notifyDate | DateTime | 是 | 通知日期 | "2023-12-05T10:00:00Z" |
| pickupLocation | String | 是 | 取书地点 | "总馆" |
| createdAt | DateTime | 否 | 创建时间 | "2023-12-01T10:00:00Z" |

### JSON示例

```json
{
  "id": "RS001",
  "userId": "10001",
  "bookId": "1001",
  "book": {
    "id": "1001",
    "title": "算法导论",
    "author": "Thomas H. Cormen",
    "coverImage": "https://example.com/cover1.jpg"
  },
  "status": "ready",
  "reserveDate": "2023-12-01T10:00:00Z",
  "expireDate": "2023-12-08T23:59:59Z",
  "notifyDate": "2023-12-05T10:00:00Z",
  "pickupLocation": "总馆",
  "createdAt": "2023-12-01T10:00:00Z"
}
```

---

## 9. 分页响应模型 (PageResponse)

### 字段定义

```json
{
  "total": 100,
  "page": 1,
  "pageSize": 20,
  "totalPages": 5,
  "hasNext": true,
  "hasPrevious": false,
  "items": []
}
```

---

## 10. 统一响应模型 (ApiResponse)

### 字段定义

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1701417600000
}
```

---

## 附加说明

### 数据类型说明

- **String**: 字符串
- **Int**: 整数
- **Decimal**: 小数（用于金额等）
- **Boolean**: 布尔值（true/false）
- **Date**: 日期（YYYY-MM-DD）
- **DateTime**: 日期时间（ISO 8601格式）
- **Array**: 数组
- **Object**: 对象

### 状态枚举值

**用户状态 (User.status)**
- active: 激活
- suspended: 暂停
- banned: 封禁

**图书状态 (Book.status)**
- available: 可借
- unavailable: 不可借
- maintenance: 维护中

**借阅状态 (BorrowRecord.status)**
- borrowed: 已借出
- returned: 已归还
- overdue: 已逾期
- lost: 遗失

**通知状态 (Notification.type)**
- due_reminder: 还书提醒
- overdue_notice: 逾期通知
- return_success: 归还成功
- renew_success: 续借成功
- book_available: 图书可借
- system_notice: 系统通知

---

**请根据实际后端数据库设计，确认或修改以上数据模型！**
