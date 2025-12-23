import 'package:emp_management/employee/home/model/attendance_models.dart';
import 'package:emp_management/employee/leave/model/leave_models.dart';
import 'package:emp_management/employee/leave/repo/employee_repository.dart';
import 'package:emp_management/services/location_service.dart';
import 'package:emp_management/services/toast_service.dart';
import 'package:emp_management/services/api_service/api_provider.dart';
import 'package:get/get.dart';

class EmployeeAttendanceController extends GetxController {
  EmployeeAttendanceController()
      : _repository = EmployeeRepository(),
        _locationService = const LocationService();

  final EmployeeRepository _repository;
  final LocationService _locationService;

  final attendance = Rxn<AttendanceRecordModel>();
  final leaveStatus = Rxn<LeaveStatusModel>();
  final isLoading = false.obs;
  final isPunching = false.obs;
  final userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    userName.value = _repository.currentUserName ?? 'Employee';
    loadDashboard();
  }

  Future<void> loadDashboard({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }
      final result = await _repository.getTodayAttendance();
      final leave = await _repository.getLeaveStatus();
      attendance.value = result;
      leaveStatus.value = leave;
      update();
    } catch (e) {
      ToastService.showError(
        'Failed to load dashboard: ${_getErrorMessage(e)}',
      );
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
      update();
    }
  }

  Future<void> punchWithLocation(String type) async {
    try {
      isPunching.value = true;
      update();

      final position = await _locationService.getCurrentPosition();
      final attendanceResult = await _repository.punch(
        lat: position.latitude,
        lng: position.longitude,
        type: type, // 'in', 'out', 'break_start', 'break_end'
      );

      if (attendanceResult != null) {
        attendance.value = attendanceResult;
      } else {
        await loadDashboard();
      }
      update();

      String message;
      switch (type.toLowerCase()) {
        case 'out':
          message = 'Punched out successfully';
          break;
        case 'break_start':
          message = 'Break started successfully';
          break;
        case 'break_end':
          message = 'Break ended successfully';
          break;
        default:
          message = 'Punched in successfully';
      }
      ToastService.showSuccess(message);
    } catch (e) {
      ToastService.showError(_getErrorMessage(e));
    } finally {
      isPunching.value = false;
      update();
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }

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
