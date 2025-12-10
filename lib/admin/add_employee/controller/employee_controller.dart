import 'package:emp_management/routes/app_routes.dart';
import 'package:emp_management/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repo/employee_repository.dart';
  class EmployeeController extends GetxController {
  final EmployeeRepository repo = EmployeeRepository();

  final fullName = TextEditingController();
  final employeeId = TextEditingController();
  final jobRole = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final salary = TextEditingController();

  String? selectedDepartment;

  RxBool isLoading = false.obs;

  Future<void> createEmployee({
    required GlobalKey<FormState> formKey,
  }) async {
    try {
      if (!formKey.currentState!.validate()) return;

      if (selectedDepartment == null) {
        ToastService.showError("Please select a department");
        return;
      }

      isLoading.value = true;
      update();

      await repo.createEmployee(
        fullName: fullName.text.trim(),
        department: selectedDepartment!,
        jobRole: jobRole.text.trim(),
        email: email.text.trim(),
        phone: phone.text.trim(),
        salary: salary.text.trim(),
        employeeId: employeeId.text.trim(),
      );

      ToastService.showSuccess("Employee created successfully");

      clearFields();  

      Get.offAllNamed(AppRoutes.adminHome);
    } catch (e) {
      ToastService.showError(_getErrorMessage(e));
    } finally {
      isLoading.value = false;
      update();
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

  void clearFields() {
    fullName.clear();
    employeeId.clear();
    jobRole.clear();
    email.clear();
    phone.clear();
    salary.clear();
    selectedDepartment = null;
    update();
  }

  @override
  void onClose() {
    fullName.dispose();
    employeeId.dispose();
    jobRole.dispose();
    email.dispose();
    phone.dispose();
    salary.dispose();
    super.onClose();
  }
}
