import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:emp_management/core/widgets/section_card.dart';
import 'package:emp_management/employee/profile/model/employee_profile_model.dart';
import 'package:flutter/material.dart';

class ProfileSummaryCard extends StatelessWidget {
  final EmployeeProfileModel profile;
  final VoidCallback? onChangePhoto;

  const ProfileSummaryCard({
    super.key,
    required this.profile,
    this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 52,
                backgroundImage:
                    profile.profilePhoto != null ? NetworkImage(profile.profilePhoto!) : null,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: profile.profilePhoto == null
                    ? const Icon(Icons.person, size: 56)
                    : null,
              ),
              GestureDetector(
                onTap: onChangePhoto,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "${profile.jobRole ?? 'Designation'} · ${profile.dept ?? 'Team'}",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}


