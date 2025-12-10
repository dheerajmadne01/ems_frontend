import 'package:emp_management/admin/add_employee/view/add_employee_screen.dart';
import 'package:emp_management/admin/all_emp/view/employees_screen.dart';
import 'package:emp_management/admin/attendence/view/attendance_screen.dart';
import 'package:emp_management/admin/dashboard/view/dashboard_screen.dart';
import 'package:emp_management/admin/dashboard/view/set_location_screen.dart';
import 'package:emp_management/admin/leaves/view/leave_requests_screen.dart';
import 'package:emp_management/admin/salary/view/salary_screen.dart';
import 'package:emp_management/admin/settings/view/settings_screen.dart';
import 'package:emp_management/admin/widgets/main_navigation.dart';
import 'package:emp_management/auth/view/login_view.dart';
import 'package:emp_management/employee/home/view/employee_home_screen.dart';
import 'package:emp_management/employee/leave/view/employee_leave_screen.dart';
import 'package:emp_management/employee/profile/view/employee_profile_screen.dart';
import 'package:emp_management/employee/salary/view/employee_salary_screen.dart';
import 'package:emp_management/employee/widgets/employee_navigation.dart';
import 'package:emp_management/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static final List<GetPage> pages = [
    // Auth Pages
    GetPage<LoginScreen>(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),

    // Admin Main Navigation
    GetPage<MainNavigation>(
      name: AppRoutes.adminHome,
      page: () => const MainNavigation(),
    ),

    // Admin Individual Screens
    GetPage<DashboardScreen>(
      name: AppRoutes.adminDashboard,
      page: () => const DashboardScreen(),
    ),
    GetPage<EmployeesScreen>(
      name: AppRoutes.adminEmployees,
      page: () => const EmployeesScreen(),
    ),
    GetPage<AttendanceScreen>(
      name: AppRoutes.adminAttendance,
      page: () => const AttendanceScreen(),
    ),
    GetPage<SalaryScreen>(
      name: AppRoutes.adminSalary,
      page: () => const SalaryScreen(),
    ),
    GetPage<SettingsScreen>(
      name: AppRoutes.adminSettings,
      page: () => const SettingsScreen(),
    ),
    GetPage<AddEmployeeScreen>(
      name: AppRoutes.addEmployee,
      page: () => const AddEmployeeScreen(),
    ),
    GetPage<LeaveRequestsScreen>(
      name: AppRoutes.adminLeaveRequests,
      page: () => const LeaveRequestsScreen(),
    ),
    GetPage<SetLocationScreen>(
      name: AppRoutes.setLocation,
      page: () => const SetLocationScreen(),
    ),

    // Employee Main Navigation
    GetPage<EmployeeNavigation>(
      name: AppRoutes.employeeHome,
      page: () => const EmployeeNavigation(),
    ),

    // Employee Individual Screens
    GetPage<EmployeeHomeScreen>(
      name: '/employee/home',
      page: () => const EmployeeHomeScreen(),
    ),
    GetPage<EmployeeLeaveScreen>(
      name: AppRoutes.employeeLeave,
      page: () => const EmployeeLeaveScreen(),
    ),
    GetPage<EmployeeSalaryScreen>(
      name: AppRoutes.employeeSalary,
      page: () => const EmployeeSalaryScreen(),
    ),
    GetPage<EmployeeProfileScreen>(
      name: AppRoutes.employeeProfile,
      page: () => const EmployeeProfileScreen(),
    ),
  ];
}
