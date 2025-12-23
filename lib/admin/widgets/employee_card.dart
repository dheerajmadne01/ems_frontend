import 'package:emp_management/admin/widgets/status_badge.dart';
import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:flutter/material.dart';


class EmployeeCard extends StatelessWidget {
  final String name;
  final String role;
  final String employeeId;
  final String department;
  final String status;
  final VoidCallback? onPhonePressed;
  final VoidCallback? onEmailPressed;
  final VoidCallback? onMorePressed;

  const EmployeeCard({
    Key? key,
    required this.name,
    required this.role,
    required this.employeeId,
    required this.department,
    required this.status,
    this.onPhonePressed,
    this.onEmailPressed,
    this.onMorePressed,
  }) : super(key: key);

  Color _statusColor(String status) {
    final value = status.toLowerCase();
    if (value.contains('active')) return AppColors.success;
    if (value.contains('leave')) return AppColors.warning;
    if (value.contains('deact') || value.contains('inactive')) {
      return AppColors.textSecondary.withOpacity(0.8);
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withOpacity(0.08),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onMorePressed,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#$employeeId',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(
            status: status,
            statusColor: statusColor,
          ),
        ],
      ),
    );
  }
}

