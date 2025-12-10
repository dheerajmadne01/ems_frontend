import 'dart:convert';
import 'package:emp_management/services/api_service/api_provider.dart';
import '../model/employee_model.dart';

class EmployeeRepository {
  final ApiProvider _api = ApiProvider();

  Future<List<EmployeeModel>> fetchEmployees() async {
    final response = await _api.get('/admin/employees');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);

      final List data =( json['data']??[]) as List;
      return data.map((e) => EmployeeModel.fromJson(e)).toList();
    }

    throw Exception("Failed to load employees: ${response.body}");
  }
}
