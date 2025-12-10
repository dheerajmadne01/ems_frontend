class AdminModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final double companyLat;
  final double companyLng;
  final int rangeInMeter;
  final int createdOn;
  final int updatedOn;

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.companyLat,
    required this.companyLng,
    required this.rangeInMeter,
    required this.createdOn,
    required this.updatedOn,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      phoneNumber: json["phone_number"],
      companyLat: (json["company_lat"] ?? 0).toDouble(),
      companyLng: (json["company_lng"] ?? 0).toDouble(),
      rangeInMeter: json["range_in_meter"],
      createdOn: json["created_on"],
      updatedOn: json["updated_on"],
    );
  }
}

class DashboardSummary {
  DashboardSummary({
    required this.totalEmployees,
    required this.present,
    required this.absent,
    required this.onLeave,
    required this.pendingLeaves,
  });

  final int totalEmployees;
  final int present;
  final int absent;
  final int onLeave;
  final int pendingLeaves;

  factory DashboardSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DashboardSummary(
        totalEmployees: 0,
        present: 0,
        absent: 0,
        onLeave: 0,
        pendingLeaves: 0,
      );
    }
    return DashboardSummary(
      totalEmployees: (json['totalEmployees'] ?? 0) as int,
      present: (json['present'] ?? 0) as int,
      absent: (json['absent'] ?? 0) as int,
      onLeave: (json['onLeave'] ?? 0) as int,
      pendingLeaves: (json['pendingLeaves'] ?? 0) as int,
    );
  }
}

class DashboardEmployee {
  DashboardEmployee({
    required this.id,
    required this.empId,
    required this.name,
    required this.email,
    this.department,
    this.jobRole,
    required this.status,
    required this.punchedIn,
    required this.punchedOut,
    this.punchInTime,
    this.punchOutTime,
    required this.pendingLeaves,
    required this.activeLeaves,
  });

  final String id;
  final String empId;
  final String name;
  final String email;
  final String? department;
  final String? jobRole;
  final String status;
  final bool punchedIn;
  final bool punchedOut;
  final DateTime? punchInTime;
  final DateTime? punchOutTime;
  final int pendingLeaves;
  final int activeLeaves;

  factory DashboardEmployee.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value)?.toLocal();
      }
      return null;
    }

    final attendance = json['attendance'] as Map<String, dynamic>? ?? {};
    final leaves = json['leaves'] as Map<String, dynamic>? ?? {};

    return DashboardEmployee(
      id: json['id']?.toString() ?? '',
      empId: json['emp_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: json['department']?.toString(),
      jobRole: json['job_role']?.toString(),
      status: json['status']?.toString() ?? 'Unknown',
      punchedIn: attendance['punchedIn'] == true,
      punchedOut: attendance['punchedOut'] == true,
      punchInTime: parseDate(attendance['punchInTime']),
      punchOutTime: parseDate(attendance['punchOutTime']),
      pendingLeaves: (leaves['pending'] ?? 0) as int,
      activeLeaves: (leaves['active'] ?? 0) as int,
    );
  }
}

class DashboardData {
  DashboardData({
    required this.summary,
    required this.employees,
  });

  final DashboardSummary summary;
  final List<DashboardEmployee> employees;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] as Map<String, dynamic>?;
    final employeesJson = (json['employees'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return DashboardData(
      summary: DashboardSummary.fromJson(summaryJson),
      employees:
          employeesJson.map(DashboardEmployee.fromJson).toList(growable: false),
    );
  }
}
