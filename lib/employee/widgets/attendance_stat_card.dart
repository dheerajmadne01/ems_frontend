import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:flutter/material.dart';

class AttendanceStatCard extends StatefulWidget {
  final double percentage;
  final String label;
  final Color? color;

  const AttendanceStatCard({
    Key? key,
    required this.percentage,
    required this.label,
    this.color,
  }) : super(key: key);

  @override
  State<AttendanceStatCard> createState() => _AttendanceStatCardState();
}

class _AttendanceStatCardState extends State<AttendanceStatCard> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 0, maxWidth: double.infinity),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final double maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : 100;
          final double circleSize = (maxW * 0.6).clamp(40.0, 70.0);
          final double fontSize = (circleSize * 0.25).clamp(12.0, 18.0);

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: circleSize,
                height: circleSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: circleSize,
                      height: circleSize,
                      child: CircularProgressIndicator(
                        value: widget.percentage / 100,
                        strokeWidth: (circleSize * 0.12).clamp(4.0, 8.0),
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.color ?? AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.percentage.toInt()}%',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  widget.label,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

