// 应用常量定义类,集中管理所有常量
class AppConstants {
  // 应用信息
  static const String appName = 'Library Management System';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // API端点地址
  static const String apiBaseUrl = 'https://api.library.com';
  static const String apiDevUrl = 'http://dev-api.library.com';
  static const String apiTestUrl = 'http://test-api.library.com';

  // 超时时间(毫秒)
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Hive数据库存储盒名称
  static const String hiveBoxTokens = 'tokens';
  static const String hiveBoxUserCache = 'user_cache';
  static const String hiveBoxConfig = 'app_config';

  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 借阅规则
  static const int maxBorrowCount = 5;
  static const int defaultBorrowDays = 30;
  static const int maxRenewCount = 3;
  static const double finePerDay = 1.0; // 每天的罚款金额

  // HTTP状态码
  static const int successCode = 200;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int serverErrorCode = 500;

  // 借阅状态
  static const String borrowStatusBorrowed = 'borrowed';
  static const String borrowStatusReturned = 'returned';
  static const String borrowStatusOverdue = 'overdue';

  // 图书状态
  static const String bookStatusAvailable = 'available';
  static const String bookStatusUnavailable = 'unavailable';

  // 用户角色
  static const String userRoleUser = 'user';
  static const String userRoleAdmin = 'admin';

  // 用户状态
  static const String userStatusActive = 'active';
  static const String userStatusSuspended = 'suspended';
  static const String userStatusBanned = 'banned';

  // 通知类型
  static const String notificationTypeDueReminder = 'due_reminder';
  static const String notificationTypeOverdue = 'overdue';
  static const String notificationTypeReturn = 'return';
  static const String notificationTypeAvailable = 'available';
  static const String notificationTypeSystem = 'system';

  // 日期格式模式
  static const String dateFormatPattern = 'yyyy-MM-dd';
  static const String dateTimeFormatPattern = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormatPattern = 'MMM dd, yyyy';
}

// 错误消息定义类
class ErrorMessages {
  static const String networkError = '网络连接失败，请检查网络设置';
  static const String serverError = '服务器错误，请稍后重试';
  static const String unauthorizedError = '未授权，请重新登录';
  static const String forbiddenError = '没有权限访问此资源';
  static const String notFoundError = '请求的资源不存在';
  static const String validationError = '请求参数错误，请检查输入';
  static const String unknownError = '发生未知错误';

  // 根据HTTP状态码获取对应的错误消息
  static String getErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return validationError;
      case 401:
        return unauthorizedError;
      case 403:
        return forbiddenError;
      case 404:
        return notFoundError;
      case 500:
      case 502:
      case 503:
        return serverError;
      default:
        return unknownError;
    }
  }
}

// 成功消息定义类
class SuccessMessages {
  static const String loginSuccess = '登录成功！';
  static const String registerSuccess = '注册成功！';
  static const String logoutSuccess = '退出登录成功！';
  static const String borrowSuccess = '借阅成功！';
  static const String returnSuccess = '归还成功！';
  static const String renewSuccess = '续借成功！';
  static const String updateSuccess = '更新成功！';
  static const String deleteSuccess = '删除成功！';
}

// 验证消息定义类
class ValidationMessages {
  static const String emptyUsername = '用户名不能为空';
  static const String emptyEmail = '邮箱不能为空';
  static const String emptyPassword = '密码不能为空';
  static const String emptyPhone = '手机号不能为空';
  static const String emptyStudentId = '学号不能为空';
  static const String invalidEmail = '请输入有效的邮箱地址';
  static const String invalidPhone = '请输入有效的手机号码';
  static const String passwordTooShort = '密码至少需要8个字符';
  static const String passwordMismatch = '密码不匹配';
  static const String usernameTooShort = '用户名至少需要3个字符';
  static const String usernameTooLong = '用户名不能超过20个字符';
}
