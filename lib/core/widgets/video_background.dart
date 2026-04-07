import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class VideoBackground extends StatefulWidget {
  final Widget child;
  final String? videoPath;
  final BoxFit fit;
  final double opacity;
  
  const VideoBackground({
    super.key,
    required this.child,
    this.videoPath = 'assets/videos/26070-357512237_medium.mp4',
    this.fit = BoxFit.cover,
    this.opacity = 0.7,
  });

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  bool _isVideoSupported = false;
  bool _videoLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkVideoSupport();
  }

  void _checkVideoSupport() {
    // For web, we'll use HTML video element
    // For mobile, we'll use a fallback gradient
    if (kIsWeb) {
      setState(() {
        _isVideoSupported = true;
      });
    }
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
        
        // Video background for web
        if (_isVideoSupported && kIsWeb)
          Positioned.fill(
            child: _WebVideoBackground(
              videoPath: widget.videoPath!,
              fit: widget.fit,
              opacity: widget.opacity,
              onVideoLoaded: () {
                setState(() {
                  _videoLoaded = true;
                });
              },
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
                const Color(0xFF1B4332).withOpacity(0.8),
                const Color(0xFF2D6A4F).withOpacity(0.6),
                const Color(0xFF40916C).withOpacity(0.4),
                const Color(0xFF1B4332).withOpacity(0.8),
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

class _WebVideoBackground extends StatefulWidget {
  final String videoPath;
  final BoxFit fit;
  final double opacity;
  final VoidCallback onVideoLoaded;

  const _WebVideoBackground({
    required this.videoPath,
    required this.fit,
    required this.opacity,
    required this.onVideoLoaded,
  });

  @override
  State<_WebVideoBackground> createState() => _WebVideoBackgroundState();
}

class _WebVideoBackgroundState extends State<_WebVideoBackground> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initializeWebVideo();
    }
  }

  void _initializeWebVideo() {
    // This will be handled by the HTML video element
    // We'll inject the video element into the DOM
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onVideoLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    return Opacity(
      opacity: widget.opacity,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: kIsWeb
            ? _buildWebVideo()
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildWebVideo() {
    // For web, we'll use HtmlElementView to embed video
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: const Center(
        child: Text(
          'Video Background Loading...',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}