import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:emp_management/core/widgets/info_tile.dart';
import 'package:emp_management/employee/profile/controller/employee_profile_controller.dart';
import 'package:emp_management/employee/profile/widgets/profile_header.dart';
import 'package:emp_management/employee/profile/widgets/profile_section.dart';
import 'package:emp_management/employee/profile/widgets/profile_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  late final EmployeeProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<EmployeeProfileController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.isNotEmpty) {
            return Center(child: Text(controller.error.value));
          }

          final profile = controller.profile.value;
          if (profile == null) {
            return const Center(child: Text('No profile data'));
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await controller.fetchProfile(showLoader: false);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                ProfileHeader(
                  onEdit: () => Get.snackbar('Info', 'Edit coming soon'),
                ),
                const SizedBox(height: 20),
                ProfileSummaryCard(
                  profile: profile,
                  onChangePhoto: () => Get.snackbar(
                    'Info',
                    'Profile photo update coming soon',
                  ),
                ),
                const SizedBox(height: 20),
                ProfileSection(
                  title: 'Contact Information',
                  children: [
                    InfoTile(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: profile.email,
                      trailing: const Icon(
                        Icons.copy,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    InfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: profile.phoneNumber ?? '-',
                      trailing: const Icon(
                        Icons.phone_in_talk,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    InfoTile(
                      icon: Icons.business_center_outlined,
                      label: 'Department',
                      value: profile.dept ?? '-',
                      trailing: const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ProfileSection(
                  title: 'Employment Details',
                  children: [
                    InfoTile(
                      icon: Icons.badge_outlined,
                      label: 'Employee ID',
                      value: profile.empId,
                      iconBackground: AppColors.primary.withOpacity(0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ProfileLogoutButton(
                  onPressed: () => Get.offAllNamed('/login'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

}

class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ProfileLogoutButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: AppTextStyles.heading3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
