import 'package:emp_management/services/api_service/api_provider.dart';

class EmployeeRepository {
  final ApiProvider _api = ApiProvider();

  Future<void> createEmployee({
    required String fullName,
    required String department,
    required String jobRole,
    required String email,
    required String phone,
    required String salary,
    required String employeeId,
  }) async {
    final response = await _api.post(
      '/admin/employee',
      body: {
        'name': fullName,
        'dept': department,
        'job_role': jobRole,
        'email': email,
        'phone_number': phone,
        'salary': salary,
        'role': 'employee',
        'emp_id': employeeId,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Failed to create employee: ${response.body}");
    }
  }
}
