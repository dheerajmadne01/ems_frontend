class LeaveStatusModel {
  LeaveStatusModel({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.reason,
    this.days,
  });

  final String id;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? reason;
  final double? days;

  factory LeaveStatusModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception("LeaveStatusModel Error: Received null JSON");
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();

      try {
        if (value is String) return DateTime.parse(value).toLocal();
        if (value is int) {
          return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
        }
      } catch (_) {}

      return DateTime.now();
    }

    double? parseDays(dynamic value) {
      if (value == null) return null;

      try {
        if (value is num) return value.toDouble();
        if (value is String) return double.parse(value);
      } catch (_) {}

      return null;
    }

    return LeaveStatusModel(
      id: json['id']?.toString() ?? '',
      leaveType: json['leave_type']?.toString() ??
          json['leaveType']?.toString() ??
          '',
      startDate: parseDate(json['start_date'] ?? json['startDate']),
      endDate: parseDate(json['end_date'] ?? json['endDate']),
      status: json['status']?.toString() ?? '',
      reason: json['reason']?.toString(),
      days: parseDays(json['days']),
    );
  }
}
