import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:emp_management/employee/leave/controller/all_leaves_controller.dart';
import 'package:emp_management/employee/widgets/leave_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllLeavesScreen extends StatefulWidget {
  const AllLeavesScreen({Key? key}) : super(key: key);

  @override
  State<AllLeavesScreen> createState() => _AllLeavesScreenState();
}

class _AllLeavesScreenState extends State<AllLeavesScreen> {
  late final AllLeavesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AllLeavesController>();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.textPrimary),
              onPressed: () => Get.back(),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'My Leaves',
              style: AppTextStyles.heading2.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Obx(() {
              final pendingCount = controller.leaves  
                  .where((e) => e.status == 'pending')
                  .length;
              final approvedCount = controller.leaves
                  .where((e) => e.status == 'approved')
                  .length;
              final rejectedCount = controller.leaves
                  .where((e) => e.status == 'rejected')
                  .length;

              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                padding: const EdgeInsets.all(4),
                // decoration: BoxDecoration(
                //   color: AppColors.background,
                //   borderRadius: BorderRadius.circular(30),
                // ),
                child: TabBar(
                  // indicator: BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(30),
                  // ),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(text: 'Pending ($pendingCount)'),
                    Tab(text: 'Approved ($approvedCount)'),
                    Tab(text: 'Rejected ($rejectedCount)'),
                  ],
                ),
              );
            }),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final pendingLeaves =
              controller.leaves.where((e) => e.status == 'pending').toList();
          final approvedLeaves =
              controller.leaves.where((e) => e.status == 'approved').toList();
          final rejectedLeaves =
              controller.leaves.where((e) => e.status == 'rejected').toList();

          return TabBarView(
            children: [
              _buildLeavesList(pendingLeaves),
              _buildLeavesList(approvedLeaves),
              _buildLeavesList(rejectedLeaves),
            ],
          );
        }),
      ),
    );
  }

  /// =======================
  /// Leaves List
  /// =======================
  Widget _buildLeavesList(List leaves) {
    if (leaves.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: controller.loadLeaves,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: leaves.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LeaveItem(leave: leaves[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.beach_access,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No leaves found',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
