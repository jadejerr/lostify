import 'report_data.dart'; 

class AppNotification {
  final String title;
  final String message;
  final String time;
  final String type; 
  final ReportItem? itemData; 

  AppNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.itemData, 
  });
}

List<AppNotification> globalNotifications = [];