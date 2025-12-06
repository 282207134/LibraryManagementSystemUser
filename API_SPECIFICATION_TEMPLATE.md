# API接口规范模板

## 请按照此模板提供完整的API接口文档

---

## 通用说明

### 服务器地址
```
开发环境: http://dev-api.library.com
测试环境: http://test-api.library.com  
生产环境: https://api.library.com
```

### 通用请求头
```http
Content-Type: application/json
Authorization: Bearer {token}
Accept-Language: zh-CN
```

### 通用响应格式
```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1234567890
}
```

### 错误码定义
| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权/Token失效 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 1. 用户认证接口

### 1.1 用户注册

**接口地址**: `POST /api/auth/register`

**请求参数**:
```json
{
  "username": "zhangsan",
  "password": "Password123!",
  "email": "zhangsan@example.com",
  "phone": "13800138000",
  "studentId": "2021001",
  "department": "计算机科学与技术"
}
```

**参数说明**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| username | string | 是 | 用户名，3-20字符 |
| password | string | 是 | 密码，至少8位，包含字母和数字 |
| email | string | 是 | 邮箱地址 |
| phone | string | 否 | 手机号 |
| studentId | string | 是 | 学号 |
| department | string | 否 | 院系 |

**响应示例**:
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "userId": "10001",
    "username": "zhangsan",
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

---

### 1.2 用户登录

**接口地址**: `POST /api/auth/login`

**请求参数**:
```json
{
  "username": "zhangsan",
  "password": "Password123!"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 7200,
    "user": {
      "id": "10001",
      "username": "zhangsan",
      "email": "zhangsan@example.com",
      "avatar": "https://example.com/avatar.jpg",
      "role": "user"
    }
  }
}
```

---

### 1.3 刷新Token

**接口地址**: `POST /api/auth/refresh`

**请求参数**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "刷新成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 7200
  }
}
```

---

## 2. 用户信息接口

### 2.1 获取用户信息

**接口地址**: `GET /api/user/profile`

**请求头**:
```
Authorization: Bearer {token}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "10001",
    "username": "zhangsan",
    "email": "zhangsan@example.com",
    "phone": "13800138000",
    "avatar": "https://example.com/avatar.jpg",
    "studentId": "2021001",
    "department": "计算机科学与技术",
    "borrowLimit": 5,
    "currentBorrowCount": 2,
    "createdAt": "2023-01-01T00:00:00Z"
  }
}
```

---

### 2.2 更新用户信息

**接口地址**: `PUT /api/user/profile`

**请求参数**:
```json
{
  "email": "newemail@example.com",
  "phone": "13900139000",
  "avatar": "https://example.com/new-avatar.jpg"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "更新成功",
  "data": {
    "id": "10001",
    "username": "zhangsan",
    "email": "newemail@example.com",
    "phone": "13900139000"
  }
}
```

---

## 3. 图书接口

### 3.1 获取图书列表

**接口地址**: `GET /api/books`

**请求参数** (Query):
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| page | int | 否 | 页码，默认1 |
| pageSize | int | 否 | 每页数量，默认20 |
| category | string | 否 | 分类ID |
| keyword | string | 否 | 搜索关键词 |
| sortBy | string | 否 | 排序字段(title/author/publishDate) |
| order | string | 否 | 排序方式(asc/desc) |

**请求示例**:
```
GET /api/books?page=1&pageSize=20&category=tech&keyword=算法
```

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 100,
    "page": 1,
    "pageSize": 20,
    "items": [
      {
        "id": "1001",
        "isbn": "9787115123456",
        "title": "算法导论",
        "author": "Thomas H. Cormen",
        "publisher": "机械工业出版社",
        "publishDate": "2020-01-01",
        "category": {
          "id": "tech",
          "name": "计算机技术"
        },
        "coverImage": "https://example.com/cover1.jpg",
        "description": "经典算法教材...",
        "totalCopies": 10,
        "availableCopies": 5,
        "location": "A区3层",
        "tags": ["算法", "计算机", "教材"]
      }
    ]
  }
}
```

---

### 3.2 获取图书详情

**接口地址**: `GET /api/books/:id`

**路径参数**:
- id: 图书ID

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "1001",
    "isbn": "9787115123456",
    "title": "算法导论",
    "author": "Thomas H. Cormen",
    "publisher": "机械工业出版社",
    "publishDate": "2020-01-01",
    "category": {
      "id": "tech",
      "name": "计算机技术"
    },
    "coverImage": "https://example.com/cover1.jpg",
    "description": "详细的图书描述...",
    "totalCopies": 10,
    "availableCopies": 5,
    "location": "A区3层",
    "tags": ["算法", "计算机", "教材"],
    "rating": 4.5,
    "reviewCount": 120
  }
}
```

---

### 3.3 搜索图书

**接口地址**: `POST /api/books/search`

**请求参数**:
```json
{
  "keyword": "算法",
  "searchFields": ["title", "author", "isbn"],
  "filters": {
    "category": "tech",
    "publishDateFrom": "2020-01-01",
    "publishDateTo": "2023-12-31"
  },
  "page": 1,
  "pageSize": 20
}
```

**响应格式**: 同3.1图书列表

---

### 3.4 获取图书分类

**接口地址**: `GET /api/categories`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": "tech",
      "name": "计算机技术",
      "icon": "https://example.com/icon-tech.png",
      "bookCount": 1500
    },
    {
      "id": "literature",
      "name": "文学",
      "icon": "https://example.com/icon-lit.png",
      "bookCount": 2000
    }
  ]
}
```

---

## 4. 借阅接口

### 4.1 借阅图书

**接口地址**: `POST /api/borrow`

**请求参数**:
```json
{
  "bookId": "1001",
  "borrowDays": 30
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "借阅成功",
  "data": {
    "borrowId": "B20231201001",
    "bookId": "1001",
    "bookTitle": "算法导论",
    "borrowDate": "2023-12-01T10:00:00Z",
    "dueDate": "2023-12-31T23:59:59Z",
    "renewCount": 0
  }
}
```

---

### 4.2 归还图书

**接口地址**: `POST /api/return`

**请求参数**:
```json
{
  "borrowId": "B20231201001"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "归还成功",
  "data": {
    "borrowId": "B20231201001",
    "returnDate": "2023-12-15T10:00:00Z",
    "isOverdue": false,
    "fine": 0
  }
}
```

---

### 4.3 续借图书

**接口地址**: `POST /api/borrow/renew`

**请求参数**:
```json
{
  "borrowId": "B20231201001",
  "extendDays": 15
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "续借成功",
  "data": {
    "borrowId": "B20231201001",
    "newDueDate": "2024-01-15T23:59:59Z",
    "renewCount": 1,
    "maxRenewCount": 2
  }
}
```

---

### 4.4 当前借阅列表

**接口地址**: `GET /api/borrow/current`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "borrowId": "B20231201001",
      "book": {
        "id": "1001",
        "title": "算法导论",
        "author": "Thomas H. Cormen",
        "coverImage": "https://example.com/cover1.jpg"
      },
      "borrowDate": "2023-12-01T10:00:00Z",
      "dueDate": "2023-12-31T23:59:59Z",
      "remainingDays": 15,
      "isOverdue": false,
      "renewCount": 0,
      "maxRenewCount": 2
    }
  ]
}
```

---

### 4.5 借阅历史

**接口地址**: `GET /api/borrow/history`

**请求参数** (Query):
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| page | int | 否 | 页码，默认1 |
| pageSize | int | 否 | 每页数量，默认20 |
| status | string | 否 | 状态(all/returned/overdue) |

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 50,
    "page": 1,
    "pageSize": 20,
    "items": [
      {
        "borrowId": "B20231101001",
        "book": {
          "id": "1002",
          "title": "深度学习",
          "author": "Ian Goodfellow",
          "coverImage": "https://example.com/cover2.jpg"
        },
        "borrowDate": "2023-11-01T10:00:00Z",
        "dueDate": "2023-11-30T23:59:59Z",
        "returnDate": "2023-11-25T14:30:00Z",
        "status": "returned",
        "isOverdue": false,
        "fine": 0
      }
    ]
  }
}
```

---

## 5. 通知接口

### 5.1 获取通知列表

**接口地址**: `GET /api/notifications`

**请求参数** (Query):
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| page | int | 否 | 页码，默认1 |
| pageSize | int | 否 | 每页数量，默认20 |
| unreadOnly | boolean | 否 | 仅未读 |

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 30,
    "unreadCount": 5,
    "items": [
      {
        "id": "N001",
        "type": "due_reminder",
        "title": "还书提醒",
        "content": "您借阅的《算法导论》将在3天后到期，请及时归还",
        "isRead": false,
        "createdAt": "2023-12-01T10:00:00Z",
        "relatedData": {
          "borrowId": "B20231201001",
          "bookId": "1001"
        }
      }
    ]
  }
}
```

---

### 5.2 标记通知已读

**接口地址**: `PUT /api/notifications/:id`

**路径参数**:
- id: 通知ID

**响应示例**:
```json
{
  "code": 200,
  "message": "已标记为已读"
}
```

---

## 6. 文件上传接口

### 6.1 上传头像

**接口地址**: `POST /api/upload/avatar`

**请求格式**: multipart/form-data

**请求参数**:
- file: 图片文件

**响应示例**:
```json
{
  "code": 200,
  "message": "上传成功",
  "data": {
    "url": "https://example.com/avatar/user10001.jpg",
    "filename": "user10001.jpg"
  }
}
```

---

## 附加说明

### 分页说明
- 默认页码从1开始
- 默认每页20条数据
- 最大每页100条

### 日期格式
- 统一使用 ISO 8601 格式: `2023-12-01T10:00:00Z`

### 图片地址
- 返回完整的URL地址
- 支持HTTPS访问

### Token有效期
- Access Token: 2小时
- Refresh Token: 7天

---

**请根据实际后端实现，填写完整的接口文档！**
