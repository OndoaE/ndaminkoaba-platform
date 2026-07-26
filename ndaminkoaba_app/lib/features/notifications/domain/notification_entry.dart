class NotificationEntry {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntry({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationEntry.fromJson(Map<String, dynamic> json) {
    return NotificationEntry(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
