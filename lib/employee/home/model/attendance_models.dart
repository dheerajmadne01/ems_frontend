class AttendanceRecordModel {
  AttendanceRecordModel({
    required this.id,
    required this.employeeId,
    this.punchInTime,
    this.punchOutTime,
    this.type,
    this.status,
  });

  final String id;
  final String employeeId;
  final DateTime? punchInTime;
  final DateTime? punchOutTime;
  final String? type; 
  final String? status;

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      punchInTime: json['punch_in_time'] != null
          ? DateTime.parse(json['punch_in_time'] as String)
          : null,
      punchOutTime: json['punch_out_time'] != null
          ? DateTime.parse(json['punch_out_time'] as String)
          : null,
      type: json['type'] as String?,
      status: json['status'] as String? ?? 'present',
    );
  }
}


