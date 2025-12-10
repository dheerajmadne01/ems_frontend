import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:flutter/material.dart';


class PayslipItem extends StatefulWidget {
  final String month;
  final String date;
  final String amount;
  final VoidCallback? onDownload;

  const PayslipItem({
    Key? key,
    required this.month,
    required this.date,
    required this.amount,
    this.onDownload,
  }) : super(key: key);

  @override
  State<PayslipItem> createState() => _PayslipItemState();
}

class _PayslipItemState extends State<PayslipItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.attach_money,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.month,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.date,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            widget.amount,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: widget.onDownload,
            icon: const Icon(
              Icons.download,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

