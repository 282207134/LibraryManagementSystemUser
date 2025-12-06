class AppConstants {
  // App information
  static const String appName = 'Library Management System';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // API endpoints
  static const String apiBaseUrl = 'https://api.library.com';
  static const String apiDevUrl = 'http://dev-api.library.com';
  static const String apiTestUrl = 'http://test-api.library.com';

  // Timeout values (in milliseconds)
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Database
  static const String hiveBoxTokens = 'tokens';
  static const String hiveBoxUserCache = 'user_cache';
  static const String hiveBoxConfig = 'app_config';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Borrow rules
  static const int maxBorrowCount = 5;
  static const int defaultBorrowDays = 30;
  static const int maxRenewCount = 3;
  static const double finePerDay = 1.0; // Currency unit per day

  // Status codes
  static const int successCode = 200;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int serverErrorCode = 500;

  // Borrow status
  static const String borrowStatusBorrowed = 'borrowed';
  static const String borrowStatusReturned = 'returned';
  static const String borrowStatusOverdue = 'overdue';

  // Book status
  static const String bookStatusAvailable = 'available';
  static const String bookStatusUnavailable = 'unavailable';

  // User role
  static const String userRoleUser = 'user';
  static const String userRoleAdmin = 'admin';

  // User status
  static const String userStatusActive = 'active';
  static const String userStatusSuspended = 'suspended';
  static const String userStatusBanned = 'banned';

  // Notification type
  static const String notificationTypeDueReminder = 'due_reminder';
  static const String notificationTypeOverdue = 'overdue';
  static const String notificationTypeReturn = 'return';
  static const String notificationTypeAvailable = 'available';
  static const String notificationTypeSystem = 'system';

  // Date format patterns
  static const String dateFormatPattern = 'yyyy-MM-dd';
  static const String dateTimeFormatPattern = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormatPattern = 'MMM dd, yyyy';
}

class ErrorMessages {
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError = 'Unauthorized. Please login again.';
  static const String forbiddenError = 'You do not have permission to access this resource.';
  static const String notFoundError = 'The requested resource was not found.';
  static const String validationError = 'Please check your input.';
  static const String unknownError = 'An unknown error occurred.';

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

class SuccessMessages {
  static const String loginSuccess = 'Login successful!';
  static const String registerSuccess = 'Registration successful!';
  static const String logoutSuccess = 'Logout successful!';
  static const String borrowSuccess = 'Book borrowed successfully!';
  static const String returnSuccess = 'Book returned successfully!';
  static const String renewSuccess = 'Book renewed successfully!';
  static const String updateSuccess = 'Updated successfully!';
  static const String deleteSuccess = 'Deleted successfully!';
}

class ValidationMessages {
  static const String emptyUsername = 'Username cannot be empty';
  static const String emptyEmail = 'Email cannot be empty';
  static const String emptyPassword = 'Password cannot be empty';
  static const String emptyPhone = 'Phone cannot be empty';
  static const String emptyStudentId = 'Student ID cannot be empty';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String usernameTooShort = 'Username must be at least 3 characters';
  static const String usernameTooLong = 'Username cannot exceed 20 characters';
}
