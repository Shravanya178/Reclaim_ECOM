import 'package:flutter/material.dart';

class RequestCreationScreen extends StatelessWidget {
  const RequestCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Request'),
      ),
      body: const Center(
        child: Text(
          'Request Creation Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}