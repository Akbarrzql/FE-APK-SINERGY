import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/api_exception.dart';

class AppUiHelper {
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const EdgeInsets snackBarMargin = EdgeInsets.fromLTRB(16, 0, 16, 24);
  static const double dialogRadius = 16;
  static const double sheetRadius = 20;

  static void showSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = const Color(0xFF2F80ED),
  }) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: snackBarMargin,
        duration: snackBarDuration,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 6,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    final displayMessage = _looksIndonesian(message) ? message : toIndonesianMessage(message);
    showSnackBar(
      context,
      displayMessage,
      backgroundColor: Colors.red.shade600,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green.shade600,
    );
  }

  static void showInfo(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFF2F80ED),
    );
  }

  static Future<T?> showAppDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        content: content,
        actions: actions,
      ),
    );
  }

  static Future<T?> showAppBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(sheetRadius)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  if (title != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    const SizedBox(height: 12),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String readableError(Object error, {String? fallback}) {
    if (error is ApiException) {
      return error.message;
    }
    
    String errorString = error.toString();

    // 1. Jika mengandung tag Firebase [firebase_auth/...]
    // Kita simpan kodenya untuk dicek di toIndonesianMessage sebelum dibersihkan
    if (errorString.contains('[') && errorString.contains(']')) {
      return toIndonesianMessage(errorString, fallback: fallback);
    }

    // 2. Bersihkan prefix Exception atau ApiException
    errorString = errorString.replaceAll('ApiException:', '').replaceAll('Exception:', '').trim();
    
    return toIndonesianMessage(errorString, fallback: fallback);
  }

  static String toIndonesianMessage(String message, {String? fallback}) {
    final normalized = message.trim();
    if (normalized.isEmpty) return fallback ?? 'Terjadi kesalahan. Silakan coba lagi.';

    final lower = normalized.toLowerCase();

    // -- Authentication & Session --
    if (lower.contains('invalid token') || lower.contains('token tidak valid')) {
      return 'Sesi Anda tidak valid. Silakan masuk kembali.';
    }
    if (lower.contains('invalid email or password') || 
        lower.contains('email atau password salah') ||
        lower.contains('invalid-credential') ||
        lower.contains('user-not-found') ||
        lower.contains('malformed or has expired')) {
      return 'Email atau password salah. Silakan coba lagi.';
    }
    if (lower.contains('email already exists') || lower.contains('already exists')) {
      return 'Email ini sudah digunakan. Silakan gunakan email lain.';
    }
    if (lower.contains('too many requests')) {
      return 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
    }
    if (lower.contains('unauthorized')) {
      return 'Anda belum memiliki akses. Silakan masuk kembali.';
    }
    if (lower.contains('forbidden')) {
      return 'Akses ditolak. Silakan coba lagi.';
    }

    // -- Network & Server --
    if (lower.contains('network') || lower.contains('socket') || lower.contains('timeout')) {
      return 'Koneksi bermasalah. Periksa internet Anda lalu coba lagi.';
    }
    if (lower.contains('format respons tidak valid') || lower.contains('invalid response format')) {
      return 'Format respons server tidak valid. Silakan coba lagi.';
    }
    if (lower.contains('500') || lower.contains('internal server error')) {
      return 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
    }
    if (lower.contains('502') || lower.contains('bad gateway')) {
      return 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
    }
    if (lower.contains('login dibatalkan') ||
        lower.contains('sign_in_canceled') ||
        lower.contains('sign_in_cancelled') ||
        lower.contains('cancelled by user') ||
        lower.contains('canceled by user')) {
      return 'Aksi dibatalkan.';
    }
    return normalized;
  }

  static bool _looksIndonesian(String message) {
    final lower = message.toLowerCase();
    const hints = [
      'silakan',
      'password',
      'sandi',
      'email',
      'akun',
      'terjadi kesalahan',
      'periksa',
      'masukkan',
      'tidak valid',
      'berhasil',
      'gagal',
    ];
    return hints.any(lower.contains);
  }
}

