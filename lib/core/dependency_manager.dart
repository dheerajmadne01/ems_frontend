import 'package:emp_management/admin/add_employee/controller/employee_controller.dart';
import 'package:emp_management/admin/attendence/controller/attendance_controller.dart';
import 'package:emp_management/admin/attendence/repo/attendance_repository.dart';
import 'package:emp_management/admin/dashboard/controller/admin_dashboard_controller.dart';
import 'package:emp_management/admin/dashboard/repo/admin_repository.dart';
import 'package:emp_management/admin/leaves/controller/leave_requests_controller.dart';
import 'package:emp_management/admin/leaves/repo/leave_repository.dart';
import 'package:emp_management/auth/controller/auth_controller.dart';
import 'package:emp_management/auth/repo/auth_repository.dart';
import 'package:emp_management/employee/home/controller/employee_attendance_controller.dart';
import 'package:emp_management/employee/leave/controller/leave_controller.dart';
import 'package:emp_management/employee/leave/repo/employee_repository.dart'
    as employee_repos;
import 'package:emp_management/services/api_service/api_provider.dart';
import 'package:emp_management/services/location_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DependencyManager {
  const DependencyManager._();

  static Future<void> init() async {
    if (!Get.isRegistered<GetStorage>()) {
      Get.put<GetStorage>(GetStorage(), permanent: true);
    }

    if (!Get.isRegistered<ApiProvider>()) {
      Get.put<ApiProvider>(ApiProvider(), permanent: true);
    }

    if (!Get.isRegistered<LocationService>()) {
      Get.put<LocationService>(const LocationService(), permanent: true);
    }

    _registerAuth();
    _registerAdmin();
    _registerEmployee();
  }

  static void _registerAuth() {
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(Get.find<ApiProvider>(), Get.find<GetStorage>()),
      fenix: true,
    );

    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<AuthRepository>()),
      fenix: true,
    );
  }

  static void _registerAdmin() {
    Get.lazyPut<AdminRepository>(
      () => AdminRepository(Get.find<ApiProvider>()),
      fenix: true,
    );

    Get.lazyPut<AdminDashboardController>(
      () => AdminDashboardController(Get.find<AdminRepository>()),
      fenix: true,
    );

    Get.lazyPut<AttendanceRepository>(
      () => AttendanceRepository(Get.find<ApiProvider>(), Get.find<GetStorage>()),
      fenix: true,
    );

    Get.lazyPut<AttendanceController>(
      () => AttendanceController(Get.find<AttendanceRepository>()),
      fenix: true,
    );

    Get.lazyPut<EmployeeController>(
      () => EmployeeController(),
      fenix: true,
    );

    Get.lazyPut<AdminLeaveRepository>(
      () => AdminLeaveRepository(Get.find<ApiProvider>()),
      fenix: true,
    );

    Get.lazyPut<LeaveRequestsController>(
      () => LeaveRequestsController(Get.find<AdminLeaveRepository>()),
      fenix: true,
    );
  }

  static void _registerEmployee() {
    Get.lazyPut<employee_repos.EmployeeRepository>(
      () => employee_repos.EmployeeRepository(
        Get.find<ApiProvider>(),
        Get.find<GetStorage>(),
      ),
      fenix: true,
    );

    Get.lazyPut<EmployeeAttendanceController>(
      () => EmployeeAttendanceController(
        Get.find<employee_repos.EmployeeRepository>(),
        Get.find<LocationService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<LeaveController>(
      () => LeaveController(Get.find<employee_repos.EmployeeRepository>()),
      fenix: true,
    );
  }
}

