import 'package:supabase_flutter/supabase_flutter.dart';

enum CampaignEmailType { reminder, advertisement }

class EmailCampaignService {
  EmailCampaignService._();

  static final SupabaseClient _supabase = Supabase.instance.client;

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
      final result = await _supabase.functions.invoke(
        'send-campaign-email',
        body: <String, dynamic>{
        'recipients': sanitizedRecipients,
        'subject': subject.trim(),
        'body': body.trim(),
        'type': type.name,
        },
      );

      final data = result.data;
      if (data is Map && data['success'] == true) {
        return (data['message'] ?? 'Email request accepted.').toString();
      }

      throw Exception('Email dispatch failed.');
    } catch (e) {
      throw Exception('Failed to send email: $e');
    }
  }

  static Future<String> sendWaitlistAutoReply({
    required String email,
  }) async {
    final sanitized = email.trim().toLowerCase();
    if (sanitized.isEmpty) {
      throw Exception('Please enter an email address.');
    }

    try {
      final result = await _supabase.functions.invoke(
        'send-waitlist-email',
        body: <String, dynamic>{
          'email': sanitized,
        },
      );

      final data = result.data;
      if (data is Map && data['success'] == true) {
        return (data['message'] ?? 'Waitlist email sent.').toString();
      }

      throw Exception('Unable to send waitlist email.');
    } catch (e) {
      throw Exception('Waitlist email failed: $e');
    }
  }
}
