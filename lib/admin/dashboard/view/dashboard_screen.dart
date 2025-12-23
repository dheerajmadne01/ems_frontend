import 'package:emp_management/admin/dashboard/controller/admin_dashboard_controller.dart';
import 'package:emp_management/admin/dashboard/model/admin_model.dart';
import 'package:emp_management/admin/settings/controller/settings_controller.dart';
import 'package:emp_management/admin/widgets/action_button.dart';
import 'package:emp_management/admin/widgets/stat_card.dart';
import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:emp_management/routes/app_routes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();
    final settingsController = Get.find<SettingsController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: GetBuilder<AdminDashboardController>(
          builder: (_) {
            final summary = controller.summary.value;
            final totalEmployees = summary?.totalEmployees ?? 0;
            final presentToday = summary?.present ?? 0;
            final onLeave = summary?.onLeave ?? 0;
            final pendingLeaves = summary?.pendingLeaves ?? 0;

            if (controller.isLoading.value && controller.employees.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(  
              onRefresh: () async {
                await controller.loadDashboard();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingCard(settingsController.name),
                    const SizedBox(height: 18),
                    _buildQuickActions(
                      onAddEmployee: () => Get.toNamed(AppRoutes.addEmployee),
                      onApproveLeave: () =>
                          Get.toNamed(AppRoutes.adminLeaveRequests),
                      onSetLocation: () =>
                          Get.toNamed(AppRoutes.setLocation),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Overview',
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewCards(
                      totalEmployees: totalEmployees,
                      presentToday: presentToday,
                      onLeave: onLeave,
                      pendingLeaves: pendingLeaves,
                    ),
                    const SizedBox(height: 22),
                    _buildWeeklyAttendance(),
                    const SizedBox(height: 22),
                    _buildRecentActivity(controller.employees),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGreetingCard(String adminName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.18),
                  AppColors.primary.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  adminName.isNotEmpty ? adminName : 'Admin User',
                  style: AppTextStyles.heading3.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none,
                color: AppColors.primary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions({
    required VoidCallback onAddEmployee,
    required VoidCallback onApproveLeave,
    required VoidCallback onSetLocation,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ActionButton(
                label: 'Add Employee',
                icon: Icons.person_add_alt_1,
                backgroundColor: AppColors.primary,
                iconColor: Colors.white,
                textColor: Colors.white,
                borderColor: Colors.transparent,
                onPressed: onAddEmployee,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionButton(
                label: 'Approve Leave',
                icon: Icons.fact_check,
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                iconColor: AppColors.textPrimary,
                borderColor: AppColors.border,
                onPressed: onApproveLeave,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onSetLocation,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Set office location',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildOverviewCards({
    required int totalEmployees,
    required int presentToday,
    required int onLeave,
    required int pendingLeaves,
  }) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      children: [
        StatCard(
          label: 'Total Employees',
          value: '$totalEmployees',
          icon: Icons.people_alt,
          iconColor: AppColors.primary,
          badge: '+2.5%',
          badgeColor: const Color(0xFFE9F7EF),
          badgeTextColor: AppColors.success,
        ),
        StatCard(
          label: 'Present Today',
          value: '$presentToday',
          icon: Icons.check_circle,
          iconColor: AppColors.success,
          backgroundColor: Colors.white,
        ),
        StatCard(
          label: 'On Leave',
          value: '$onLeave',
          icon: Icons.airline_seat_individual_suite,
          iconColor: AppColors.warning,
          backgroundColor: Colors.white,
        ),
        StatCard(
          label: 'Leave Requests',
          value: '$pendingLeaves',
          icon: Icons.flight_takeoff,
          iconColor: const Color(0xFF7B61FF),
          backgroundColor: Colors.white,
          showAlert: pendingLeaves > 0,
        ),
      ],
    );
  }

  Widget _buildWeeklyAttendance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Attendance',
                    style: AppTextStyles.heading3.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'View Report',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                            if (value.toInt() >= 0 &&
                                value.toInt() < days.length) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 6.0, right: 6),
                                child: Text(
                                  days[value.toInt()],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 38),
                          FlSpot(1, 40),
                          FlSpot(2, 42),
                          FlSpot(3, 41),
                          FlSpot(4, 42),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(List<DashboardEmployee> employees) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: AppTextStyles.heading3.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (employees.isEmpty)
            Text(
              'No recent updates yet.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: employees.length.clamp(0, 4).toInt(),
              separatorBuilder: (_, __) => const Divider(
                height: 16,
                color: Color(0xFFEFF1F4),
              ),
              itemBuilder: (_, index) {
                final employee = employees[index];
                final status = _statusLabel(employee);
                final statusColor = _statusColor(status);
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.08),
                      child: const Icon(Icons.person,
                          size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name.isNotEmpty
                                ? employee.name
                                : 'Employee',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            employee.jobRole ?? employee.department ?? '',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusChip(status, statusColor),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  String _statusLabel(DashboardEmployee employee) {
    if (employee.pendingLeaves > 0) return 'Pending Leave';
    if (employee.activeLeaves > 0 || employee.status.toLowerCase() == 'leave') {
      return 'On Leave';
    }
    if (employee.punchedIn && !employee.punchedOut) return 'Present';
    return 'Offline';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Present':
        return AppColors.success;
      case 'On Leave':
        return AppColors.warning;
      case 'Pending Leave':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
