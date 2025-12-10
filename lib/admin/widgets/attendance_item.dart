import 'package:emp_management/admin/widgets/status_badge.dart';
import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:flutter/material.dart';


class AttendanceItem extends StatelessWidget {
  final String name;
  final String status;
  final Color statusColor;
  final String checkIn;

  const AttendanceItem({
    Key? key,
    required this.name,
    required this.status,
    required this.statusColor,
    required this.checkIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLight.withOpacity(0.2),
            child: const Icon(Icons.person, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: StatusBadge(
                status: status,
                statusColor: statusColor,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                checkIn,
                style: AppTextStyles.bodySmall.copyWith(
                  color: checkIn == '-' ? AppColors.textHint : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

