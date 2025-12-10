import 'package:emp_management/services/toast_service.dart';
import 'package:get/get.dart';
import '../model/employee_model.dart';
import '../repo/employee_repository.dart';

class EmployeeListController extends GetxController {
  final EmployeeRepository repo = EmployeeRepository();

  RxBool isLoading = false.obs;
  RxList<EmployeeModel> employees = <EmployeeModel>[].obs;

  Future<void> loadEmployees() async {
    try {
      isLoading.value = true;
      final result = await repo.fetchEmployees();
      employees.assignAll(result);
    } catch (e) {
      ToastService.showError(_getErrorMessage(e));
    } finally {
      isLoading.value = false;
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

  @override
  void onInit() {
    loadEmployees();
    super.onInit();
  }
}
