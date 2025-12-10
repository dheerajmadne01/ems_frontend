class PunchModel {
  final String id;
  final String type; // "IN" or "OUT"
  final DateTime? punchInTime; // may be null
  final DateTime? punchOutTime; // may be null
  final double? lat;
  final double? lng;
  final bool geofencePassed;

  PunchModel({
    required this.id,
    required this.type,
    this.punchInTime,
    this.punchOutTime,
    this.lat,
    this.lng,
    required this.geofencePassed,
  });

  factory PunchModel.fromJson(Map<String, dynamic> json) {
    DateTime? _parse(String? s) => s == null ? null : DateTime.parse(s).toLocal();
    return PunchModel(
      id: json['id'] as String,
      type: json['type'] as String,
      punchInTime: _parse(json['punch_in_time'] as String?),
      punchOutTime: _parse(json['punch_out_time'] as String?),
      lat: (json['lat'] is num) ? (json['lat'] as num).toDouble() : null,
      lng: (json['lng'] is num) ? (json['lng'] as num).toDouble() : null,
      geofencePassed: json['geofence_passed'] == true,
    );
  }
}

class LeaveModel {
  final String id;
  final String status; // e.g., "approved" / "pending"
  final String? reason;
  final DateTime? from;
  final DateTime? to;

  LeaveModel({
    required this.id,
    required this.status,
    this.reason,
    this.from,
    this.to,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    DateTime? _parseEpoch(dynamic v) {
      // Some APIs return epoch ms; adapt if needed.
      if (v == null) return null;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v).toLocal();
      if (v is String) {
        try {
          return DateTime.parse(v).toLocal();
        } catch (_) {
          final n = int.tryParse(v);
          if (n != null) return DateTime.fromMillisecondsSinceEpoch(n).toLocal();
        }
      }
      return null;
    }

    return LeaveModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      reason: json['reason'] as String?,
      from: _parseEpoch(json['from']),
      to: _parseEpoch(json['to']),
    );
  }
}

class EmployeeModel {
  final String id;
  final String empId;
  final String name;
  final String? email;
  final String? dept;
  final String? jobRole;
  final String? phone;
  final String? profilePhoto;
  final List<PunchModel> punches;
  final List<LeaveModel> leaves;

  EmployeeModel({
    required this.id,
    required this.empId,
    required this.name,
    this.email,
    this.dept,
    this.jobRole,
    this.phone,
    this.profilePhoto,
    required this.punches,
    required this.leaves,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final punchesJson = (json['punches'] as List<dynamic>?) ?? [];
    final leavesJson = (json['leaves'] as List<dynamic>?) ?? [];

    return EmployeeModel(
      id: json['id'] as String,
      empId: (json['emp_id'] ?? json['empId'] ?? '') as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      dept: json['dept'] as String?,
      jobRole: json['job_role'] as String?,
      phone: json['phone_number'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      punches: punchesJson.map((e) => PunchModel.fromJson(e as Map<String, dynamic>)).toList(),
      leaves: leavesJson.map((e) => LeaveModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
