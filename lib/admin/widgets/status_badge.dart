import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Color statusColor;
  final double? fontSize;

  const StatusBadge({
    Key? key,
    required this.status,
    required this.statusColor,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: fontSize ?? 10,
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

