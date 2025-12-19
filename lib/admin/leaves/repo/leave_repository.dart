import 'dart:convert';

import 'package:emp_management/admin/leaves/model/leave_request_model.dart';
import 'package:emp_management/services/api_service/api_provider.dart';

class AdminLeaveRepository {
  AdminLeaveRepository() : _api = ApiProvider();

  final ApiProvider _api;

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

  Future<void> decideLeave({
    required String leaveId,
    required String action,
  }) async {
    final response = await _api.post(
      '/leave/$leaveId/decide',
      body: <String, dynamic>{'action': action},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to $action leave: ${response.body}');
    }
  }
}

