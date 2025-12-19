import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:emp_management/employee/home/controller/employee_attendance_controller.dart';
import 'package:emp_management/employee/widgets/attendance_punch_card.dart';
import 'package:emp_management/employee/widgets/attendance_stat_card.dart';
import 'package:emp_management/employee/widgets/info_stat_card.dart';
import 'package:emp_management/employee/widgets/today_activity_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  final controller = Get.find<EmployeeAttendanceController>();

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning,';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon,';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening,';
    } else {
      return 'Good Night,';
    }
  }

  String _formatDate(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final currentTime =
        '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    final currentDate = _formatDate(now);

return Scaffold(
  backgroundColor: Colors.white,
  body: SafeArea(
    child: Obx(() {
      final attendanceModel = controller.attendance.value;
      final isPunchedIn =
          attendanceModel?.punchInTime != null &&
          attendanceModel?.punchOutTime == null;

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await controller.loadDashboard();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(controller),
              const SizedBox(height: 24),
              AttendancePunchCard(
                currentTime: currentTime,
                currentDate: currentDate,
                location: 'Office Location',
                onPunchIn: () async {
                  final type = isPunchedIn ? 'out' : 'in';
                  await controller.punchWithLocation(type);
                },
                isPunchedIn: isPunchedIn,
                isPunching: controller.isPunching.value,
              ),
              const SizedBox(height: 24),
              _buildStatsSection(controller),
              const SizedBox(height: 24),
              _buildTodayActivitySection(controller, currentTime),
            ],
          ),
        ),
      );
    }),
  ),
);

  }

  Widget _buildHeader(EmployeeAttendanceController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 4),
            Obx(() {
              return Text(
                controller.userName.value,
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.person, color: AppColors.primary, size: 28),
        ),
      ],
    );
  }

  Widget _buildStatsSection(EmployeeAttendanceController controller) {
    final hasAttendance = controller.attendance.value?.punchInTime != null;
    final attendancePercent = hasAttendance ? 100.0 : 0.0;
    final leave = controller.leaveStatus.value;
    final leaveValue = leave == null ? '0' : leave.status.toUpperCase();
    final workedDuration =
        (controller.attendance.value?.punchInTime != null &&
            controller.attendance.value?.punchOutTime != null)
        ? controller.attendance.value!.punchOutTime!
              .difference(controller.attendance.value!.punchInTime!)
              .inHours
        : 0;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AttendanceStatCard(
            percentage: attendancePercent,
            label: 'Attendance',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: InfoStatCard(
            label: 'Pending Leaves',
            value: leaveValue,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: InfoStatCard(
            label: 'Working Days',
            value: workedDuration > 0 ? '${workedDuration}h' : '0h',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayActivitySection(
    EmployeeAttendanceController controller,
    String currentTime,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Activity",
          style: AppTextStyles.heading3.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (controller.attendance.value?.punchInTime != null)
          TodayActivityItem(
            type: 'Punch In',
            time: controller.attendance.value!.punchInTime!
                .toLocal()
                .toString(),
            status: 'Recorded',
            icon: Icons.access_time,
          ),
        if (controller.attendance.value?.punchOutTime != null)
          TodayActivityItem(
            type: 'Punch Out',
            time: controller.attendance.value!.punchOutTime!
                .toLocal()
                .toString(),
            status: 'Recorded',
            icon: Icons.logout,
          ),
      ],
    );
  }
}
