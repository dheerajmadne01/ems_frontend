import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:emp_management/employee/leave/controller/all_leaves_controller.dart';
import 'package:emp_management/employee/leave/model/leave_models.dart';
import 'package:emp_management/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AllLeavesScreen extends StatefulWidget {
  const AllLeavesScreen({Key? key}) : super(key: key);

  @override
  State<AllLeavesScreen> createState() => _AllLeavesScreenState();
}

class _AllLeavesScreenState extends State<AllLeavesScreen> {
  late final AllLeavesController controller;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    controller = Get.find<AllLeavesController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Get.toNamed(AppRoutes.employeeLeave),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final leaves = controller.leaves;
          final pendingDays = _sumDays(leaves, status: 'pending');
          final approvedDays = _sumDays(leaves, status: 'approved');
          final allDays = _sumDays(leaves);

          final filteredLeaves = _filterLeaves(leaves, _selectedFilter);


          return Column(
            children: [
              Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: _buildTopBar(),
        ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => controller.loadLeaves(showLoader: false),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 10),
                      _buildSummaryCards(
                        balanceDays: allDays,
                        pendingDays: pendingDays,
                        approvedDays: approvedDays,
                      ),
                      const SizedBox(height: 16),
                      _buildFilters(),
                      const SizedBox(height: 16),
                      Text(
                        'Recent Requests',
                        style: AppTextStyles.heading3.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (filteredLeaves.isEmpty)
                        _buildEmptyState()
                      else
                        ...filteredLeaves.map((leave) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildLeaveCard(leave),
                            )),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ------------------ UI BUILDERS ------------------
  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        const SizedBox(width: 4),
        Text(
          'Leave History',
          style: AppTextStyles.heading2.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // const Spacer(),
        // Container(
        //   padding: const EdgeInsets.all(8),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(12),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withOpacity(0.05),
        //         blurRadius: 8,
        //         offset: const Offset(0, 2),
        //       ),
        //     ],
        //   ),
        //   child: const Icon(Icons.tune, color: AppColors.textSecondary, size: 20),
        // ),
      ],
    );
  }

  Widget _buildSummaryCards({
    required double balanceDays,
    required double pendingDays,
    required double approvedDays,
  }) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            label: 'Balance',
            value: _formatDays(balanceDays),
            color: AppColors.primary,
            background: AppColors.primary.withOpacity(0.1),
            icon: Icons.folder_copy_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            label: 'Pending',
            value: _formatDays(pendingDays),
            color: Colors.orange,
            background: Colors.orange.withOpacity(0.1),
            icon: Icons.pending_actions_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            label: 'Approved',
            value: _formatDays(approvedDays),
            color: Colors.green,
            background: Colors.green.withOpacity(0.1),
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required Color color,
    required Color background,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Pending', 'Approved', 'Rejected'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in filters) _filterChip(f),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedFilter = label;
          });
        },
        selectedColor: AppColors.primary.withOpacity(0.12),
        backgroundColor: Colors.white,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveCard(LeaveStatusModel leave) {
    final status = leave.status.toLowerCase();
    Color statusColor;
    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    final dateRange =
        '${DateFormat('MMM dd, yyyy').format(leave.startDate)} - ${DateFormat('MMM dd, yyyy').format(leave.endDate)}';
    final days = leave.days ??
        leave.endDate.difference(leave.startDate).inDays.toDouble() + 1;

    IconData leadingIcon;
    Color iconColor;
    if (leave.leaveType.toLowerCase().contains('sick')) {
      leadingIcon = Icons.vaccines_outlined;
      iconColor = Colors.redAccent;
    } else if (leave.leaveType.toLowerCase().contains('vacation') ||
        leave.leaveType.toLowerCase().contains('casual')) {
      leadingIcon = Icons.flight_takeoff;
      iconColor = Colors.blueAccent;
    } else {
      leadingIcon = Icons.event_note_outlined;
      iconColor = AppColors.primary;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(leadingIcon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.leaveType,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leave.reason?.isNotEmpty == true
                          ? leave.reason!
                          : 'No reason provided',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  leave.status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                dateRange,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '• ${days.toStringAsFixed(days.truncateToDouble() == days ? 0 : 1)} Days',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No leave requests',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ HELPERS ------------------
  List<LeaveStatusModel> _filterLeaves(
      List<LeaveStatusModel> leaves, String filter) {
    switch (filter) {
      case 'Pending':
        return leaves.where((l) => l.status.toLowerCase() == 'pending').toList();
      case 'Approved':
        return leaves.where((l) => l.status.toLowerCase() == 'approved').toList();
      case 'Rejected':
        return leaves.where((l) => l.status.toLowerCase() == 'rejected').toList();
      default:
        return leaves;
    }
  }

  double _sumDays(List<LeaveStatusModel> leaves, {String? status}) {
    final filtered = status == null
        ? leaves
        : leaves.where((l) => l.status.toLowerCase() == status).toList();
    return filtered.fold<double>(
        0,
        (prev, l) =>
            prev +
            (l.days ??
                l.endDate.difference(l.startDate).inDays.toDouble() + 1));
  }

  String _formatDays(double days) {
    final display = days.truncateToDouble() == days
        ? days.toStringAsFixed(0)
        : days.toStringAsFixed(1);
    return '$display Days';
  }
}
