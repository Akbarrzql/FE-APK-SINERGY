import 'package:flutter/material.dart';

class TeskScreen extends StatefulWidget {
  const TeskScreen({super.key});

  @override
  State<TeskScreen> createState() => _TeskScreenState();
}

class _TeskScreenState extends State<TeskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
            "Collaboration Screen"
        ),
      ),
    );
  }
}
