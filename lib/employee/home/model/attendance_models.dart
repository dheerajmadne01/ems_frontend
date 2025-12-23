class AttendanceRecordModel {
  AttendanceRecordModel({
    required this.id,
    required this.employeeId,
    this.punchInTime,
    this.punchOutTime,
    this.breakStartTime,
    this.breakEndTime,
    this.type,
    this.status,
  });

  final String id;
  final String employeeId;
  final DateTime? punchInTime;
  final DateTime? punchOutTime;
  final DateTime? breakStartTime;
  final DateTime? breakEndTime;
  final String? type; 
  final String? status;

  bool get isPunchedIn => punchInTime != null && punchOutTime == null;
  bool get isOnBreak => breakStartTime != null && breakEndTime == null;
  bool get canPunchIn => punchInTime == null;
  bool get canPunchOut => isPunchedIn && !isOnBreak;
  bool get canBreakStart => isPunchedIn && !isOnBreak;
  bool get canBreakEnd => isOnBreak;

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseTime(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value).toLocal();
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return AttendanceRecordModel(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      punchInTime: parseTime(json['punch_in_time']),
      punchOutTime: parseTime(json['punch_out_time']),
      breakStartTime: parseTime(json['break_start_time']),
      breakEndTime: parseTime(json['break_end_time']),
      type: json['type'] as String?,
      status: json['status'] as String? ?? 'present',
    );
  }
}


