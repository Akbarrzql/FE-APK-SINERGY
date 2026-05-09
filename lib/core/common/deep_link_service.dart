import 'dart:collection';

class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  final Set<String> _handledLinks = HashSet<String>();
  Uri? _pendingLink;
  bool _bypassSplash = false;

  Uri? get pendingLink => _pendingLink;

  bool get bypassSplash => _bypassSplash;

  void markBypassSplash() {
    _bypassSplash = true;
  }

  void clearBypassSplash() {
    _bypassSplash = false;
  }

  bool wasHandled(Uri uri) => _handledLinks.contains(uri.toString());

  void markHandled(Uri uri) {
    _handledLinks.add(uri.toString());
  }

  Uri? normalize(Uri? uri) {
    if (uri == null) return null;

    final nestedLink = uri.queryParameters['link'];
    if (nestedLink != null && nestedLink.isNotEmpty) {
      final nestedUri = Uri.tryParse(nestedLink);
      if (nestedUri != null) {
        return nestedUri;
      }
    }

    return uri;
  }

  void storePending(Uri uri) {
    _pendingLink = normalize(uri);
  }

  Uri? takePending() {
    final uri = _pendingLink;
    _pendingLink = null;
    return uri;
  }

  bool shouldOpenResetPassword(Uri uri) {
    if (uri.queryParameters['oobCode'] != null) return true;

    final segments = uri.pathSegments.map((segment) => segment.toLowerCase()).toList();
    return segments.contains('reset-password') ||
        segments.contains('reset_password') ||
        segments.contains('forgot-password');
  }
}

