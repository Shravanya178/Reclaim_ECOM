import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gemini Vision API service for intelligent material analysis
class GeminiVisionService {
  static final GeminiVisionService _instance = GeminiVisionService._internal();
  factory GeminiVisionService() => _instance;
  GeminiVisionService._internal();

  GenerativeModel? _model;
  String? _apiKey;
  bool _isInitialized = false;

  static const String _apiKeyPrefKey = 'gemini_api_key';
  
  // Hardcoded API key from .env
  static const String _defaultApiKey = 'AIzaSyDcn21C20DWW6XuniUP9B0FWm7JBudbI14';

  bool get isInitialized => _isInitialized;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  /// List available Gemini models
  Future<List<String>> listAvailableModels() async {
    try {
      final apiKey = _apiKey ?? _defaultApiKey;
      if (apiKey.isEmpty) {
        print('No API key available');
        return [];
      }
      
      final response = await HttpClient()
          .getUrl(Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey'))
          .then((request) => request.close())
          .then((response) => response.transform(utf8.decoder).join());
      
      final data = jsonDecode(response) as Map<String, dynamic>;
      final models = (data['models'] as List?)?.map((m) => m['name'] as String).toList() ?? [];
      
      print('Available Gemini models: $models');
      return models;
    } catch (e) {
      print('Failed to list models: $e');
      return [];
    }
  }

  /// The Hybrid Vision Intelligence System Prompt
  static const String systemPrompt = '''
You are an AI assistant for a campus circular economy material recovery system. Analyze images of materials for recyclability and reuse potential.

Return ONLY valid JSON in this exact format:

{
  "processing_mode": "direct_vision",
  "materials_detected": [
    {
      "material_type": "PCB|Electronics|Metal|Plastic|Cables|Tools|Other",
      "estimated_quantity": "1-2 units",
      "estimated_size": "small|medium|large",
      "condition": {
        "structural": "High|Medium|Low",
        "visible_damage": "None|Minor|Major",
        "defects": []
      },
      "reuse_suitability": "Likely Reusable|Needs Testing|Recycle Only",
      "safety_flag": "Safe (Visual)|Caution Required|Hazard Detected",
      "confidence": {
        "material_identification": 0.9,
        "condition_assessment": 0.85,
        "quantity_estimation": 0.8
      },
      "reasoning": "Brief explanation"
    }
  ],
  "suggested_projects": [
    {
      "name": "Project name",
      "description": "Brief description",
      "complexity": "Beginner|Intermediate|Advanced",
      "materials_used": ["material1", "material2"],
      "estimated_build_time": "2-4 hours",
      "category": "electronics|robotics|furniture|IoT|art|other"
    }
  ],
  "overall_notes": "Brief summary of findings",
  "recommended_next_step": "Approve for inventory|Needs Inspection|Recycle"
}

Guidelines:
- Focus on visible materials only
- Be conservative with safety assessments
- Provide realistic project suggestions based on detected materials
- Keep descriptions concise but informative
''';

  /// Initialize with API key
  Future<bool> initialize({String? apiKey}) async {
    try {
      // Try to get API key from parameter, then from storage, then use default
      _apiKey = apiKey;
      
      if (_apiKey == null || _apiKey!.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        _apiKey = prefs.getString(_apiKeyPrefKey);
      }

      // Use default API key if none provided
      if (_apiKey == null || _apiKey!.isEmpty) {
        _apiKey = _defaultApiKey;
      }

      if (_apiKey == null || _apiKey!.isEmpty) {
        print('Gemini API key not configured');
        _isInitialized = false;
        return false;
      }

      // List available models for debugging
      final availableModels = await listAvailableModels();
      print('Trying to initialize with available models: $availableModels');

      // Initialize the Gemini model - try multiple models in order
      String? workingModel;
      final modelsToTry = [
        'gemini-2.5-flash',
        'gemini-2.0-flash',
        'gemini-flash-latest',
        'gemini-2.5-pro',
        'gemini-2.0-flash-exp',
        'gemini-pro-latest',
      ];
      
      for (final modelName in modelsToTry) {
        try {
          print('Trying model: $modelName');
          _model = GenerativeModel(
            model: modelName,
            apiKey: _apiKey!,
            generationConfig: GenerationConfig(
              temperature: 0.2,
              topK: 32,
              topP: 0.8,
              maxOutputTokens: 4096,
            ),
          );
          workingModel = modelName;
          print('Successfully initialized with model: $modelName');
          break;
        } catch (e) {
          print('Model $modelName failed: $e');
          continue;
        }
      }
      
      if (workingModel == null) {
        print('All models failed to initialize');
        _isInitialized = false;
        return false;
      }

      _isInitialized = true;
      print('Gemini Vision service initialized');
      return true;
    } catch (e) {
      print('Failed to initialize Gemini: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Save API key to storage
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefKey, apiKey);
    _apiKey = apiKey;
    await initialize(apiKey: apiKey);
  }

  /// Get stored API key
  Future<String?> getStoredApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPrefKey);
  }

  /// Clear API key
  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPrefKey);
    _apiKey = null;
    _isInitialized = false;
  }

  /// Analyze image directly (Mode 1: Direct Vision Analysis)
  Future<GeminiAnalysisResult> analyzeImage(File imageFile) async {
    if (!_isInitialized || _model == null) {
      return GeminiAnalysisResult.error('Gemini not initialized. Please configure API key.');
    }

    try {
      final bytes = await imageFile.readAsBytes();
      return analyzeImageBytes(bytes);
    } catch (e) {
      return GeminiAnalysisResult.error('Failed to read image: $e');
    }
  }

  /// Analyze image from bytes
  Future<GeminiAnalysisResult> analyzeImageBytes(Uint8List imageBytes) async {
    if (!_isInitialized || _model == null) {
      return GeminiAnalysisResult.error('Gemini not initialized. Please configure API key.');
    }

    try {
      final prompt = '''
$systemPrompt

Analyze this image. Return ONLY JSON. Keep descriptions SHORT (max 10 words each).
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model!.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        print('Gemini direct analysis returned empty response');
        return GeminiAnalysisResult.error('Empty response from Gemini');
      }

      print('Gemini direct analysis response received (${responseText.length} chars)');

      // Parse JSON response
      return _parseResponse(responseText);
    } catch (e) {
      print('Gemini direct analysis error: $e');
      // Provide more helpful error messages
      if (e.toString().contains('quota') || e.toString().contains('rate limit')) {
        return GeminiAnalysisResult.error('API rate limit reached. Please wait a moment and try again.');
      } else if (e.toString().contains('safety') || e.toString().contains('blocked')) {
        return GeminiAnalysisResult.error('Content was blocked by safety filters. Try a different image.');
      } else if (e.toString().contains('invalid') && e.toString().contains('api')) {
        return GeminiAnalysisResult.error('Invalid API key. Please check your configuration.');
      } else {
        return GeminiAnalysisResult.error('Analysis failed. Please try again.');
      }
    }
  }

  /// Analyze with preprocessed YOLO data (Mode 2: Post-Processing)
  Future<GeminiAnalysisResult> analyzeWithPreprocessedData(
    Uint8List imageBytes,
    Map<String, dynamic> preprocessedData,
  ) async {
    if (!_isInitialized || _model == null) {
      return GeminiAnalysisResult.error('Gemini not initialized. Please configure API key.');
    }

    try {
      final preprocessedJson = jsonEncode(preprocessedData);
      
      final prompt = '''
$systemPrompt

You are receiving pre-processed detection data from YOLO/OpenCV. Use MODE 2: Post-Processing Analysis.

Pre-processed data:
$preprocessedJson

Additionally, I'm providing the original image for visual verification. Enhance the YOLO detections with:
1. More specific material type identification
2. Detailed condition assessment
3. Safety flag assignments
4. Confidence calibration based on image quality

Return ONLY valid JSON in the format specified above.
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model!.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        print('Gemini post-processing returned empty response');
        return GeminiAnalysisResult.error('Empty response from Gemini');
      }

      print('Gemini post-processing response received (${responseText.length} chars)');

      // Parse JSON response
      final result = _parseResponse(responseText);
      if (!result.hasError) {
        // Mark as post-processed
        result.rawJson['processing_mode'] = 'post_processed';
      }
      return result;
    } catch (e) {
      print('Gemini post-processing error: $e');
      // Provide more helpful error message
      if (e.toString().contains('quota') || e.toString().contains('rate limit')) {
        return GeminiAnalysisResult.error('API rate limit reached. Please wait a moment and try again.');
      } else if (e.toString().contains('safety') || e.toString().contains('blocked')) {
        return GeminiAnalysisResult.error('Content was blocked by safety filters. Try a different image.');
      } else {
        return GeminiAnalysisResult.error('Analysis failed. Please try again.');
      }
    }
  }

  GeminiAnalysisResult _parseResponse(String responseText) {
    try {
      // Clean up response - remove markdown code blocks if present
      String cleanedResponse = responseText.trim();
      
      // Remove markdown code block markers
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      } else if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      
      cleanedResponse = cleanedResponse.trim();

      // Check if response looks truncated (missing closing braces)
      final openBraces = '{'.allMatches(cleanedResponse).length;
      final closeBraces = '}'.allMatches(cleanedResponse).length;
      final openBrackets = '['.allMatches(cleanedResponse).length;
      final closeBrackets = ']'.allMatches(cleanedResponse).length;
      
      if (openBraces > closeBraces || openBrackets > closeBrackets) {
        // Try to fix incomplete JSON by adding missing closing braces
        print('WARNING: Detected truncated JSON response. Attempting to fix...');
        final missingBraces = openBraces - closeBraces;
        final missingBrackets = openBrackets - closeBrackets;
        
        for (int i = 0; i < missingBrackets; i++) {
          cleanedResponse += ']';
        }
        for (int i = 0; i < missingBraces; i++) {
          cleanedResponse += '}';
        }
      }

      // Parse JSON
      final json = jsonDecode(cleanedResponse) as Map<String, dynamic>;
      
      return GeminiAnalysisResult(
        rawJson: json,
        processingMode: json['processing_mode'] ?? 'direct_vision',
        materialsDetected: (json['materials_detected'] as List?)
            ?.map((m) => MaterialAnalysis.fromJson(m))
            .toList() ?? [],
        suggestedProjects: (json['suggested_projects'] as List?)
            ?.map((p) => ProjectSuggestion.fromJson(p))
            .toList() ?? [],
        overallNotes: json['overall_notes'] ?? '',
        recommendedNextStep: json['recommended_next_step'] ?? '',
      );
    } on FormatException catch (e) {
      print('JSON parsing failed: $e');
      // Return a more user-friendly error for parsing failures
      return GeminiAnalysisResult.error(
        'Gemini response was incomplete or invalid. This may happen with complex images. '
        'Please try again or use a simpler photo.'
      );
    } catch (e) {
      return GeminiAnalysisResult.error('Failed to parse Gemini response: $e');
    }
  }
}

// Data classes

class GeminiAnalysisResult {
  final Map<String, dynamic> rawJson;
  final String processingMode;
  final List<MaterialAnalysis> materialsDetected;
  final List<ProjectSuggestion> suggestedProjects;
  final String overallNotes;
  final String recommendedNextStep;
  final String? error;

  GeminiAnalysisResult({
    required this.rawJson,
    required this.processingMode,
    required this.materialsDetected,
    this.suggestedProjects = const [],
    required this.overallNotes,
    required this.recommendedNextStep,
  }) : error = null;

  GeminiAnalysisResult.error(this.error)
      : rawJson = {},
        processingMode = '',
        materialsDetected = [],
        suggestedProjects = [],
        overallNotes = '',
        recommendedNextStep = '';

  bool get hasError => error != null;
  bool get hasMaterials => materialsDetected.isNotEmpty;
}

class MaterialAnalysis {
  final String materialType;
  final String estimatedQuantity;
  final String estimatedSize;
  final ConditionAssessment condition;
  final String reuseSuitability;
  final String safetyFlag;
  final ConfidenceScores confidence;
  final String reasoning;

  MaterialAnalysis({
    required this.materialType,
    required this.estimatedQuantity,
    required this.estimatedSize,
    required this.condition,
    required this.reuseSuitability,
    required this.safetyFlag,
    required this.confidence,
    required this.reasoning,
  });

  factory MaterialAnalysis.fromJson(Map<String, dynamic> json) {
    return MaterialAnalysis(
      materialType: json['material_type'] ?? 'Unknown Material',
      estimatedQuantity: json['estimated_quantity'] ?? 'Unknown',
      estimatedSize: json['estimated_size'] ?? 'Unknown',
      condition: ConditionAssessment.fromJson(json['condition'] ?? {}),
      reuseSuitability: json['reuse_suitability'] ?? 'Manual Review Required',
      safetyFlag: json['safety_flag'] ?? 'Caution',
      confidence: ConfidenceScores.fromJson(json['confidence'] ?? {}),
      reasoning: json['reasoning'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'material_type': materialType,
    'estimated_quantity': estimatedQuantity,
    'estimated_size': estimatedSize,
    'condition': condition.toJson(),
    'reuse_suitability': reuseSuitability,
    'safety_flag': safetyFlag,
    'confidence': confidence.toJson(),
    'reasoning': reasoning,
  };
}

class ConditionAssessment {
  final String structural;
  final String visibleDamage;
  final List<String> defects;

  ConditionAssessment({
    required this.structural,
    required this.visibleDamage,
    required this.defects,
  });

  factory ConditionAssessment.fromJson(Map<String, dynamic> json) {
    return ConditionAssessment(
      structural: json['structural'] ?? 'Unknown',
      visibleDamage: json['visible_damage'] ?? 'Unknown',
      defects: (json['defects'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'structural': structural,
    'visible_damage': visibleDamage,
    'defects': defects,
  };
}

class ConfidenceScores {
  final double materialIdentification;
  final double conditionAssessment;
  final double quantityEstimation;

  ConfidenceScores({
    required this.materialIdentification,
    required this.conditionAssessment,
    required this.quantityEstimation,
  });

  factory ConfidenceScores.fromJson(Map<String, dynamic> json) {
    return ConfidenceScores(
      materialIdentification: (json['material_identification'] ?? 0.5).toDouble(),
      conditionAssessment: (json['condition_assessment'] ?? 0.5).toDouble(),
      quantityEstimation: (json['quantity_estimation'] ?? 0.5).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'material_identification': materialIdentification,
    'condition_assessment': conditionAssessment,
    'quantity_estimation': quantityEstimation,
  };
}

class ProjectSuggestion {
  final String name;
  final String description;
  final String complexity;
  final List<String> materialsUsed;
  final String estimatedBuildTime;
  final String category;

  ProjectSuggestion({
    required this.name,
    required this.description,
    required this.complexity,
    required this.materialsUsed,
    required this.estimatedBuildTime,
    required this.category,
  });

  factory ProjectSuggestion.fromJson(Map<String, dynamic> json) {
    return ProjectSuggestion(
      name: json['name'] ?? 'Unnamed Project',
      description: json['description'] ?? '',
      complexity: json['complexity'] ?? 'Intermediate',
      materialsUsed: (json['materials_used'] as List?)?.map((e) => e.toString()).toList() ?? [],
      estimatedBuildTime: json['estimated_build_time'] ?? 'Unknown',
      category: json['category'] ?? 'Other',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'complexity': complexity,
    'materials_used': materialsUsed,
    'estimated_build_time': estimatedBuildTime,
    'category': category,
  };
}
