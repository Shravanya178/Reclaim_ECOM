import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:reclaim/core/services/hybrid_vision.dart';

class MaterialCaptureScreen extends StatefulWidget {
  const MaterialCaptureScreen({super.key});

  @override
  State<MaterialCaptureScreen> createState() => _MaterialCaptureScreenState();
}

class _MaterialCaptureScreenState extends State<MaterialCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isAnalyzing = false;
  HybridAnalysisResult? _result;
  String? _error;
  bool get _isDesktop => MediaQuery.of(context).size.width > 768;

  Future<void> _pickImage(ImageSource source) async {
    setState(() { _error = null; });
    final xFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (xFile != null) {
      setState(() { _imageFile = File(xFile.path); });
    }
  }

  Future<void> _analyze() async {
    if (_imageFile == null) return;
    setState(() { _isAnalyzing = true; _error = null; _result = null; });

    final hv = HybridVisionService();
    await hv.initialize();
    final res = await hv.analyzeImage(_imageFile!);

    setState(() { _isAnalyzing = false; _result = res; _error = res.hasError ? res.error : null; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDesktop ? Colors.grey.shade100 : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Capture Materials'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(_isDesktop ? 24 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Container(
              padding: _isDesktop ? EdgeInsets.all(24) : EdgeInsets.zero,
              decoration: _isDesktop ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ) : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Camera'))),
                      const SizedBox(width: 12),
                      Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('Gallery'))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
                    )
                  else
                    Container(
                      height: 200,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade100),
                      child: const Text('No image selected'),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(onPressed: _imageFile == null || _isAnalyzing ? null : _analyze, icon: const Icon(Icons.auto_awesome), label: const Text('Analyze')),
                  const SizedBox(height: 12),
                  if (_isAnalyzing) const LinearProgressIndicator(),
                  if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  _buildResults(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_result == null || _result!.hasError) {
      return const SizedBox.shrink();
    }
    final r = _result!;
    return ListView(
      children: [
        Text('Source: ${r.sourceDescription}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (r.overallNotes.isNotEmpty) Text(r.overallNotes),
        const SizedBox(height: 12),
        Text('Recommended: ${r.recommendedNextStep}'),
        const SizedBox(height: 12),
        Text('Detected Materials', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...r.materials.map((m) => ListTile(
          leading: const Icon(Icons.inventory_2_outlined),
          title: Text(m.materialType),
          subtitle: Text('${m.estimatedQuantity} • ${m.reuseSuitability}'),
        )),
        const SizedBox(height: 12),
        if (r.suggestedProjects.isNotEmpty) ...[
          Text('Suggested Projects', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...r.suggestedProjects.map((p) => ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: Text(p.name),
            subtitle: Text(p.description),
          )),
        ],
      ],
    );
  }
}
