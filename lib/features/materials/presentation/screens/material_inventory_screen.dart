import 'package:flutter/material.dart';

class MaterialInventoryScreen extends StatelessWidget {
  const MaterialInventoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material Inventory')),
      body: const Center(child: Text('Material Inventory\n\nAll detected materials\nFilters and search\nComing Soon!', 
                                    textAlign: TextAlign.center, style: TextStyle(fontSize: 18))),
    );
  }
}