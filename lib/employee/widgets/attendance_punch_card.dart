import 'package:emp_management/core/app_colors.dart';
// removed AppStrings import
import 'package:flutter/material.dart';

class AttendancePunchCard extends StatefulWidget {
  final String currentTime;
  final String currentDate;
  final String location;
  final Future<void> Function()? onPunchIn;
  final bool isPunchedIn;
  final bool isPunching;

  const AttendancePunchCard({
    Key? key,
    required this.currentTime,
    required this.currentDate,
    required this.location,
    this.onPunchIn,
    this.isPunchedIn = true,
    this.isPunching = false,
  }) : super(key: key);

  @override
  State<AttendancePunchCard> createState() => _AttendancePunchCardState();
}

class _AttendancePunchCardState extends State<AttendancePunchCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3089E1), Color(0xFF2E80FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Current Time',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.currentTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.currentDate,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              if (widget.isPunching) return;
              widget.onPunchIn?.call();
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isPunching)
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.fingerprint,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isPunchedIn ? 'Punch Out' : 'Punch In',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white.withOpacity(0.9),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Office Location: ${widget.location}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

