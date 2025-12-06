class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(emailPattern);

    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 20) {
      return 'Username cannot exceed 20 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one digit';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    const phonePattern = r'^\+?1?\d{9,15}$';
    final regex = RegExp(phonePattern);

    if (!regex.hasMatch(value.replaceAll(RegExp(r'[^\d+]'), ''))) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Student ID validation
  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Student ID is required';
    }

    if (value.length < 5) {
      return 'Student ID must be at least 5 characters';
    }

    return null;
  }

  // General text field validation
  static String? validateTextField(String? value, {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // Book title validation
  static String? validateBookTitle(String? value) {
    return validateTextField(value, fieldName: 'Book title');
  }

  // Author name validation
  static String? validateAuthorName(String? value) {
    return validateTextField(value, fieldName: 'Author name');
  }

  // ISBN validation
  static String? validateISBN(String? value) {
    if (value == null || value.isEmpty) {
      return null; // ISBN is optional
    }

    // ISBN-10 or ISBN-13
    const isbnPattern = r'^\d{10}(\d{3})?(-\d+)?$';
    final regex = RegExp(isbnPattern);

    if (!regex.hasMatch(value.replaceAll('-', ''))) {
      return 'Please enter a valid ISBN';
    }

    return null;
  }

  // Range validation
  static String? validateRange(int? value, {required int min, required int max}) {
    if (value == null) {
      return 'Value is required';
    }

    if (value < min || value > max) {
      return 'Value must be between $min and $max';
    }

    return null;
  }
}

// Extension methods for validation
extension StringValidation on String {
  bool isValidEmail() {
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(emailPattern).hasMatch(this);
  }

  bool isValidUsername() {
    return length >= 3 && length <= 20 && RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(this);
  }

  bool isValidPassword() {
    return length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(this) &&
        RegExp(r'[a-z]').hasMatch(this) &&
        RegExp(r'[0-9]').hasMatch(this);
  }

  bool isValidPhone() {
    const phonePattern = r'^\+?1?\d{9,15}$';
    return RegExp(phonePattern).hasMatch(replaceAll(RegExp(r'[^\d+]'), ''));
  }

  bool isValidISBN() {
    const isbnPattern = r'^\d{10}(\d{3})?(-\d+)?$';
    return RegExp(isbnPattern).hasMatch(replaceAll('-', ''));
  }

  bool isEmpty() => trim().length == 0;

  bool isNotEmpty() => !isEmpty();
}
