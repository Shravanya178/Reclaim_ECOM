import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:js' as js;

class WebVideoBackground extends StatefulWidget {
  final Widget child;
  final String videoPath;
  final double opacity;

  const WebVideoBackground({
    super.key,
    required this.child,
    this.videoPath = 'assets/videos/26070-357512237_medium.mp4',
    this.opacity = 0.7,
  });

  @override
  State<WebVideoBackground> createState() => _WebVideoBackgroundState();
}

class _WebVideoBackgroundState extends State<WebVideoBackground> {
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initializeVideoBackground();
    }
  }

  void _initializeVideoBackground() {
    try {
      // Call the JavaScript function to initialize video background
      js.context.callMethod('initVideoBackground', [
        widget.videoPath,
        widget.opacity,
      ]);
      
      setState(() {
        _videoInitialized = true;
      });
      
      print('Video background initialized: ${widget.videoPath}');
    } catch (e) {
      print('Failed to initialize video background: $e');
    }
  }

  @override
  void dispose() {
    if (kIsWeb && _videoInitialized) {
      try {
        js.context.callMethod('removeVideoBackground');
      } catch (e) {
        print('Failed to remove video background: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fallback gradient background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B4332),
                Color(0xFF2D6A4F),
                Color(0xFF40916C),
              ],
            ),
          ),
        ),

        // Overlay for better text readability
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1B4332).withOpacity(0.6),
                const Color(0xFF2D6A4F).withOpacity(0.4),
                const Color(0xFF40916C).withOpacity(0.3),
                const Color(0xFF1B4332).withOpacity(0.6),
              ],
            ),
          ),
        ),

        // Content
        widget.child,
      ],
    );
  }
}