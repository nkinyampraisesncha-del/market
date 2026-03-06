class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    if (value.length > 50) return 'Name must not exceed 50 characters';
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) return 'Price is required';
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Enter a valid price';
    if (parsed < 0) return 'Price cannot be negative';
    if (parsed > 99999) return 'Price exceeds maximum allowed';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    final phoneRegex = RegExp(r'^\+?[1-9]\d{7,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? description(String? value) {
    if (value == null || value.isEmpty) return 'Description is required';
    if (value.length < 10) return 'Description must be at least 10 characters';
    if (value.length > 2000) return 'Description must not exceed 2000 characters';
    return null;
  }

  static String? title(String? value) {
    if (value == null || value.isEmpty) return 'Title is required';
    if (value.length < 3) return 'Title must be at least 3 characters';
    if (value.length > 100) return 'Title must not exceed 100 characters';
    return null;
  }
}
