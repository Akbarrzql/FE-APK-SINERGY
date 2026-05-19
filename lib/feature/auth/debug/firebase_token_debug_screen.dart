import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gabungyuk/feature/auth/service/firebase_auth_token_service.dart';

/// 🔐 DEBUG SCREEN - Firebase ID Token Viewer
///
/// Screen ini hanya ditampilkan di debug mode untuk memudahkan developer
/// melihat dan mencopy Firebase ID Token untuk testing backend
///
/// Akses: Bisa ditambahkan di Settings atau Debug menu
class FirebaseTokenDebugScreen extends StatefulWidget {
  const FirebaseTokenDebugScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseTokenDebugScreen> createState() => _FirebaseTokenDebugScreenState();
}

class _FirebaseTokenDebugScreenState extends State<FirebaseTokenDebugScreen> {
  String? _currentToken;
  String? _userEmail;
  String _statusMessage = '';
  final List<String> _tokenHistory = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentToken();
    _loadUserInfo();
  }

  Future<void> _loadCurrentToken() async {
    try {
      final token = await FirebaseAuthTokenService.instance.getIdTokenWithRefresh();

      if (token != null) {
        setState(() {
          _currentToken = token;
          _statusMessage = '✅ Token berhasil diambil';
          if (!_tokenHistory.contains(token)) {
            _tokenHistory.insert(0, token);
          }
        });
      } else {
        setState(() {
          _statusMessage = '❌ Tidak ada token (user mungkin belum login)';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuthTokenService.instance.getCurrentUser();
      if (user != null) {
        setState(() {
          _userEmail = user.email ?? 'N/A';
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading user info: $e');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Token copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _decodeToken() {
    if (_currentToken == null) return;

    try {
      final parts = _currentToken!.split('.');
      if (parts.length != 3) throw Exception('Invalid JWT format');

      final header = utf8.decode(base64Url.decode(base64Url.normalize(parts[0])));
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('🔍 Token Details')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Header:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(header, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  ),
                ),
                const Text('Payload:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(payload, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error decoding token: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 Firebase ID Token Debug'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            _buildInfoCard(
              'Current User',
              _userEmail ?? 'Not authenticated',
              Colors.blue,
            ),
            const SizedBox(height: 16),

            // Status
            _buildInfoCard(
              'Status',
              _statusMessage,
              _statusMessage.contains('✅') ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),

            // Current Token
            Text(
              'Current Token',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            if (_currentToken != null) ...[
              // Token Preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      _currentToken!.substring(0, 50) + '...',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _copyToClipboard(_currentToken!),
                            icon: const Icon(Icons.content_copy),
                            label: const Text('Copy Full Token'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _decodeToken,
                          icon: const Icon(Icons.visibility),
                          label: const Text('Decode'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadCurrentToken,
                child: const Text('🔄 Refresh Token'),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Text(
                  'ℹ️ Login terlebih dahulu untuk melihat token',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            const SizedBox(height: 24),

            // Token History
            if (_tokenHistory.isNotEmpty) ...[
              Text(
                'Token History (${_tokenHistory.length})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tokenHistory.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final token = _tokenHistory[index];
                  return ListTile(
                    title: Text(
                      token.substring(0, 50) + '...',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.content_copy),
                      onPressed: () => _copyToClipboard(token),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Instructions
            _buildInstructionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📖 How to Use Token in Backend',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        const Text(
          '1. Copy the token above using the "Copy Full Token" button\n'
          '2. Add header di request API:\n'
          '   Authorization: Bearer <token>\n'
          '3. Backend akan verify token dengan Firebase Admin SDK\n'
          '4. Extract user info dari token payload (uid, email, dll)',
          style: TextStyle(height: 1.6),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            'Example:\n'
            'curl -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..." \\\n'
            'https://api.example.com/user',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}


