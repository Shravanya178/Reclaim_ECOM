import 'package:cloud_functions/cloud_functions.dart';

enum CampaignEmailType { reminder, advertisement }

class EmailCampaignService {
  EmailCampaignService._();

  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');

  static Future<String> sendCampaignEmail({
    required List<String> recipients,
    required String subject,
    required String body,
    CampaignEmailType type = CampaignEmailType.reminder,
  }) async {
    if (recipients.isEmpty) {
      throw Exception('Please provide at least one recipient email.');
    }

    final sanitizedRecipients = recipients
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    if (sanitizedRecipients.isEmpty) {
      throw Exception('Please provide valid recipient emails.');
    }

    try {
      final callable = _functions.httpsCallable('sendMarketingEmail');
      final result = await callable.call(<String, dynamic>{
        'recipients': sanitizedRecipients,
        'subject': subject.trim(),
        'body': body.trim(),
        'type': type.name,
      });

      final data = result.data;
      if (data is Map && data['success'] == true) {
        return (data['message'] ?? 'Email request accepted.').toString();
      }

      throw Exception('Email dispatch failed.');
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Failed to send email.');
    } catch (e) {
      throw Exception('Failed to send email: $e');
    }
  }
}
