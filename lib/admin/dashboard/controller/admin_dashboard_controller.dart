import 'package:emp_management/admin/dashboard/model/admin_model.dart';
import 'package:emp_management/admin/dashboard/repo/admin_repository.dart';
import 'package:emp_management/admin/attendence/model/attendance_models.dart' as attendance;
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
      
      // Fetch data from multiple APIs
      final allEmployees = await _repository.fetchAllEmployees();
      final today = DateTime.now();
      final attendanceData = await _repository.fetchAttendanceData(date: today);
      final leaveRequests = await _repository.fetchLeaveRequests();

      // Calculate summary
      final totalEmployees = allEmployees.length;
      
      // Count present employees (those who punched in today)
      int presentCount = 0;
      final todayDateOnly = DateTime(today.year, today.month, today.day);
      
      for (final emp in attendanceData) {
        // Check if employee has punch in today
        final hasPunchInToday = emp.punches.any((punch) {
          if (punch.punchInTime == null) return false;
          final punchDate = DateTime(
            punch.punchInTime!.year,
            punch.punchInTime!.month,
            punch.punchInTime!.day,
          );
          return punchDate.isAtSameMomentAs(todayDateOnly);
        });
        
        if (hasPunchInToday) {
          presentCount++;
        }
      }

      // Count employees on leave (active approved leaves that include today)
      int onLeaveCount = 0;
      final activeLeaves = leaveRequests.where((leave) {
        final status = leave.status.toLowerCase();
        if (status != 'approved') return false;
        
        final startDate = DateTime(
          leave.startDate.year,
          leave.startDate.month,
          leave.startDate.day,
        );
        final endDate = DateTime(
          leave.endDate.year,
          leave.endDate.month,
          leave.endDate.day,
        );
        
        return !todayDateOnly.isBefore(startDate) && 
               !todayDateOnly.isAfter(endDate);
      }).toList();
      
      // Get unique employee IDs on leave
      final onLeaveEmployeeIds = activeLeaves.map((l) => l.employeeId).toSet();
      onLeaveCount = onLeaveEmployeeIds.length;

      // Count pending leave requests
      final pendingLeavesCount = leaveRequests
          .where((leave) => leave.status.toLowerCase() == 'pending')
          .length;

      // Create summary
      summary.value = DashboardSummary(
        totalEmployees: totalEmployees,
        present: presentCount,
        absent: totalEmployees - presentCount - onLeaveCount,
        onLeave: onLeaveCount,
        pendingLeaves: pendingLeavesCount,
      );

      // Convert to DashboardEmployee list for recent activity
      final recentEmployees = allEmployees.take(4).map((emp) {
        // Find attendance status for this employee
        final attendanceEmp = attendanceData.firstWhere(
          (a) => a.id == emp.id,
          orElse: () => attendance.EmployeeModel(
            id: emp.id,
            empId: emp.empId,
            name: emp.name,
            punches: [],
            leaves: [],
          ),
        );
        
        // Check if on leave
        final isOnLeave = activeLeaves.any((l) => l.employeeId == emp.id);
        
        // Check if punched in today
        final todayPunches = attendanceEmp.punches.where((punch) {
          if (punch.punchInTime == null) return false;
          final punchDate = DateTime(
            punch.punchInTime!.year,
            punch.punchInTime!.month,
            punch.punchInTime!.day,
          );
          return punchDate.isAtSameMomentAs(todayDateOnly);
        }).toList();
        
        final hasPunchIn = todayPunches.isNotEmpty;
        final punchInTime = hasPunchIn ? todayPunches.first.punchInTime : null;
        
        return DashboardEmployee(
          id: emp.id,
          empId: emp.empId,
          name: emp.name,
          email: emp.email,
          department: emp.department,
          jobRole: emp.jobRole,
          status: isOnLeave ? 'leave' : (hasPunchIn ? 'present' : 'offline'),
          punchedIn: hasPunchIn,
          punchedOut: false,
          punchInTime: punchInTime,
          punchOutTime: null,
          pendingLeaves: leaveRequests
              .where((l) => l.employeeId == emp.id && l.status.toLowerCase() == 'pending')
              .length,
          activeLeaves: isOnLeave ? 1 : 0,
        );
      }).toList();

      employees.assignAll(recentEmployees);
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


