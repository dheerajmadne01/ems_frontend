import 'package:emp_management/admin/add_employee/controller/employee_controller.dart';
import 'package:emp_management/admin/add_employee/view/add_employee_screen.dart';
import 'package:emp_management/admin/all_emp/controller/employee_controller.dart';
import 'package:emp_management/admin/all_emp/view/employees_screen.dart';
import 'package:emp_management/admin/attendence/controller/attendance_controller.dart';
import 'package:emp_management/admin/attendence/view/attendance_screen.dart';
import 'package:emp_management/admin/dashboard/controller/admin_dashboard_controller.dart';
import 'package:emp_management/admin/dashboard/view/dashboard_screen.dart';
import 'package:emp_management/admin/dashboard/view/set_location_screen.dart';
import 'package:emp_management/admin/leaves/controller/leave_requests_controller.dart';
import 'package:emp_management/admin/leaves/view/leave_requests_screen.dart';
import 'package:emp_management/admin/salary/view/salary_screen.dart';
import 'package:emp_management/admin/settings/controller/settings_controller.dart';
import 'package:emp_management/admin/settings/view/settings_screen.dart';
import 'package:emp_management/admin/widgets/main_navigation.dart';
import 'package:emp_management/auth/controller/auth_controller.dart';
import 'package:emp_management/auth/view/login_view.dart';
import 'package:emp_management/employee/home/controller/employee_attendance_controller.dart';
import 'package:emp_management/employee/home/view/employee_home_screen.dart';
import 'package:emp_management/employee/leave/controller/all_leaves_controller.dart';
import 'package:emp_management/employee/leave/controller/leave_controller.dart';
import 'package:emp_management/employee/leave/view/all_leaves_screen.dart';
import 'package:emp_management/employee/leave/view/employee_leave_screen.dart';
import 'package:emp_management/employee/profile/controller/employee_profile_controller.dart';
import 'package:emp_management/employee/profile/view/employee_profile_screen.dart';
import 'package:emp_management/employee/salary/view/employee_salary_screen.dart';
import 'package:emp_management/employee/widgets/employee_navigation.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    // Auth Pages
    GetPage<LoginScreen>(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      }),
    ),

    // Admin Main Navigation
    GetPage<MainNavigation>(
      name: AppRoutes.adminHome,
      page: () => const MainNavigation(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminDashboardController>(
          () => AdminDashboardController(),
          fenix: true,
        );
        Get.lazyPut<EmployeeListController>(
          () => EmployeeListController(),
          fenix: true,
        );
        Get.lazyPut<AttendanceController>(
          () => AttendanceController(),
          fenix: true,
        );
        Get.lazyPut<SettingsController>(
          () => SettingsController(),
          fenix: true,
        );
      }),
    ),

    // Admin Individual Screens
    GetPage<DashboardScreen>(
      name: AppRoutes.adminDashboard,
      page: () => const DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminDashboardController>(
          () => AdminDashboardController(),
          fenix: true,
        );
      }),
    ),
    GetPage<EmployeesScreen>(
      name: AppRoutes.adminEmployees,
      page: () => const EmployeesScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EmployeeListController>(
          () => EmployeeListController(),
          fenix: true,
        );
      }),
    ),
    GetPage<AttendanceScreen>(
      name: AppRoutes.adminAttendance,
      page: () => const AttendanceScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AttendanceController>(
          () => AttendanceController(),
          fenix: true,
        );
      }),
    ),
    GetPage<SalaryScreen>(
      name: AppRoutes.adminSalary,
      page: () => const SalaryScreen(),
    ),
    GetPage<SettingsScreen>(
      name: AppRoutes.adminSettings,
      page: () => const SettingsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(
          () => SettingsController(),
          fenix: true,
        );
      }),
    ),
    GetPage<AddEmployeeScreen>(
      name: AppRoutes.addEmployee,
      page: () => const AddEmployeeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EmployeeController>(
          () => EmployeeController(),
          fenix: true,
        );
      }),
    ),
    GetPage<LeaveRequestsScreen>(
      name: AppRoutes.adminLeaveRequests,
      page: () => const LeaveRequestsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LeaveRequestsController>(
          () => LeaveRequestsController(),
          fenix: true,
        );
      }),
    ),
    GetPage<SetLocationScreen>(
      name: AppRoutes.setLocation,
      page: () => const SetLocationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminDashboardController>(
          () => AdminDashboardController(),
          fenix: true,
        );
      }),
    ),

    // Employee Main Navigation
    GetPage<EmployeeNavigation>(
      name: AppRoutes.employeeHome,
      page: () => const EmployeeNavigation(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EmployeeAttendanceController>(
          () => EmployeeAttendanceController(),
          fenix: true,
        );
        Get.lazyPut<LeaveController>(
          () => LeaveController(),
          fenix: true,
        );
        Get.lazyPut<EmployeeProfileController>(
          () => EmployeeProfileController(),
          fenix: true,
        );
      }),
    ),

    // Employee Individual Screens
    GetPage<EmployeeHomeScreen>(
      name: '/employee/home',
      page: () => const EmployeeHomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EmployeeAttendanceController>(
          () => EmployeeAttendanceController(),
          fenix: true,
        );
      }),
    ),
    GetPage<EmployeeLeaveScreen>(
      name: AppRoutes.employeeLeave,
      page: () => const EmployeeLeaveScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LeaveController>(
          () => LeaveController(),
          fenix: true,
        );
      }),
    ),
    GetPage<AllLeavesScreen>(
      name: AppRoutes.employeeAllLeaves,
      page: () => const AllLeavesScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AllLeavesController>(
          () => AllLeavesController(),
          fenix: true,
        );
      }),
    ),
    GetPage<EmployeeSalaryScreen>(
      name: AppRoutes.employeeSalary,
      page: () => const EmployeeSalaryScreen(),
    ),
    GetPage<EmployeeProfileScreen>(
      name: AppRoutes.employeeProfile,
      page: () => const EmployeeProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EmployeeProfileController>(
          () => EmployeeProfileController(),
          fenix: true,
        );
      }),
    ),
  ];
}
