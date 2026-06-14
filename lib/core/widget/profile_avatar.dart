import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? fullName;
  final double size;
  final double fontSize;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.fullName,
    this.size = 50,
    this.fontSize = 18,
  });

  String get initials {
    if (fullName == null || fullName!.isEmpty) return '??';
    final parts = fullName!.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].length >= 2
        ? parts[0].substring(0, 2).toUpperCase()
        : parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final source = imageUrl?.trim() ?? '';

    Widget placeholder = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );

    if (source.isEmpty) {
      return placeholder;
    }

    // Base64 handling
    if (source.startsWith('data:') || (!source.startsWith('http://') && !source.startsWith('https://'))) {
      try {
        String b64 = source;
        if (source.startsWith('data:')) {
          final parts = source.split(',');
          b64 = parts.length > 1 ? parts[1] : '';
        }
        final bytes = base64Decode(b64);
        return ClipOval(
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) => placeholder,
          ),
        );
      } catch (_) {
        return placeholder;
      }
    }

    // Network Image
    return ClipOval(
      child: Image.network(
        source,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}
