import 'dart:convert';
import 'package:emp_management/admin/attendence/model/attendance_models.dart';
import 'package:emp_management/services/api_service/api_provider.dart';
import 'package:get_storage/get_storage.dart';

class AttendanceRepository {
  final ApiProvider api;
  final GetStorage storage;

  AttendanceRepository()
      : api = ApiProvider(),
        storage = GetStorage();

  Future<List<EmployeeModel>> fetchEmployeesWithPunches() async {
    // Fetch attendance data
    final attendanceResponse = await api.get('/employee/all-emp-punches');

    if (attendanceResponse.statusCode >= 200 &&
        attendanceResponse.statusCode < 300) {
      final Map<String, dynamic> attendanceJson =
          jsonDecode(attendanceResponse.body) as Map<String, dynamic>;
      final List<dynamic> attendanceList =
          attendanceJson['data'] ?? attendanceJson['employees'] ?? [];

      // Fetch leave data
      final leaveResponse = await api.get('/employee/all-emp-leaves');

      if (leaveResponse.statusCode >= 200 && leaveResponse.statusCode < 300) {
        final Map<String, dynamic> leaveJson =
            jsonDecode(leaveResponse.body) as Map<String, dynamic>;
        final List<dynamic> leaveList =
            leaveJson['data'] ?? leaveJson['employees'] ?? [];

        final Map<String, List<dynamic>> leaveMap = {};
        for (var leaveEntry in leaveList) {
          if (leaveEntry is Map<String, dynamic>) {
            final employeeId = leaveEntry['id'] as String?;
            if (employeeId != null) {
              final employeeLeaves =
                  (leaveEntry['leaves'] as List<dynamic>?) ?? [];
              leaveMap[employeeId] = employeeLeaves;
            }
          }
        }

        // Merge attendance and leave data
        final List<EmployeeModel> employees = [];
        for (var attendanceEntry in attendanceList) {
          if (attendanceEntry is Map<String, dynamic>) {
            final employeeId = attendanceEntry['id'] as String?;
            if (employeeId != null && leaveMap.containsKey(employeeId)) {
              // Add leave data to the attendance entry
              final updatedEntry = Map<String, dynamic>.from(attendanceEntry);
              updatedEntry['leaves'] = leaveMap[employeeId];
              employees.add(EmployeeModel.fromJson(updatedEntry));
            } else {
              // If no leave data, create employee with empty leaves
              employees.add(EmployeeModel.fromJson(attendanceEntry));
            }
          }
        }

        return employees;
      } else {
        // If leave data fetch fails, return attendance data only
        return attendanceList
            .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    throw Exception('Failed to load employees: ${attendanceResponse.body}');
  }
}
