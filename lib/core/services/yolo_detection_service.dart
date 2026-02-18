import 'dart:typed_data';

/// Minimal YOLO/heuristic stub to satisfy HybridVisionService dependencies.
class YoloDetectionService {
  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<bool> initialize() async {
    _initialized = true;
    return true;
  }

  Future<YoloDetectionResult> detectFromBytes(Uint8List imageBytes) async {
    // Return an empty detection result (offline heuristic placeholder)
    return YoloDetectionResult(
      detections: const [],
      isModelBased: false,
      visualHeuristics: VisualHeuristics(),
      imageQuality: ImageQuality(blurScore: 0.1, lighting: 'normal', occlusionLevel: 'low'),
    );
  }

  void dispose() {}
}

class YoloDetectionResult {
  final List<YoloDetection> detections;
  final bool isModelBased;
  final VisualHeuristics? visualHeuristics;
  final ImageQuality? imageQuality;
  final String? error;

  YoloDetectionResult({
    required this.detections,
    required this.isModelBased,
    this.visualHeuristics,
    this.imageQuality,
    this.error,
  });

  bool get hasDetections => detections.isNotEmpty;
  bool get hasError => error != null;

  Map<String, dynamic> toPreprocessedJson() => {
    'is_model_based': isModelBased,
    'detections': detections.map((d) => d.toJson()).toList(),
    if (visualHeuristics != null) 'visual_heuristics': visualHeuristics!.toJson(),
    if (imageQuality != null) 'image_quality': imageQuality!.toJson(),
  };
}

class YoloDetection {
  final String label;
  final double confidence;
  final int estimatedCount;

  YoloDetection({
    required this.label,
    required this.confidence,
    required this.estimatedCount,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'confidence': confidence,
    'estimated_count': estimatedCount,
  };
}

class VisualHeuristics {
  final bool burnMarksDetected;
  final bool rustDetected;
  final bool oxidationDetected;
  final bool discolorationDetected;

  VisualHeuristics({
    this.burnMarksDetected = false,
    this.rustDetected = false,
    this.oxidationDetected = false,
    this.discolorationDetected = false,
  });

  Map<String, dynamic> toJson() => {
    'burn_marks_detected': burnMarksDetected,
    'rust_detected': rustDetected,
    'oxidation_detected': oxidationDetected,
    'discoloration_detected': discolorationDetected,
  };
}

class ImageQuality {
  final double blurScore;
  final String lighting;
  final String occlusionLevel;

  ImageQuality({
    required this.blurScore,
    required this.lighting,
    required this.occlusionLevel,
  });

  Map<String, dynamic> toJson() => {
    'blur_score': blurScore,
    'lighting': lighting,
    'occlusion_level': occlusionLevel,
  };
}
