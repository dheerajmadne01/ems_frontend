import 'package:emp_management/employee/leave/repo/employee_repository.dart';
import 'package:emp_management/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emp_management/routes/app_routes.dart';

class LeaveController extends GetxController {
  LeaveController() : _repository = EmployeeRepository();

  final EmployeeRepository _repository;
  final selectedLeaveType = RxnString();
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final isSubmitting = false.obs;

  Future<void> pickStartDate(BuildContext context) async {
    try {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) {
        startDate.value = picked;
        if (endDate.value != null && endDate.value!.isBefore(picked)) {
          endDate.value = null;
        }
      }
    } catch (e) {
      ToastService.showError(
        'Failed to pick start date: ${_getErrorMessage(e)}',
      );
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    try {
      final base = startDate.value ?? DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: base,
        firstDate: base,
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) {
        endDate.value = picked;
      }
    } catch (e) {
      ToastService.showError('Failed to pick end date: ${_getErrorMessage(e)}');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String? get startDateLabel =>
      startDate.value != null ? _formatDate(startDate.value!) : null;

  String? get endDateLabel =>
      endDate.value != null ? _formatDate(endDate.value!) : null;

  int get calculatedDuration {
    if (startDate.value == null || endDate.value == null) return 0;
    return endDate.value!.difference(startDate.value!).inDays + 1;
  }

  Future<void> submitLeave({required String reason}) async {
    try {
      if (selectedLeaveType.value == null ||
          startDate.value == null ||
          endDate.value == null ||
          reason.trim().isEmpty) {
        ToastService.showError('Please fill all fields');
        return;
      }

      isSubmitting.value = true;
      await _repository.applyLeave(
        leaveType: selectedLeaveType.value!,
        startDate: startDate.value!.toIso8601String().split('T')[0],
        endDate: endDate.value!.toIso8601String().split('T')[0],
        reason: reason,
      );
      ToastService.showSuccess('Leave request submitted');

      selectedLeaveType.value = null;
      startDate.value = null;
      endDate.value = null;
      // Reason text controller is managed by the view and cleared there.
      Get.offAllNamed(AppRoutes.employeeHome);
    } catch (e) {
      ToastService.showError(_getErrorMessage(e));
    } finally {
      isSubmitting.value = false;
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
  void onClose() {
    super.onClose();
  }
}
