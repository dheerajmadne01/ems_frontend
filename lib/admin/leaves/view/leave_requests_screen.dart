import 'package:emp_management/admin/leaves/controller/leave_requests_controller.dart';
import 'package:emp_management/admin/leaves/model/leave_request_model.dart';
import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({Key? key}) : super(key: key);

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  String _selectedFilter = 'All Requests';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeaveRequestsController>();
    final dateFormat = DateFormat('MMM dd');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // Calculate summary counts
          final allLeaves = [
            ...controller.pendingLeaves,
            ...controller.historyLeaves,
          ];
          final pendingCount = controller.pendingLeaves.length;
          final approvedCount = allLeaves
              .where((l) => l.status.toLowerCase() == 'approved')
              .length;
          final rejectedCount = allLeaves
              .where((l) => l.status.toLowerCase() == 'rejected')
              .length;

          // Filter leaves based on selected filter
          List<LeaveRequestModel> filteredLeaves;
          switch (_selectedFilter) {
            case 'Pending':
              filteredLeaves = controller.pendingLeaves;
              break;
            case 'Approved':
              filteredLeaves = allLeaves
                  .where((l) => l.status.toLowerCase() == 'approved')
                  .toList();
              break;
            case 'Rejected':
              filteredLeaves = allLeaves
                  .where((l) => l.status.toLowerCase() == 'rejected')
                  .toList();
              break;
            default:
              filteredLeaves = allLeaves;
          }

          return RefreshIndicator(
            onRefresh: () async => controller.loadLeaves(showLoader: false),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 16),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Leave Requests',
                        style: AppTextStyles.heading2
                            .copyWith(color: AppColors.primary),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.search,
                            color: AppColors.textSecondary, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.filter_list,
                            color: AppColors.textSecondary, size: 20),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Summary Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          label: 'Pending',
                          value: pendingCount.toString(),
                          color: Colors.orange,
                          background: Colors.orange.withOpacity(0.1),
                          icon: Icons.folder_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _summaryCard(
                          label: 'Approved',
                          value: approvedCount.toString(),
                          color: Colors.green,
                          background: Colors.green.withOpacity(0.1),
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _summaryCard(
                          label: 'Rejected',
                          value: rejectedCount.toString(),
                          color: Colors.red,
                          background: Colors.red.withOpacity(0.1),
                          icon: Icons.cancel_outlined,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Filter Tabs
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _filterChip('All Requests'),
                        _filterChip('Pending'),
                        _filterChip('Approved'),
                        _filterChip('Rejected'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Leave Requests List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      if (filteredLeaves.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            'No leave requests found',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      else
                        for (final leave in filteredLeaves)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _leaveRequestCard(
                              leave: leave,
                              dateFormat: dateFormat,
                              onApprove: leave.isPending
                                  ? () => controller.decideLeave(leave, 'approve')
                                  : null,
                              onReject: leave.isPending
                                  ? () => controller.decideLeave(leave, 'reject')
                                  : null,
                            ),
                          ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add leave request screen
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 24,
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

  Widget _filterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedFilter = label;
          });
        },
        selectedColor: AppColors.primary.withOpacity(0.12),
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _leaveRequestCard({
    required LeaveRequestModel leave,
    required DateFormat dateFormat,
    VoidCallback? onApprove,
    VoidCallback? onReject,
  }) {
    final avatarInitial =
        leave.employeeName.isNotEmpty ? leave.employeeName[0] : '?';
    final isPending = leave.isPending;
    final isApproved = leave.status.toLowerCase() == 'approved';

    // Format date range
    String dateRange;
    if (leave.startDate.year == leave.endDate.year &&
        leave.startDate.month == leave.endDate.month &&
        leave.startDate.day == leave.endDate.day) {
      dateRange = '${dateFormat.format(leave.startDate)} (1 Day)';
    } else {
      final days = (leave.days ?? leave.endDate.difference(leave.startDate).inDays + 1).toInt();
      dateRange = '${dateFormat.format(leave.startDate)} - ${dateFormat.format(leave.endDate)} ($days Days)';
    }

    Color statusColor;
    if (isPending) {
      statusColor = Colors.orange;
    } else if (isApproved) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: (leave.profilePhoto?.isNotEmpty ?? false)
                        ? NetworkImage(leave.profilePhoto!)
                        : null,
                    backgroundColor: Colors.grey.shade300,
                    child: (leave.profilePhoto?.isNotEmpty ?? false)
                        ? null
                        : Text(
                            avatarInitial,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.employeeName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leave.employeeRole,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  leave.status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            leave.leaveType,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                dateRange,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (leave.reason != null && leave.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              leave.reason!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (isPending && onApprove != null && onReject != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 18),
                        SizedBox(width: 4),
                        Text('Reject'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 18, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Approve', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
