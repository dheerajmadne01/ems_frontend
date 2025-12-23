import 'dart:convert';
import 'package:emp_management/admin/attendence/model/attendance_models.dart';
import 'package:emp_management/services/api_service/api_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class AttendanceRepository {
  final ApiProvider api;
  final GetStorage storage;

  AttendanceRepository()
      : api = ApiProvider(),
        storage = GetStorage();

  Future<List<EmployeeModel>> fetchEmployeesWithPunches({DateTime? date}) async {
    final String? dateParam =
        date != null ? DateFormat('yyyy-MM-dd').format(date) : null;

    final response = await api.get(
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
          .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load employees: ${response.body}');
  }
}
