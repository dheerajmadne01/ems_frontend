import 'dart:convert';

import 'package:emp_management/admin/dashboard/model/admin_model.dart';
import 'package:emp_management/services/api_service/api_provider.dart';

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

  Future<DashboardData> fetchDashboard() async {
    final response = await _api.get('/admin/dashboard');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final data = (json['data'] ?? <String, dynamic>{}) as Map<String, dynamic>;
      return DashboardData.fromJson(data);
    }
    throw Exception('Failed to load dashboard: ${response.body}');
  }
}
