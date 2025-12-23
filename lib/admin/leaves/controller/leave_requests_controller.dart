import 'package:emp_management/admin/leaves/model/leave_request_model.dart';
import 'package:emp_management/admin/leaves/repo/leave_repository.dart';
import 'package:emp_management/services/toast_service.dart';
import 'package:get/get.dart';

class LeaveRequestsController extends GetxController {
  LeaveRequestsController() : _repository = AdminLeaveRepository();

  final AdminLeaveRepository _repository;

  final isLoading = false.obs;
  final pendingLeaves = <LeaveRequestModel>[].obs;
  final historyLeaves = <LeaveRequestModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLeaves();
  }

  Future<void> loadLeaves({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }
      final leaves = await _repository.fetchLeaveRequests();
      pendingLeaves.assignAll(
        leaves.where((leave) => leave.isPending).toList(),
      );
      historyLeaves.assignAll(
        leaves.where((leave) => !leave.isPending).toList(),
      );
    } catch (e) {
      ToastService.showError(_getErrorMessage(e));
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  Future<void> decideLeave(LeaveRequestModel leave, String action) async {
    try {
      await _repository.decideLeave(leaveId: leave.id, action: action);
      ToastService.showSuccess(
        action == 'approve' ? 'Leave approved' : 'Leave rejected',
      );
      await loadLeaves(showLoader: false);
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

