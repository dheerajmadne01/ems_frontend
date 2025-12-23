import 'dart:convert';

import 'package:emp_management/services/api_service/api_provider.dart';
import 'package:emp_management/admin/all_emp/model/employee_model.dart';
import 'package:emp_management/admin/attendence/model/attendance_models.dart' as attendance;
import 'package:emp_management/admin/leaves/model/leave_request_model.dart';
import 'package:intl/intl.dart';

class AdminRepository {
  AdminRepository() : _api = ApiProvider();

  final ApiProvider _api;

  Future<void> setCompanyLocation({
    required double lat,
    required double lng,
  }) async {
    final response = await _api.put(
      '/admin/location',
      body: <String, dynamic>{
        'lat': lat,
        'lng': lng,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update location: ${response.body}');
    }
  }

  Future<List<EmployeeModel>> fetchAllEmployees() async {
    final response = await _api.get('/admin/employees');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final List data = (json['data'] ?? []) as List;
      return data.map((e) => EmployeeModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load employees: ${response.body}');
  }

  Future<List<attendance.EmployeeModel>> fetchAttendanceData({DateTime? date}) async {
    final String? dateParam =
        date != null ? DateFormat('yyyy-MM-dd').format(date) : null;

    final response = await _api.get(
      '/employee/all-emp-punches',
      queryParameters:
          dateParam != null ? <String, dynamic>{'date': dateParam} : null,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> employeeList =
          json['data'] ?? json['employees'] ?? [];
      return employeeList
          .map((e) => attendance.EmployeeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load attendance: ${response.body}');
  }

  Future<List<LeaveRequestModel>> fetchLeaveRequests() async {
    final response = await _api.get('/employee/all-emp-leaves');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final employees =
          (decoded['data'] ?? decoded['employees'] ?? []) as List<dynamic>;

      final List<LeaveRequestModel> leaves = [];
      for (final entry in employees) {
        if (entry is Map<String, dynamic>) {
          final employeeLeaves =
              (entry['leaves'] as List<dynamic>?) ?? const <dynamic>[];
          for (final leave in employeeLeaves) {
            if (leave is Map<String, dynamic>) {
              leaves.add(
                LeaveRequestModel.fromJson(
                  leave: leave,
                  employee: entry,
                ),
              );
            }
          }
        }
      }
      return leaves;
    }
    throw Exception('Failed to load leave requests: ${response.body}');
  }
}
