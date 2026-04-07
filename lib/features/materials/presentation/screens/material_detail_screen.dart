import 'package:flutter/material.dart';

class MaterialDetailScreen extends StatelessWidget {
  final String materialId;
  const MaterialDetailScreen({super.key, required this.materialId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material Details')),
      body: Center(child: Text('Material Detail\n\nID: $materialId\n\nPhotos, specs, lifecycle\nComing Soon!', 
                              textAlign: TextAlign.center, style: const TextStyle(fontSize: 18))),
    );
  }
}