/// 错误消息本地化工具
/// 将 Supabase 和其他错误转换为中文
class ErrorLocalization {
  /// 将错误对象转换为中文错误消息
  static String getLocalizedErrorMessage(dynamic error) {
    if (error == null) {
      return '发生未知错误';
    }

    final errorString = error.toString().toLowerCase();
    
    // 处理 Supabase AuthApiException 错误
    if (errorString.contains('email_not_confirmed')) {
      return '邮箱未确认，请检查您的邮箱并点击确认链接';
    }
    
    if (errorString.contains('invalid_credentials') || 
        errorString.contains('invalid login credentials')) {
      return '邮箱或密码错误，请重试';
    }
    
    if (errorString.contains('user_not_found')) {
      return '用户不存在';
    }
    
    if (errorString.contains('email_rate_limit') || 
        errorString.contains('over_email_send_rate_limit')) {
      return '邮件发送频率过高，请稍后再试';
    }
    
    if (errorString.contains('signup_disabled')) {
      return '注册功能已禁用';
    }
    
    if (errorString.contains('email_already_exists') ||
        errorString.contains('user already registered') ||
        errorString.contains('already exists')) {
      return '该邮箱已被注册，请直接登录';
    }
    
    if (errorString.contains('weak_password')) {
      return '密码强度不够，请使用更复杂的密码';
    }
    
    if (errorString.contains('password_reset_required')) {
      return '需要重置密码';
    }
    
    if (errorString.contains('token_expired')) {
      return '验证链接已过期，请重新申请';
    }
    
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return '网络连接失败，请检查网络设置';
    }
    
    if (errorString.contains('rate limit') || 
        errorString.contains('429')) {
      return '请求过于频繁，请稍后再试';
    }
    
    // 移除异常类型前缀，提取原始错误消息
    String message = error.toString();
    message = message
        .replaceAll('Exception: ', '')
        .replaceAll('AuthApiException: ', '')
        .replaceAll('AuthException: ', '')
        .replaceAll('ApiException: ', '');
    
    // 如果消息仍然包含英文错误代码，尝试提取更友好的消息
    if (message.contains('message:')) {
      final match = RegExp(r'message:\s*([^,]+)').firstMatch(message);
      if (match != null) {
        message = match.group(1)?.trim() ?? message;
      }
    }
    
    // 如果消息是纯英文且包含常见错误模式，进行翻译
    if (message.contains('email not confirmed')) {
      return '邮箱未确认，请检查您的邮箱并点击确认链接';
    }
    
    if (message.contains('invalid login credentials')) {
      return '邮箱或密码错误';
    }
    
    // 如果消息仍然是英文，返回通用错误消息
    if (RegExp(r'^[a-zA-Z\s]+$').hasMatch(message.trim()) && 
        message.length < 100) {
      return '操作失败，请稍后重试';
    }
    
    return message.isNotEmpty ? message : '发生未知错误';
  }
  
  /// 根据 HTTP 状态码获取中文错误消息
  static String getErrorMessageByStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误，请检查输入';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '没有权限访问此资源';
      case 404:
        return '请求的资源不存在';
      case 429:
        return '请求过于频繁，请稍后再试';
      case 500:
      case 502:
      case 503:
        return '服务器错误，请稍后重试';
      default:
        return '发生未知错误';
    }
  }
}
