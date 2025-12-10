import 'package:emp_management/admin/leaves/controller/leave_requests_controller.dart';
import 'package:emp_management/admin/leaves/model/leave_request_model.dart';
import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveRequestsScreen extends StatelessWidget {
  const LeaveRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeaveRequestsController>();
    final dateFormat = DateFormat('MMM dd');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.back(),
                    ),                  
                    SizedBox(width: 50),
                    Text(
                      'Leave Requests',
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
 
                    // IconButton(
                    //   icon: const Icon(Icons.refresh),
                    //   onPressed: controller.loadLeaves,
                    // ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  // indicator: BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(16),
                  // ),
                  labelColor: AppColors.primary,
                  // unselectedLabelColor: AppColors.textSecondary,
                  tabs: [
                    Obx(
                      () => Tab(
                        child: Text(
                          'Pending (${controller.pendingLeaves.length})',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => Tab(
                        child: Text(
                          'History (${controller.historyLeaves.length})',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return TabBarView(
                    children: [
                      _LeaveList(
                        items: controller.pendingLeaves,
                        dateFormat: dateFormat,
                        showActions: true,
                        onApprove: (leave) =>
                            controller.decideLeave(leave, 'approve'),
                        onReject: (leave) =>
                            controller.decideLeave(leave, 'reject'),
                      ),
                      _LeaveList(
                        items: controller.historyLeaves,
                        dateFormat: dateFormat,
                        showActions: false,
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaveList extends StatelessWidget {
  const _LeaveList({
    required this.items,
    required this.dateFormat,
    required this.showActions,
    this.onApprove,
    this.onReject,
  });

  final List<LeaveRequestModel> items;
  final DateFormat dateFormat;
  final bool showActions;
  final ValueChanged<LeaveRequestModel>? onApprove;
  final ValueChanged<LeaveRequestModel>? onReject;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          showActions
              ? 'No pending leave requests'
              : 'No leave history available',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemBuilder: (_, index) {
        final leave = items[index];
        return _LeaveCard(
          leave: leave,
          dateFormat: dateFormat,
          showActions: showActions,
          onApprove: onApprove,
          onReject: onReject,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: items.length,
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({
    required this.leave,
    required this.dateFormat,
    required this.showActions,
    this.onApprove,
    this.onReject,
  });

  final LeaveRequestModel leave;
  final DateFormat dateFormat;
  final bool showActions;
  final ValueChanged<LeaveRequestModel>? onApprove;
  final ValueChanged<LeaveRequestModel>? onReject;

  @override
  Widget build(BuildContext context) {
    final avatarInitial =
        leave.employeeName.isNotEmpty ? leave.employeeName[0] : '?';
    final period =
        '${dateFormat.format(leave.startDate)} - ${dateFormat.format(leave.endDate)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: (leave.profilePhoto?.isNotEmpty ?? false)
                    ? NetworkImage(leave.profilePhoto!)
                    : null,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: (leave.profilePhoto?.isNotEmpty ?? false)
                    ? null
                    : Text(
                        avatarInitial,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
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
                      leave.leaveType,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  leave.durationLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      period,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (leave.reason != null && leave.reason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '"${leave.reason!}"',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!showActions) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _StatusChip(status: leave.status),
              ],
            ),
          ],
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject == null
                        ? null
                        : () => onReject!(leave),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove == null
                        ? null
                        : () => onApprove!(leave),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Approve'),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    switch (status.toLowerCase()) {
      case 'approved':
        bg = Colors.green.withOpacity(0.1);
        text = Colors.green;
        break;
      case 'rejected':
        bg = Colors.red.withOpacity(0.1);
        text = Colors.red;
        break;
      default:
        bg = AppColors.primary.withOpacity(0.1);
        text = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

