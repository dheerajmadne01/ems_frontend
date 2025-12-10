import 'dart:convert';
import 'package:emp_management/admin/dashboard/model/admin_model.dart';
import 'package:emp_management/services/api_service/api_provider.dart';

class SettingsRepo {
 final ApiProvider _api = ApiProvider();

  Future<AdminModel?> getAdminData() async {
  try {
    final response = await _api.get("/admin/me");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return AdminModel.fromJson(body["data"]);
    }

    return null;
  } catch (e) {
    print("Repo Error: $e");
    return null;
  }
}
}
