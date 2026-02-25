/// Simple notification service stub
class NotificationService {
  NotificationService();

  Future<void> sendNotification(String userId, String message) async {
    // TODO: Implement notification logic
    print('Sending notification to $userId: $message');
  }

  Future<void> showNotification(String title, String body, {String? payload}) async {
    // TODO: Implement local notification logic
    print('Showing notification: $title - $body');
  }
}
