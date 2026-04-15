/// Input validators for forms.
///
/// Provides validation for common input fields such as
/// email, phone number (Ethiopian format), and passwords.
class Validators {
  Validators._();

  /// Validates an email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates an Ethiopian phone number.
  ///
  /// Accepts formats:
  /// - +251XXXXXXXXX (international)
  /// - 09XXXXXXXX (local)
  /// - 9XXXXXXXX (without leading zero)
  static String? validateEthiopianPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    String cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');

    final internationalRegex = RegExp(r'^\+2519\d{8}$');
    final localRegex = RegExp(r'^09\d{8}$');
    final shortRegex = RegExp(r'^9\d{8}$');

    if (!internationalRegex.hasMatch(cleaned) &&
        !localRegex.hasMatch(cleaned) &&
        !shortRegex.hasMatch(cleaned)) {
      return 'Please enter a valid Ethiopian phone number';
    }
    return null;
  }

  /// Validates a password.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validates a required field.
  static String? validateRequired(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates passenger name (no special characters except spaces, hyphens, apostrophes).
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\u1200-\u137F\s'\-]+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Please enter a valid name';
    }
    return null;
  }
}
