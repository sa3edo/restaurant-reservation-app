class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Invalid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if(value.length < 3){
      return "name must be 3 characters or more";
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.length < 11) {
      return 'Invalid phone number';
    }
    return null;
  }
}
