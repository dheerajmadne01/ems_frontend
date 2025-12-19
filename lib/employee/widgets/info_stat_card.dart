import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:flutter/material.dart';


class InfoStatCard extends StatefulWidget {
  final String label;
  final Color color;

  const InfoStatCard({
    Key? key,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  State<InfoStatCard> createState() => _InfoStatCardState();
}

class _InfoStatCardState extends State<InfoStatCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

