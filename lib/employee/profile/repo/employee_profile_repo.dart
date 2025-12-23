import 'dart:convert';

import 'package:emp_management/employee/profile/model/employee_profile_model.dart';
import 'package:emp_management/services/api_service/api_provider.dart';

class EmployeeRepository {
  EmployeeRepository()
      : _api = ApiProvider();

  final ApiProvider _api;

  Future<EmployeeProfileModel> getEmployeeProfile() async {
    final response = await _api.get('/employee/profile');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];

      if (data is Map<String, dynamic>) {
        return EmployeeProfileModel.fromJson(data);
      }

      throw Exception('Invalid profile data');
    }

    String message = 'Failed to load profile';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        message = decoded['message'];
      }
    } catch (_) {}

    throw Exception(message);
  }
}
