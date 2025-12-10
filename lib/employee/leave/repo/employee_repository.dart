import 'dart:convert';

import 'package:emp_management/employee/home/model/attendance_models.dart';
import 'package:emp_management/employee/leave/model/leave_models.dart';
import 'package:emp_management/services/api_service/api_provider.dart';
import 'package:get_storage/get_storage.dart';


class EmployeeRepository {
  EmployeeRepository(this._api, this._storage);

  final ApiProvider _api;
  final GetStorage _storage;

  String _ensureEmployeeId() {
    final employeeId = _storage.read<String>('auth_id');
    if (employeeId == null || employeeId.isEmpty) {
      throw Exception('Employee ID not found. Please login again.');
    }
    return employeeId;
  }

  String? get currentUserName => _storage.read<String>('auth_name');

  Future<AttendanceRecordModel?> punch({
    required double lat,
    required double lng,
    required String type, // 'IN' or 'OUT'
  }) async {
    final employeeId = _ensureEmployeeId();
    final punchType = type.toUpperCase();

    final response = await _api.post(
      '/employee/punch',
      body: <String, dynamic>{
        'employee_id': employeeId,
        'type': punchType,
        'lat': lat,
        'lng': lng,
        'source': 'mobile',
      },
      
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Try to parse a friendly message from the response body
      String message = 'Punch failed. Please try again.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded['message'] is String) {
            message = decoded['message'];
          } else if (decoded['error'] is String) {
            message = decoded['error'];
          } else if (decoded['data'] is Map && decoded['data']['message'] is String) {
            message = decoded['data']['message'];
          }
        }
      } catch (_) {}
      throw ApiException(response.statusCode, message);
    }

    final candidate = _extractAttendanceCandidate(response.body);
    if (candidate != null) {
      return AttendanceRecordModel.fromJson(candidate);
    }

    return null;
  }

  bool _looksLikeAttendance(Map<String, dynamic> json) {
    return json.containsKey('type') || json.containsKey('punch_in_time') || json.containsKey('punch_out_time');
  }

  Future<AttendanceRecordModel?> getTodayAttendance() async {
    final employeeId = _ensureEmployeeId();
    final response = await _api.get('/employee/punches/$employeeId');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final candidate = _extractAttendanceCandidate(response.body);
      if (candidate != null) {
        return AttendanceRecordModel.fromJson(candidate);
      }
      return null;
    }
    // parse friendly message
    String message = 'Failed to load attendance.';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] is String) message = decoded['message'];
      }
    } catch (_) {}
    throw ApiException(response.statusCode, message);
  }

  Future<void> applyLeave({
    required String leaveType,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    final employeeId = _ensureEmployeeId();
    final response = await _api.post(
      '/employee/leave',
      body: <String, dynamic>{
        'employee_id': employeeId,
        'leave_type': leaveType,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Leave apply failed. Please try again.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded['message'] is String) message = decoded['message'];
        }
      } catch (_) {}
      throw ApiException(response.statusCode, message);
    }
  }

  Future<LeaveStatusModel?> getLeaveStatus() async {
    final response = await _api.get('/employee/leaves');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> list = (json['data'] ?? []) as List<dynamic>;
      final leaves = list
          .whereType<Map<String, dynamic>>()
          .map(LeaveStatusModel.fromJson)
          .toList();
      return _selectRelevantLeave(leaves);
    }
    String message = 'Failed to load leave status.';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] is String) message = decoded['message'];
      }
    } catch (_) {}
    throw ApiException(response.statusCode, message);
  }

  Map<String, dynamic>? _extractAttendanceCandidate(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      Map<String, dynamic>? candidate;

      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          candidate = data;
        } else if (data is List && data.isNotEmpty) {
          final first = data.first;
          if (first is Map<String, dynamic>) candidate = first;
        } else if (_looksLikeAttendance(decoded)) {
          candidate = decoded;
        }
      }
      return candidate;
    } catch (_) {
      return null;
    }
  }

  LeaveStatusModel? _selectRelevantLeave(List<LeaveStatusModel> leaves) {
    if (leaves.isEmpty) return null;

    final now = DateTime.now();

    final pending = leaves.where((leave) => leave.status == 'pending').toList();
    if (pending.isNotEmpty) {
      pending.sort((a, b) => b.startDate.compareTo(a.startDate));
      return pending.first;
    }

    final active = leaves.where((leave) {
      final start = DateTime(leave.startDate.year, leave.startDate.month, leave.startDate.day);
      final end = DateTime(leave.endDate.year, leave.endDate.month, leave.endDate.day);
      return !now.isBefore(start) && !now.isAfter(end) && leave.status == 'approved';
    }).toList();
    if (active.isNotEmpty) {
      active.sort((a, b) => b.startDate.compareTo(a.startDate));
      return active.first;
    }

    leaves.sort((a, b) => b.startDate.compareTo(a.startDate));
    return leaves.first;
  }
}
