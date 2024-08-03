import 'package:flutter/material.dart';

class SpashScreen extends StatelessWidget {
  const SpashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat'),
      ),
      body: const Center(
        child: Text('Loading...'),
      ),
    );
  }
}
