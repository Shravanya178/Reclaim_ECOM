import 'package:cloud_functions/cloud_functions.dart';

class WelcomeEmailService {
  WelcomeEmailService._();

  static final WelcomeEmailService instance = WelcomeEmailService._();

  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'asia-south1');

  Future<void> sendPersonalizedWelcomeEmail({
    required String fullName,
    required String departmentName,
    required String campusName,
    required String role,
  }) async {
    final callable = _functions.httpsCallable('sendPersonalizedWelcomeEmail');

    await callable.call(<String, dynamic>{
      'fullName': fullName,
      'departmentName': departmentName,
      'campusName': campusName,
      'role': role,
    });
  }
}