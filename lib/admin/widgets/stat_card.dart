import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/layout/responsive.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isLarge;
  final Color? backgroundColor;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final bool showAlert;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.isLarge = false,
    this.backgroundColor,
    this.badge,
    this.badgeColor,
    this.badgeTextColor,
    this.showAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? (isLarge ? AppColors.primary : Colors.white);
    final textColor = isLarge ? Colors.white : AppColors.textPrimary;
    final labelColor = isLarge ? Colors.white70 : AppColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final valueSize = Responsive.sizeByWidth(
          context,
          base: isLarge ? 30 : 22,
          min: 18,
          max: 34,
        );
        final labelSize = Responsive.sizeByWidth(
          context,
          base: 12,
          min: 11,
          max: 14,
        );
        final iconSize = Responsive.sizeByWidth(
          context,
          base: isLarge ? 26 : 22,
          min: 18,
          max: 30,
        );

        return Container(
          padding: EdgeInsets.all(isLarge ? 20 : 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLarge ? Colors.white.withOpacity(0.14) : iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isLarge ? Colors.white : iconColor,
                      size: iconSize,
                    ),
                  ),
                  const Spacer(),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor ?? iconColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontSize: Responsive.sizeByWidth(context, base: 12, min: 10, max: 14),
                          fontWeight: FontWeight.w700,
                          color: badgeTextColor ?? (isLarge ? Colors.white : AppColors.textPrimary),
                        ),
                      ),
                    ),
                  if (showAlert)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: labelSize,
                  color: labelColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

