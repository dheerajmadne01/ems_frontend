import 'package:emp_management/admin/widgets/logout_button.dart';
import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:emp_management/employee/profile/controller/employee_profile_controller.dart';
import 'package:emp_management/employee/profile/model/employee_profile_model.dart';
import 'package:emp_management/employee/profile/repo/employee_profile_repo.dart';
import 'package:emp_management/services/api_service/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  bool _notificationsEnabled = false;

  late final EmployeeProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<EmployeeProfileController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              await controller.fetchProfile();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileHeader(profile),
                  const SizedBox(height: 32),
                  _buildInfoCards(profile),
                  const SizedBox(height: 32),
                  _buildContactInfo(profile),
                  const SizedBox(height: 32),
                  _buildSettings(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // 🔹 HEADER
  Widget _buildProfileHeader(EmployeeProfileModel profile) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: profile.profilePhoto != null
              ? NetworkImage(profile.profilePhoto!)
              : null,
          child: profile.profilePhoto == null
              ? const Icon(Icons.person, size: 60, color: AppColors.primary)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: AppTextStyles.heading2.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          profile.jobRole ?? '-',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'EMP ID: ${profile.empId}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(EmployeeProfileModel profile) {
    return Row(
      children: [
        Expanded(child: _buildInfoCard('Role', profile.jobRole ?? '-')),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoCard('Dept', profile.dept ?? '-')),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoCard('Status', 'Active')),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(EmployeeProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTACT INFO',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          Icons.email,
          'Email',
          profile.email,
          AppColors.primary,
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          Icons.phone,
          'Phone',
          profile.phoneNumber ?? '-',
          Colors.lightBlue,
        ),
      ],
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //  SETTINGS
  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SETTINGS',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingItem(
          Icons.notifications,
          'Notifications',
          Colors.purple,
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingItem(
          Icons.lock,
          'Change Password',
          Colors.green,
          const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Change Password coming soon')),
            );
          },
        ),
        const SizedBox(height: 16),
        LogoutButton(onPressed: () => Get.offAllNamed('/login')),
      ],
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String label,
    Color iconColor,
    Widget trailing, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
