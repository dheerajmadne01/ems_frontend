import 'package:emp_management/admin/widgets/status_badge.dart';
import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:flutter/material.dart';


class EmployeeCard extends StatelessWidget {
  final String name;
  final String role;
  final String status;
  final Color statusColor;
  final VoidCallback? onPhonePressed;
  final VoidCallback? onEmailPressed;
  final VoidCallback? onMorePressed;

  const EmployeeCard({
    Key? key,
    required this.name,
    required this.role,
    required this.status,
    required this.statusColor,
    this.onPhonePressed,
    this.onEmailPressed,
    this.onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryLight.withOpacity(0.2),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    StatusBadge(
                      status: status,
                      statusColor: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.phone, size: 18, color: AppColors.textSecondary),
                      onPressed: onPhonePressed,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.email, size: 18, color: AppColors.textSecondary),
                      onPressed: onEmailPressed,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onPressed: onMorePressed,
          ),
        ],
      ),
    );
  }
}

