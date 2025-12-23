import 'dart:async';

import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:emp_management/employee/home/controller/employee_attendance_controller.dart';
import 'package:emp_management/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  final controller = Get.find<EmployeeAttendanceController>();

  @override
  void initState() {
    super.initState();
    // Start timer if punched in
    if (controller.attendance.value?.isPunchedIn == true) {
      _startTimer();
    }
  }

  Timer? _timer;
  Duration _shiftDuration = Duration.zero;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted && controller.attendance.value?.punchInTime != null) {
        final punchIn = controller.attendance.value!.punchInTime!;
        final now = DateTime.now();
        
        // Subtract break time if on break
        Duration breakDuration = Duration.zero;
        if (controller.attendance.value?.breakStartTime != null &&
            controller.attendance.value?.breakEndTime == null) {
          breakDuration = now.difference(controller.attendance.value!.breakStartTime!);
        }
        
        _shiftDuration = now.difference(punchIn) - breakDuration;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _shiftDuration = Duration.zero;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Obx(() {
          final attendance = controller.attendance.value;
          final leaveStatus = controller.leaveStatus.value;
          final isPunchedIn = attendance?.isPunchedIn ?? false;
          final isOnBreak = attendance?.isOnBreak ?? false;

          // Update timer when attendance changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isPunchedIn && _timer == null) {
              _startTimer();
            } else if (!isPunchedIn && _timer != null) {
              _stopTimer();
            }
          });

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await controller.loadDashboard(showLoader: false);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),

                // Shift Status Card
                _buildShiftStatusCard(attendance, isPunchedIn, isOnBreak),
                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(),
                const SizedBox(height: 24),

                // Leave Balance
                _buildLeaveBalance(leaveStatus),
                const SizedBox(height: 24),

                // Punch Button
                _buildPunchButton(isPunchedIn, isOnBreak),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee Dashboard',
              style: AppTextStyles.heading3.copyWith(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Obx(() => Text(
                        controller.userName.value.isNotEmpty
                            ? controller.userName.value[0].toUpperCase()
                            : 'E',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primary,
                        ),
                      )),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Obx(() => Text(
                      controller.userName.value.isNotEmpty
                          ? controller.userName.value
                          : 'Employee',
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    Text(
                      _formatDate(DateTime.now()),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_none, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildShiftStatusCard(dynamic attendance, bool isPunchedIn, bool isOnBreak) {
    final hours = _shiftDuration.inHours.toString().padLeft(2, '0');
    final minutes = (_shiftDuration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_shiftDuration.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPunchedIn
                      ? (isOnBreak ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1))
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isPunchedIn
                            ? (isOnBreak ? Colors.orange : Colors.green)
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPunchedIn
                          ? (isOnBreak ? 'ON BREAK' : 'ON SHIFT')
                          : 'OFF SHIFT',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isPunchedIn
                            ? (isOnBreak ? Colors.orange : Colors.green)
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (attendance?.punchInTime != null)
                Text(
                  'Punched In: ${_formatTime(attendance!.punchInTime!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (isPunchedIn)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeUnit(hours, 'HRS'),
                const SizedBox(width: 8),
                Text(
                  ':',
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 32,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                _buildTimeUnit(minutes, 'MIN'),
                const SizedBox(width: 8),
                Text(
                  ':',
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 32,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                _buildTimeUnit(seconds, 'SEC', highlight: true),
              ],
            )
          else
            Center(
              child: Text(
                'Not punched in',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label, {bool highlight = false}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(highlight ? 12 : 8),
          decoration: highlight
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                )
              : null,
          child: Text(
            value,
            style: AppTextStyles.heading1.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.heading3.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickActionButton(
              icon: Icons.coffee_outlined,
              label: 'Break',
              color: Colors.orange,
              onTap: () {
                final attendance = controller.attendance.value;
                if (attendance?.isOnBreak == true) {
                  controller.punchWithLocation('break_end');
                } else if (attendance?.isPunchedIn == true) {
                  controller.punchWithLocation('break_start');
                } else {
                  Get.snackbar('Info', 'Please punch in first');
                }
              },
            ),
            _buildQuickActionButton(
              icon: Icons.event_busy_outlined,
              label: 'Req. Leave',
              color: Colors.blue,
              onTap: () => Get.toNamed(AppRoutes.employeeLeave),
            ),
            _buildQuickActionButton(
              icon: Icons.receipt_long_outlined,
              label: 'Payslip',
              color: Colors.purple,
              onTap: () => Get.toNamed(AppRoutes.employeeSalary),
            ),
            _buildQuickActionButton(
              icon: Icons.people_outline,
              label: 'Team',
              color: Colors.green,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveBalance(dynamic leaveStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Leave Balance',
              style: AppTextStyles.heading3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.employeeAllLeaves),
              child: Text(
                'View All >',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (leaveStatus != null)
          _buildLeaveCard(
            icon: Icons.flight_takeoff,
            label: 'Casual',
            used: 4,
            total: 12,
            color: Colors.pink,
          )
        else
          _buildLeaveCard(
            icon: Icons.flight_takeoff,
            label: 'Casual',
            used: 0,
            total: 12,
            color: Colors.pink,
          ),
        const SizedBox(height: 12),
        _buildLeaveCard(
          icon: Icons.sick,
          label: 'Sick',
          used: 2,
          total: 10,
          color: Colors.red,
        ),
        const SizedBox(height: 12),
        _buildLeaveCard(
          icon: Icons.star_outline,
          label: 'Annual',
          used: 0,
          total: 15,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildLeaveCard({
    required IconData icon,
    required String label,
    required int used,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? (used / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$used / $total DAYS',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPunchButton(bool isPunchedIn, bool isOnBreak) {
    final attendance = controller.attendance.value;
    final isPunchedOut = attendance?.punchOutTime != null;
    
    String buttonText;
    IconData buttonIcon;
    VoidCallback? onPressed;

    // If punched out, show Punch In
    if (isPunchedOut) {
      buttonText = 'Punch In';
      buttonIcon = Icons.fingerprint;
      onPressed = () => controller.punchWithLocation('in');
    }
    // If punched in (regardless of break status), show Punch Out
    else if (isPunchedIn) {
      buttonText = 'Punch Out';
      buttonIcon = Icons.logout;
      onPressed = () => controller.punchWithLocation('out');
    }
    // If not punched in, show Punch In
    else {
      buttonText = 'Punch In';
      buttonIcon = Icons.fingerprint;
      onPressed = () => controller.punchWithLocation('in');
    }

    return Obx(() => Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.isPunching.value ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: controller.isPunching.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(buttonIcon, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        buttonText,
                        style: AppTextStyles.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ));
  }
}
