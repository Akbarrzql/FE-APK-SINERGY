import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedCode {
  static const String authTokenKey = 'token';
  static const String authTokenExpiredAtKey = 'token_expired_at';

  String? emptyValidator(value) {
    return value.toString().trim().isEmpty ? 'Masukkan tidak boleh kosong' : null;
  }

  String? nameValidator(value) {
    bool nameValid = RegExp(r'[0-9]').hasMatch(value);

    if (nameValid) {
      return 'Nama tidak boleh mengandung angka';
    } else if (value.toString().trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    } else {
      return null;
    }
  }

  String? emailValidator(value) {
    final v = value?.toString().trim() ?? '';
    if (v.isEmpty) return 'Email tidak boleh kosong';
    
    // Standard RFC 5322 regex for email
    bool emailValid = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
        .hasMatch(v);
        
    return !emailValid ? 'Format email tidak valid' : null;
  }

  String? passwordValidator(value) {
    final v = value?.toString() ?? '';
    if (v.isEmpty) return 'Kata sandi tidak boleh kosong';
    if (v.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    
    // Must contain at least one letter and one number
    bool hasLetter = v.contains(RegExp(r'[a-zA-Z]'));
    bool hasNumber = v.contains(RegExp(r'[0-9]'));
    
    if (!hasLetter || !hasNumber) {
      return 'Kata sandi harus kombinasi huruf dan angka';
    }
    
    return null;
  }

  String? confirmPasswordValidator(value, password) {
    final v = value?.toString() ?? '';
    if (v.isEmpty) return 'Konfirmasi kata sandi tidak boleh kosong';
    if (v != password) {
      return 'Kata sandi tidak cocok';
    }
    return null;
  }

  String? urlValidator(value) {
    final v = value?.toString().trim() ?? '';
    if (v.isEmpty) return null;
    
    // Simple but effective URL regex
    bool urlValid = RegExp(
        r"^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$")
        .hasMatch(v);
        
    return !urlValid ? 'Format link tidak valid (gunakan http/https)' : null;
  }

  // Validator untuk form kolaborasi (create / edit)
  String? titleValidator(value) {
    final v = value?.toString() ?? '';
    if (v.trim().isEmpty) {
      return 'Judul tidak boleh kosong';
    }
    if (v.trim().length < 3) {
      return 'Judul terlalu pendek (minimal 3 karakter)';
    }
    return null;
  }

  String? descriptionValidator(value) {
    final v = value?.toString() ?? '';
    if (v.trim().isEmpty) {
      return 'Deskripsi tidak boleh kosong';
    }
    if (v.trim().length < 10) {
      return 'Deskripsi terlalu pendek (minimal 10 karakter)';
    }
    return null;
  }

  String? categoryValidator(value) {
    final v = value?.toString() ?? '';
    if (v.trim().isEmpty) {
      return 'Kategori tidak boleh kosong';
    }
    if (!isITSector(v)) {
      return 'Kategori harus dalam lingkup IT';
    }
    return null;
  }

  static const List<String> itScopeCategories = [
    // Development
    'Web Development',
    'Mobile Development',
    'Frontend Development',
    'Backend Development',
    'Fullstack Development',
    'Game Development',
    'Embedded Systems',
    'Desktop Development',
    'App Development',
    'Software Engineering',
    'Mobile Dev',
    'Web Dev',
    
    // Design
    'UI/UX Design',
    'Graphic Design',
    'Product Design',
    'Interaction Design',
    'Visual Design',
    'Web Design',
    
    // Data & AI
    'Data Science',
    'Artificial Intelligence',
    'Machine Learning',
    'Deep Learning',
    'Data Analyst',
    'Data Engineer',
    'Business Intelligence',
    'Big Data',
    'Natural Language Processing',
    'Computer Vision',
    
    // Infrastructure & Ops
    'Cloud Computing',
    'DevOps',
    'Cyber Security',
    'Network Engineer',
    'System Administrator',
    'Database Administrator',
    'Information Security',
    'Site Reliability Engineering',
    'IT Support',
    
    // Others
    'Internet of Things (IoT)',
    'Quality Assurance',
    'Blockchain',
    'Project Management',
    'Product Management',
    'Agile',
    'Scrum',
    'Digital Marketing',
    'SEO',
  ];

  /// Intelligent IT Sector check
  static bool isITSector(String value) {
    if (value.trim().isEmpty) return false;
    
    final lowerValue = value.toLowerCase().trim();
    
    // 1. Direct or partial match with the predefined list
    bool directMatch = itScopeCategories.any((cat) {
      final lowerCat = cat.toLowerCase();
      return lowerValue == lowerCat || 
             lowerValue.contains(lowerCat) || 
             lowerCat.contains(lowerValue);
    });
    
    if (directMatch) return true;

    // 2. Keyword-based matching for more flexibility
    final List<String> itKeywords = [
      'developer', 'dev', 'engineer', 'programmer', 'coding', 'code',
      'design', 'data', 'analytics', 'intelligence', 'security', 'cyber',
      'cloud', 'network', 'system', 'admin', 'software', 'hardware',
      'web', 'mobile', 'android', 'ios', 'flutter', 'react', 'java', 'python',
      'javascript', 'php', 'golang', 'kotlin', 'swift', 'c++', 'c#', 'ruby',
      'ai', 'ml', 'nlp', 'automation', 'test', 'qa', 'ux', 'ui', 'product',
      'tech', 'digital', 'base', 'computing', 'api', 'server', 'linux'
    ];

    return itKeywords.any((keyword) => lowerValue.contains(keyword));
  }

  Future<bool> setToken(String token, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(token, value);
  }

  Future<String> getToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(token) ?? '';
  }

  Future<bool> saveAuthSession({
    required String token,
    required int expiredAt,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final tokenSaved = await prefs.setString(authTokenKey, token);
    final expiredSaved = await prefs.setInt(authTokenExpiredAtKey, expiredAt);
    return tokenSaved && expiredSaved;
  }

  int? _extractJwtExp(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> json = jsonDecode(payload);
      final exp = json['exp'];
      if (exp is int) return exp;
      if (exp is String) return int.tryParse(exp);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveFirebaseAuthSession({
    required String token,
  }) async {
    final expFromToken = _extractJwtExp(token);
    // Fallback 55 menit agar session checker tidak langsung menganggap expired.
    final fallbackExpSeconds =
        DateTime.now().add(const Duration(minutes: 55)).millisecondsSinceEpoch ~/ 1000;

    return saveAuthSession(
      token: token,
      expiredAt: expFromToken ?? fallbackExpSeconds,
    );
  }

  Future<String> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(authTokenKey) ?? '';
  }

  Future<int?> getAuthTokenExpiredAt() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(authTokenExpiredAtKey);
  }

  Future<bool> clearAuthSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final removedToken = await prefs.remove(authTokenKey);
    final removedExpiredAt = await prefs.remove(authTokenExpiredAtKey);
    return removedToken && removedExpiredAt;
  }

  Future<bool> isAuthSessionExpired() async {
    final expiredAt = await getAuthTokenExpiredAt();
    if (expiredAt == null) {
      return false;
    }

    final expirationDate = expiredAt > 9999999999
        ? DateTime.fromMillisecondsSinceEpoch(expiredAt)
        : DateTime.fromMillisecondsSinceEpoch(expiredAt * 1000);

    return DateTime.now().isAfter(expirationDate);
  }

  // String get uid => FirebaseAuth.instance.currentUser!.uid;

  String get day => DateFormat('EEE').format(DateTime.now()).toLowerCase();

  String get formattedDate =>
      '${DateTime.now().weekOfMonth}-${DateFormat('MM-yyy').format(DateTime.now())}';

  String getInitials(String name) => name.isNotEmpty
      ? name.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join()
      : '';

  String getPercentString(int budget, int expenditure) {
    double value = (double.parse('$expenditure') / double.parse('$budget')) * 100;
    if (value > 100) {
      return '100%';
    } else {
      return '${value.toInt()}%';
    }
  }

  double getPercentDouble(int budget, int expenditure) {
    double value = double.parse('$expenditure') / double.parse('$budget');
    if (value > 1) {
      return 1.0;
    } else {
      return value;
    }
  }
}

extension DateTimeExtension on DateTime {
  int get weekOfMonth {
    var date = this;
    final firstDayOfTheMonth = DateTime(date.year, date.month, 1);
    int sum = firstDayOfTheMonth.weekday - 1 + date.day;
    if (sum % 7 == 0) {
      return sum ~/ 7;
    } else {
      return sum ~/ 7 + 1;
    }
  }
}