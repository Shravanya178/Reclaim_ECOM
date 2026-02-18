import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'yolo_detection_service.dart';
import 'gemini_vision_service.dart';

/// Hybrid Vision Intelligence Service
/// Combines YOLO (offline) and Gemini (online) for comprehensive material analysis
class HybridVisionService {
  static final HybridVisionService _instance = HybridVisionService._internal();
  factory HybridVisionService() => _instance;
  HybridVisionService._internal();

  final YoloDetectionService _yoloService = YoloDetectionService();
  final GeminiVisionService _geminiService = GeminiVisionService();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get isYoloReady => _yoloService.isInitialized;
  bool get isGeminiReady => _geminiService.isInitialized;
  bool get hasGeminiApiKey => _geminiService.hasApiKey;

  /// Initialize both services
  Future<HybridInitResult> initialize({String? geminiApiKey}) async {
    bool yoloReady = false;
    bool geminiReady = false;
    
    // Initialize YOLO (works offline)
    print('Initializing YOLO service...');
    try {
      yoloReady = await _yoloService.initialize();
      print('YOLO ready: $yoloReady');
    } catch (e) {
      print('YOLO initialization failed: $e');
    }

    // Initialize Gemini (requires API key and internet)
    print('Initializing Gemini service...');
    try {
      geminiReady = await _geminiService.initialize(apiKey: geminiApiKey);
      print('Gemini ready: $geminiReady');
      
      if (geminiReady) {
        // List available models
        final models = await _geminiService.listAvailableModels();
        print('Available Gemini models: $models');
      }
    } catch (e) {
      print('Gemini initialization failed: $e');
    }

    _isInitialized = yoloReady || geminiReady;

    return HybridInitResult(
      yoloReady: yoloReady,
      geminiReady: geminiReady,
      message: _getInitMessage(yoloReady, geminiReady),
    );
  }

  String _getInitMessage(bool yolo, bool gemini) {
    if (yolo && gemini) {
      return 'Full hybrid mode: YOLO + Gemini ready';
    } else if (gemini) {
      return 'Gemini Vision ready (YOLO model not available)';
    } else if (yolo) {
      return 'YOLO ready (Gemini not configured - offline mode only)';
    } else {
      return 'No AI services available. Using basic heuristics.';
    }
  }

  /// Save Gemini API key
  Future<void> saveGeminiApiKey(String apiKey) async {
    await _geminiService.saveApiKey(apiKey);
  }

  /// Get stored Gemini API key
  Future<String?> getGeminiApiKey() async {
    return _geminiService.getStoredApiKey();
  }

  /// Analyze image with hybrid intelligence
  Future<HybridAnalysisResult> analyzeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return analyzeImageBytes(bytes);
  }

  /// Analyze image bytes with hybrid intelligence
  Future<HybridAnalysisResult> analyzeImageBytes(Uint8List imageBytes) async {
    final startTime = DateTime.now();
    
    // Step 1: Run YOLO/Heuristic detection (always available offline)
    YoloDetectionResult? yoloResult;
    try {
      yoloResult = await _yoloService.detectFromBytes(imageBytes);
    } catch (e) {
      print('YOLO detection failed: $e');
    }

    // Step 2: Check connectivity for Gemini
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult != ConnectivityResult.none;

    // Step 3: If Gemini is ready and we have internet, use it
    GeminiAnalysisResult? geminiResult;
    if (_geminiService.isInitialized && hasInternet) {
      try {
        if (yoloResult != null && yoloResult.hasDetections) {
          // Mode 2: Post-processing with YOLO data
          geminiResult = await _geminiService.analyzeWithPreprocessedData(
            imageBytes,
            yoloResult.toPreprocessedJson(),
          );
        } else {
          // Mode 1: Direct vision analysis
          geminiResult = await _geminiService.analyzeImageBytes(imageBytes);
        }
      } catch (e) {
        print('Gemini analysis failed: $e');
      }
    }

    final processingTime = DateTime.now().difference(startTime);

    // Determine which result to use
    if (geminiResult != null && !geminiResult.hasError) {
      // Use Gemini result (most comprehensive)
      return HybridAnalysisResult(
        success: true,
        source: yoloResult?.hasDetections == true ? 'hybrid' : 'gemini',
        materials: geminiResult.materialsDetected,
        suggestedProjects: geminiResult.suggestedProjects,
        overallNotes: geminiResult.overallNotes,
        recommendedNextStep: geminiResult.recommendedNextStep,
        processingMode: geminiResult.processingMode,
        yoloDetections: yoloResult,
        rawGeminiResponse: geminiResult.rawJson,
        processingTimeMs: processingTime.inMilliseconds,
        isOnline: true,
      );
    } else if (yoloResult != null && !yoloResult.hasError) {
      // Fallback to YOLO/Heuristic result
      return HybridAnalysisResult(
        success: true,
        source: yoloResult.isModelBased ? 'yolo' : 'heuristic',
        materials: _convertYoloToMaterials(yoloResult),
        suggestedProjects: [], // No project suggestions in offline mode
        overallNotes: _generateYoloNotes(yoloResult),
        recommendedNextStep: 'Route to manual inspection queue',
        processingMode: 'offline_detection',
        yoloDetections: yoloResult,
        processingTimeMs: processingTime.inMilliseconds,
        isOnline: false,
        offlineWarning: geminiResult?.error ?? 
          (hasInternet ? 'Gemini not configured' : 'No internet connection'),
      );
    } else {
      // Both failed
      return HybridAnalysisResult.error(
        geminiResult?.error ?? yoloResult?.error ?? 'Analysis failed',
      );
    }
  }

  List<MaterialAnalysis> _convertYoloToMaterials(YoloDetectionResult yoloResult) {
    return yoloResult.detections.map((detection) {
      // Map YOLO labels to material types
      final materialType = _mapLabelToMaterialType(detection.label);
      
      // Determine safety based on material type
      String safetyFlag = 'Safe (Visual)';
      if (materialType.contains('Battery')) {
        safetyFlag = 'Caution';
      } else if (materialType.contains('Chemical') || materialType.contains('Glass')) {
        safetyFlag = 'Restricted';
      }

      // Determine reusability based on heuristics
      String reusability = 'Likely Reusable';
      if (yoloResult.visualHeuristics?.burnMarksDetected == true) {
        reusability = 'Possibly Reusable (Manual Review Required)';
        safetyFlag = 'Caution';
      }
      if (yoloResult.visualHeuristics?.rustDetected == true) {
        reusability = 'Possibly Reusable (Manual Review Required)';
      }

      // Build defects list
      final defects = <String>[];
      if (yoloResult.visualHeuristics?.burnMarksDetected == true) {
        defects.add('burn marks detected');
      }
      if (yoloResult.visualHeuristics?.rustDetected == true) {
        defects.add('rust/corrosion present');
      }
      if (yoloResult.visualHeuristics?.oxidationDetected == true) {
        defects.add('oxidation visible');
      }
      if (yoloResult.visualHeuristics?.discolorationDetected == true) {
        defects.add('discoloration present');
      }

      return MaterialAnalysis(
        materialType: materialType,
        estimatedQuantity: _formatQuantity(detection.estimatedCount),
        estimatedSize: 'unknown (offline detection)',
        condition: ConditionAssessment(
          structural: defects.isEmpty ? 'High' : 'Medium',
          visibleDamage: defects.isEmpty ? 'None' : 'Minor',
          defects: defects,
        ),
        reuseSuitability: reusability,
        safetyFlag: safetyFlag,
        confidence: ConfidenceScores(
          materialIdentification: detection.confidence,
          conditionAssessment: detection.confidence * 0.8,
          quantityEstimation: detection.confidence * 0.7,
        ),
        reasoning: 'Detected via ${yoloResult.isModelBased ? "YOLO model" : "color heuristics"}. Manual verification recommended.',
      );
    }).toList();
  }

  String _mapLabelToMaterialType(String label) {
    final mapping = {
      'electronics': 'Electronic Components',
      'circuit_board': 'Printed Circuit Board (PCB)',
      'pcb': 'Printed Circuit Board (PCB)',
      'motor': 'Electric Motor',
      'metal': 'Metal Offcut (Unknown Alloy)',
      'aluminum': 'Metal Offcut (Aluminum)',
      'steel': 'Metal Offcut (Steel)',
      'copper': 'Metal Offcut (Copper)',
      'wood': 'Wooden Sheet / Block',
      'plastic': 'Plastic / Acrylic Panel',
      'acrylic': 'Acrylic Panel',
      'glass': 'Lab Glassware',
      'wire': 'Cables / Wires',
      'cable': 'Cables / Wires',
      'battery': 'Battery Pack',
      'screw': 'Fasteners (Screws)',
      'bolt': 'Fasteners (Bolts)',
      'tool': 'Hand Tools',
      'capacitor': 'Electronic Components (Capacitors)',
      'resistor': 'Electronic Components (Resistors)',
      'ic_chip': 'Electronic Components (ICs)',
      'connector': 'Connectors',
      'transformer': 'Transformer / Inductor',
      'gear': 'Mechanical Parts (Gears)',
      'bearing': 'Mechanical Parts (Bearings)',
      'shaft': 'Mechanical Parts (Shafts)',
      'bracket': 'Mechanical Parts (Brackets)',
    };
    return mapping[label.toLowerCase()] ?? 'Unknown Material (Manual Review Required)';
  }

  String _formatQuantity(int count) {
    if (count <= 1) return '1 unit';
    if (count <= 2) return '1-2 units';
    if (count <= 5) return '3-5 units';
    if (count <= 10) return '6-10 units';
    return '10+ units';
  }

  String _generateYoloNotes(YoloDetectionResult yoloResult) {
    final notes = <String>[];
    
    // Add detection source
    notes.add(yoloResult.isModelBased 
      ? 'Analysis performed using YOLO model (offline).'
      : 'Analysis performed using color heuristics (offline).');

    // Add image quality notes
    if (yoloResult.imageQuality != null) {
      final quality = yoloResult.imageQuality!;
      notes.add('Image quality: ${quality.lighting} lighting, ${quality.occlusionLevel} occlusion.');
      if (quality.blurScore > 0.3) {
        notes.add('Warning: Image appears blurry, confidence reduced.');
      }
    }

    // Add heuristic notes
    if (yoloResult.visualHeuristics != null) {
      final h = yoloResult.visualHeuristics!;
      if (h.burnMarksDetected) {
        notes.add('⚠ Burn marks detected - manual inspection required.');
      }
      if (h.rustDetected) {
        notes.add('⚠ Rust/corrosion detected - assess structural integrity.');
      }
    }

    notes.add('Gemini AI analysis unavailable - using offline detection. Full analysis available when online.');

    return notes.join(' ');
  }

  void dispose() {
    _yoloService.dispose();
  }
}

// Data classes

class HybridInitResult {
  final bool yoloReady;
  final bool geminiReady;
  final String message;

  HybridInitResult({
    required this.yoloReady,
    required this.geminiReady,
    required this.message,
  });

  bool get anyReady => yoloReady || geminiReady;
  bool get fullHybrid => yoloReady && geminiReady;
}

class HybridAnalysisResult {
  final bool success;
  final String source; // 'hybrid', 'gemini', 'yolo', 'heuristic'
  final List<MaterialAnalysis> materials;
  final List<ProjectSuggestion> suggestedProjects;
  final String overallNotes;
  final String recommendedNextStep;
  final String processingMode;
  final YoloDetectionResult? yoloDetections;
  final Map<String, dynamic>? rawGeminiResponse;
  final int processingTimeMs;
  final bool isOnline;
  final String? offlineWarning;
  final String? error;

  HybridAnalysisResult({
    required this.success,
    required this.source,
    required this.materials,
    this.suggestedProjects = const [],
    required this.overallNotes,
    required this.recommendedNextStep,
    required this.processingMode,
    this.yoloDetections,
    this.rawGeminiResponse,
    required this.processingTimeMs,
    required this.isOnline,
    this.offlineWarning,
  }) : error = null;

  HybridAnalysisResult.error(this.error)
      : success = false,
        source = 'none',
        materials = [],
        suggestedProjects = [],
        overallNotes = '',
        recommendedNextStep = '',
        processingMode = '',
        yoloDetections = null,
        rawGeminiResponse = null,
        processingTimeMs = 0,
        isOnline = false,
        offlineWarning = null;

  bool get hasError => error != null;
  bool get hasMaterials => materials.isNotEmpty;

  String get sourceDescription {
    switch (source) {
      case 'hybrid':
        return 'YOLO + Gemini AI';
      case 'gemini':
        return 'Gemini Vision AI';
      case 'yolo':
        return 'YOLO Model (Offline)';
      case 'heuristic':
        return 'Color Analysis (Offline)';
      default:
        return 'Unknown';
    }
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'source': source,
    'processing_mode': processingMode,
    'materials_detected': materials.map((m) => m.toJson()).toList(),
    'suggested_projects': suggestedProjects.map((p) => p.toJson()).toList(),
    'overall_notes': overallNotes,
    'recommended_next_step': recommendedNextStep,
    'processing_time_ms': processingTimeMs,
    'is_online': isOnline,
    if (offlineWarning != null) 'offline_warning': offlineWarning,
    if (error != null) 'error': error,
  };
}
