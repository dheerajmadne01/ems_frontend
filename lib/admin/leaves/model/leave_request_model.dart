class LeaveRequestModel {
  LeaveRequestModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeRole,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.reason,
    this.days,
    this.department,
    this.profilePhoto,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String employeeRole;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? reason;
  final double? days;
  final String? department;
  final String? profilePhoto;

  bool get isPending => status.toLowerCase() == 'pending';

  String get durationLabel {
    final double duration = days ?? endDate.difference(startDate).inDays + 1;
    if (duration <= 1) return '1 Day';
    return '${duration.toStringAsFixed(duration.truncateToDouble() == duration ? 0 : 1)} Days';
  }

  factory LeaveRequestModel.fromJson({
    required Map<String, dynamic> leave,
    required Map<String, dynamic> employee,
  }) {
    DateTime _parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String && value.isNotEmpty) {
        return DateTime.parse(value).toLocal();
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
      }
      return DateTime.now();
    }

    double? _parseDays(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    }

    return LeaveRequestModel(
      id: leave['id']?.toString() ?? '',
      employeeId: employee['id']?.toString() ?? '',
      employeeName: employee['name']?.toString() ?? '',
      employeeRole: employee['job_role']?.toString() ?? employee['dept']?.toString() ?? '',
      leaveType: leave['leave_type']?.toString() ?? 'Leave',
      startDate: _parseDate(leave['start_date']),
      endDate: _parseDate(leave['end_date']),
      status: leave['status']?.toString() ?? 'pending',
      reason: leave['reason']?.toString(),
      days: _parseDays(leave['days']),
      department: employee['dept']?.toString(),
      profilePhoto: employee['profile_photo']?.toString(),
    );
  }
}

