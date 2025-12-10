import 'package:emp_management/admin/dashboard/controller/admin_dashboard_controller.dart';
import 'package:emp_management/admin/widgets/action_button.dart';
import 'package:emp_management/admin/widgets/screen_header.dart';
import 'package:emp_management/admin/widgets/stat_card.dart';
import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:emp_management/routes/app_routes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<AdminDashboardController>(
          builder: (_) {
            final summary = controller.summary.value;
            final totalEmployees =
                summary?.totalEmployees ?? controller.employees.length;
            final presentToday = summary?.present ?? 0;
            final pendingLeaves = summary?.pendingLeaves ?? 0;

            if (controller.isLoading.value && controller.employees.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                await controller.loadDashboard();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildStatsCards(
                      totalEmployees: totalEmployees,
                      presentToday: presentToday,
                      pendingLeaves: pendingLeaves,
                      onPendingLeavesTap: () =>
                          Get.toNamed(AppRoutes.adminLeaveRequests),
                    ),
                    const SizedBox(height: 24),
                    _buildActionButtons(context, controller),
                    const SizedBox(height: 24),
                    _buildAttendanceTrend(),
                    const SizedBox(height: 24),
                    _buildSalaryExpense(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ScreenHeader(
      title: 'Dashboard',
      subtitle: 'Overview of your company',
      trailing: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primaryLight.withOpacity(0.2),
        child: const Icon(Icons.person, color: AppColors.primary, size: 24),
      ),
    );
  }

  Widget _buildStatsCards({
    required int totalEmployees,
    required int presentToday,
    required int pendingLeaves,
    required VoidCallback onPendingLeavesTap,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: StatCard(
            value: '$totalEmployees',
            label: 'Total Employees',
            icon: Icons.people,
            iconColor: AppColors.primary,
            isLarge: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              StatCard(
                value: '$presentToday',
                label: 'Present Today',
                icon: Icons.check_circle,
                iconColor: AppColors.success,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onPendingLeavesTap,
                child: StatCard(
                  value: '$pendingLeaves',
                  label: 'Pending Leaves',
                  icon: Icons.access_time,
                  iconColor: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AdminDashboardController controller,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ActionButton(
                label: 'Add Employee',
                icon: Icons.person_add,
                onPressed: () {
                  Get.toNamed(AppRoutes.addEmployee);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                label: 'Set Office Location',
                icon: Icons.location_on,
                onPressed: () {
                  Get.toNamed(AppRoutes.setLocation);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceTrend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attendance Trend',
              style: AppTextStyles.heading3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.trending_up, color: AppColors.success, size: 20),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
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
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Text(
                          days[value.toInt()],
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
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
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryExpense() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Salary Expense',
          style: AppTextStyles.heading3.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(16),
            // border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: 64,
                        color: AppColors.primary,
                        title: '',
                      ),
                      PieChartSectionData(
                        value: 36,
                        color: Colors.purple,
                        title: '',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Dev', '\$45k', AppColors.primary),
                    const SizedBox(height: 12),
                    _buildLegendItem('Design', '\$25k', Colors.purple),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
