import 'package:flutter/material.dart';

class MaterialsFeedScreen extends StatelessWidget {
  const MaterialsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials Feed'),
      ),
      body: const Center(
        child: Text(
          'Materials Feed Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}