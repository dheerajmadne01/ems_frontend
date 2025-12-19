import 'package:emp_management/admin/dashboard/model/admin_model.dart';
import 'package:emp_management/admin/dashboard/repo/admin_repository.dart';
import 'package:emp_management/services/toast_service.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  AdminDashboardController() : _repository = AdminRepository();

  final AdminRepository _repository;

  final employees = <DashboardEmployee>[].obs;
  final summary = Rxn<DashboardSummary>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final dashboard = await _repository.fetchDashboard();
      summary.value = dashboard.summary;
      employees.assignAll(dashboard.employees);
      update();
    } catch (e) {
      ToastService.showError(_getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

Future<void> setCompanyLocation({
  required double lat,
  required double lng,
}) async {
  try {
    await _repository.setCompanyLocation(lat: lat, lng: lng);
    // ToastService.showSuccess('Office location updated');
  } catch (e) {
    ToastService.showError(_getErrorMessage(e));
  }
}

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      return message;
    }
    return error.toString();
  }
}


