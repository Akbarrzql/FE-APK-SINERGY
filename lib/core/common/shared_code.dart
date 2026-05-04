import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedCode {
  static const String authTokenKey = 'token';
  static const String authTokenExpiredAtKey = 'token_expired_at';

  String? emptyValidator(value) {
    return value.toString().trim().isEmpty ? 'Bidang tidak boleh kosong' : null;
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
    bool emailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    return !emailValid ? 'Email tidak valid' : null;
  }

  String? passwordValidator(value) {
    return value.toString().length < 6
        ? 'Kata sandi tidak boleh kurang dari 6 karakter'
        : null;
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