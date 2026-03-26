import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reclaim/core/theme/app_theme.dart';

class AIMaterialDetection extends StatefulWidget {
  const AIMaterialDetection({super.key});

  @override
  State<AIMaterialDetection> createState() => _AIMaterialDetectionState();
}

class _AIMaterialDetectionState extends State<AIMaterialDetection>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  bool _isAnalyzing = false;
  AIAnalysisResult? _analysisResult;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  final ImagePicker _picker = ImagePicker();

  final List<AIAnalysisResult> _sampleResults = [
    AIAnalysisResult(
      detected: 'Arduino Uno R3',
      condition: 'Good',
      confidence: 94,
      suggestedUse: 'Electronics Projects, IoT Development, Prototyping',
      estimatedValue: '₹1,200 - ₹1,500',
      compatibility: ['Breadboard', 'Sensors', 'Motors', 'LCD Displays'],
      tips: 'Perfect for beginners. Check if USB cable is included.',
    ),
    AIAnalysisResult(
      detected: 'Raspberry Pi 4',
      condition: 'Excellent',
      confidence: 98,
      suggestedUse: 'Mini Computer Projects, Home Automation, AI/ML',
      estimatedValue: '₹4,000 - ₹5,000',
      compatibility: ['MicroSD Card', 'HDMI Cable', 'Power Supply', 'GPIO Sensors'],
      tips: 'High-performance board. Ensure proper cooling for intensive tasks.',
    ),
    AIAnalysisResult(
      detected: 'Breadboard (Half-size)',
      condition: 'Fair',
      confidence: 87,
      suggestedUse: 'Circuit Prototyping, Electronics Learning',
      estimatedValue: '₹100 - ₹200',
      compatibility: ['Jumper Wires', 'Arduino', 'Electronic Components'],
      tips: 'Check for loose connections. Clean contact points if needed.',
    ),
    AIAnalysisResult(
      detected: 'Ultrasonic Sensor HC-SR04',
      condition: 'Good',
      confidence: 91,
      suggestedUse: 'Distance Measurement, Obstacle Detection, Robotics',
      estimatedValue: '₹250 - ₹350',
      compatibility: ['Arduino', 'Raspberry Pi', 'Microcontrollers'],
      tips: 'Test with simple distance measurement code before use.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
        });
        _simulateAIAnalysis();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _simulateAIAnalysis() {
    setState(() {
      _isAnalyzing = true;
    });

    _animationController.repeat();

    // Simulate AI processing time
    Future.delayed(
      Duration(milliseconds: 2000 + (DateTime.now().millisecond % 1500)),
      () {
        if (mounted) {
          final randomResult = _sampleResults[
              DateTime.now().millisecond % _sampleResults.length];
          
          setState(() {
            _analysisResult = randomResult;
            _isAnalyzing = false;
          });
          
          _animationController.stop();
          _animationController.reset();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Material Detection',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload an image to automatically identify materials and get detailed information',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Upload Area
          _buildUploadArea(),

          if (_isAnalyzing) ...[
            const SizedBox(height: 24),
            _buildAnalyzingState(),
          ],

          if (_analysisResult != null && !_isAnalyzing) ...[
            const SizedBox(height: 24),
            _buildAnalysisResults(),
          ],

          const SizedBox(height: 24),
          _buildFeatureInfo(),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return Container(
      width: double.infinity,
      height: _selectedImage != null ? 250 : 200,
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5EFE8),
          style: BorderStyle.solid,
        ),
      ),
      child: _selectedImage != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImage = null;
                        _analysisResult = null;
                        _isAnalyzing = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: AppTheme.textSecondary.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Drop an image here or click to upload',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Supports JPG, PNG up to 10MB',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, size: 16),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, size: 16),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildAnalyzingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _progressAnimation.value * 2 * 3.14159,
                child: Icon(
                  Icons.auto_awesome,
                  size: 32,
                  color: AppTheme.primaryGreen,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'AI is analyzing your image...',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            backgroundColor: const Color(0xFFE5EFE8),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    final result = _analysisResult!;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: const Color(0xFFE5EFE8)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Detection Results',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${result.confidence}% confident',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Results
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Key Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Detected Material',
                        result.detected,
                        AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        'Condition',
                        result.condition,
                        _getConditionColor(result.condition),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  'Estimated Value',
                  result.estimatedValue,
                  AppTheme.success,
                ),

                const SizedBox(height: 20),

                // Suggested Use
                _buildSectionCard(
                  'Suggested Use Cases',
                  result.suggestedUse,
                  AppTheme.success,
                ),

                const SizedBox(height: 16),

                // Compatibility
                Text(
                  'Compatible With',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: result.compatibility.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.secondary.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: AppTheme.secondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pro Tip',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              result.tips,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(
                top: BorderSide(color: Color(0xFFE5EFE8)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Find similar items feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('Find Similar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Add to inventory feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.inventory_2_outlined, size: 16),
                    label: const Text('Add to Inventory'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, String content, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🤖 AI Detection Features:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Identifies 500+ electronic components and materials\n'
            '• Estimates condition and market value\n'
            '• Suggests compatible components and use cases\n'
            '• Works with photos from any angle',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'excellent':
        return AppTheme.success;
      case 'good':
        return AppTheme.primaryGreen;
      case 'fair':
        return AppTheme.warning;
      case 'poor':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }
}

class AIAnalysisResult {
  final String detected;
  final String condition;
  final int confidence;
  final String suggestedUse;
  final String estimatedValue;
  final List<String> compatibility;
  final String tips;

  AIAnalysisResult({
    required this.detected,
    required this.condition,
    required this.confidence,
    required this.suggestedUse,
    required this.estimatedValue,
    required this.compatibility,
    required this.tips,
  });
}