import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'notification_service.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();

  // ================= MATERIALS =================
  
  /// Get all materials with real-time subscription
  Stream<List<Map<String, dynamic>>> streamMaterials() {
    return client
        .from('materials')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  /// Get materials by status
  Future<List<Map<String, dynamic>>> getMaterialsByStatus(String status) async {
    final response = await client
        .from('materials')
        .select()
        .eq('status', status)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Add a new material
  Future<Map<String, dynamic>?> addMaterial({
    required String name,
    required String type,
    required String quantity,
    required String condition,
    required String location,
    required double confidence,
    String? imageUrl,
    String? notes,
  }) async {
    final response = await client.from('materials').insert({
      'name': name,
      'type': type,
      'quantity': quantity,
      'condition': condition,
      'location': location,
      'confidence': confidence,
      'image_url': imageUrl,
      'notes': notes,
      'status': 'detected',
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();
    return response;
  }

  /// Update material status
  Future<void> updateMaterialStatus(String materialId, String status) async {
    await client
        .from('materials')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', materialId);
  }

  /// Delete a material
  Future<void> deleteMaterial(String materialId) async {
    await client.from('materials').delete().eq('id', materialId);
  }

  // ================= OPPORTUNITIES =================
  
  /// Stream opportunities in real-time
  Stream<List<Map<String, dynamic>>> streamOpportunities() {
    return client
        .from('opportunities')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  /// Create an opportunity from detected material
  Future<Map<String, dynamic>?> createOpportunity({
    required String materialId,
    required String materialName,
    required String materialType,
    required List<String> suggestedProjects,
    required double carbonImpact,
  }) async {
    final response = await client.from('opportunities').insert({
      'material_id': materialId,
      'material_name': materialName,
      'material_type': materialType,
      'suggested_projects': suggestedProjects,
      'carbon_impact': carbonImpact,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();
    return response;
  }

  /// Update opportunity status (confirm/reject)
  Future<void> updateOpportunityStatus(String opportunityId, String status, {String? matchedStudentId}) async {
    final Map<String, dynamic> updateData = {
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (matchedStudentId != null) {
      updateData['matched_student_id'] = matchedStudentId;
    }
    await client.from('opportunities').update(updateData).eq('id', opportunityId);
  }

  // ================= REQUESTS =================
  
  /// Stream material requests in real-time
  Stream<List<Map<String, dynamic>>> streamRequests() {
    return client
        .from('requests')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  /// Create a new material request
  Future<Map<String, dynamic>?> createRequest({
    required String title,
    required String materialType,
    required String quantity,
    required String project,
    required String description,
    required DateTime deadline,
    required String urgency,
    required String requesterId,
  }) async {
    final response = await client.from('requests').insert({
      'title': title,
      'material_type': materialType,
      'quantity': quantity,
      'project': project,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'urgency': urgency,
      'requester_id': requesterId,
      'status': 'open',
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();
    return response;
  }

  /// Update request status
  Future<void> updateRequestStatus(String requestId, String status) async {
    await client
        .from('requests')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', requestId);
  }

  // ================= USER PROFILE =================
  
  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? department,
    String? campusId,
    String? role,
    List<String>? skills,
    List<String>? interests,
    String? availability,
  }) async {
    final Map<String, dynamic> updateData = {
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (name != null) updateData['name'] = name;
    if (department != null) updateData['department'] = department;
    if (campusId != null) updateData['campus_id'] = campusId;
    if (role != null) updateData['role'] = role;
    if (skills != null) updateData['skills'] = skills;
    if (interests != null) updateData['interests'] = interests;
    if (availability != null) updateData['availability'] = availability;
    
    await client.from('profiles').update(updateData).eq('id', userId);
  }

  // ================= IMPACT TRACKING =================
  
  /// Get impact stats for a user
  Future<Map<String, dynamic>> getUserImpactStats(String userId) async {
    final materials = await client
        .from('materials')
        .select('carbon_saved')
        .eq('created_by', userId);
    
    double totalCo2 = 0;
    for (var m in materials) {
      totalCo2 += (m['carbon_saved'] ?? 0) as double;
    }
    
    final projectsCount = await client
        .from('opportunities')
        .select('id')
        .eq('matched_student_id', userId)
        .eq('status', 'completed');
    
    return {
      'co2_saved': totalCo2,
      'materials_count': materials.length,
      'projects_count': projectsCount.length,
    };
  }

  /// Get campus leaderboard
  Future<List<Map<String, dynamic>>> getCampusLeaderboard(String campusId) async {
    final response = await client
        .from('profiles')
        .select('id, name, department, co2_saved, materials_reused')
        .eq('campus_id', campusId)
        .order('co2_saved', ascending: false)
        .limit(10);
    return List<Map<String, dynamic>>.from(response);
  }

  // ================= NOTIFICATIONS =================
  
  /// Stream notifications for a user
  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  /// Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    await client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Create a notification
  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
  }) async {
    await client.from('notifications').insert({
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ================= IMAGE UPLOAD =================
  
  /// Upload image to Supabase Storage
  Future<String?> uploadMaterialImage(String filePath, String fileName) async {
    try {
      final bytes = await _getFileBytes(filePath);
      await client.storage
          .from('materials')
          .uploadBinary('images/$fileName', 
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      
      final publicUrl = client.storage.from('materials').getPublicUrl('images/$fileName');
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<Uint8List> _getFileBytes(String filePath) async {
    // Read file bytes from the file path
    final file = File(filePath);
    return await file.readAsBytes();
  }

  // ================= AUTHENTICATION =================
  
  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Sign in with email
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  /// Sign up with email
  Future<AuthResponse> signUpWithEmail(String email, String password, {String? name}) async {
    final response = await client.auth.signUp(email: email, password: password);
    
    // Create profile after signup
    if (response.user != null && name != null) {
      await client.from('profiles').insert({
        'id': response.user!.id,
        'name': name,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    
    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ================= NOTIFICATIONS =================
  
  /// Save FCM token for user
  Future<void> saveUserFCMToken(String token, {String? userId}) async {
    final currentUser = client.auth.currentUser;
    if (currentUser != null) {
      await client.from('profiles').upsert({
        'id': userId ?? currentUser.id,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Send notification when new material matches request
  Future<void> notifyMaterialMatch(String requestId, String materialName) async {
    await _notificationService.showNotification(
      "Material Match Found!",
      "$materialName is now available for your request"
    );
  }

  /// Send notification for new requests to lab
  Future<void> notifyNewRequest(String materialName, String requesterName) async {
    await _notificationService.showNotification(
      "New Material Request",
      "$requesterName requested $materialName"
    );
  }
}
