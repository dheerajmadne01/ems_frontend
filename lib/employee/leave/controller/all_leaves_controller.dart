import 'package:emp_management/employee/leave/model/leave_models.dart';
import 'package:emp_management/employee/leave/repo/employee_repository.dart';
import 'package:emp_management/services/toast_service.dart';
import 'package:get/get.dart';

class AllLeavesController extends GetxController {
  AllLeavesController() : _repository = EmployeeRepository();

  final EmployeeRepository _repository;
  final leaves = <LeaveStatusModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLeaves();
  }

  Future<void> loadLeaves() async {
    try {
      isLoading.value = true;
      final result = await _repository.getAllLeaves();
      leaves.assignAll(result);
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
}