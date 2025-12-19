import 'dart:convert';

import 'package:emp_management/employee/profile/model/employee_profile_model.dart';
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
