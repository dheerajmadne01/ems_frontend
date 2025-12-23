import 'package:emp_management/admin/settings/controller/settings_controller.dart';
import 'package:emp_management/admin/widgets/logout_button.dart';
import 'package:emp_management/admin/widgets/profile_card.dart';
import 'package:emp_management/admin/widgets/screen_header.dart';
import 'package:emp_management/admin/widgets/section_title.dart';
import 'package:emp_management/admin/widgets/settings_item.dart';
import 'package:emp_management/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController controller = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<SettingsController>(
        builder: (ctrl) {
          if (ctrl.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenHeader(title: 'Settings'),
                  const SizedBox(height: 24),

                  ProfileCard(
                    name: ctrl.name,
                    email: ctrl.email,
                    onEditPressed: () {},
                  ),

                  const SizedBox(height: 32),
                  const SectionTitle(title: 'GENERAL'),
                  const SizedBox(height: 16),
                  _buildGeneralSection(ctrl),

                  const SizedBox(height: 32),
                  const SectionTitle(title: 'SECURITY'),
                  const SizedBox(height: 16),
                  _buildSecuritySection(),

                  const SizedBox(height: 32),
                  LogoutButton(
                    onPressed: () {
                      Get.toNamed('/login');
                      // final authController = Get.find<AuthController>();
                      // await authController.logout(
                  
                      // );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeneralSection(SettingsController ctrl) {
    return Column(
      children: [
        SettingsItem(
          icon: Icons.person_outline,
          iconColor: AppColors.primary,
          title: 'Account Info',
          onTap: () {},
        ),

        SettingsItem(
          icon: Icons.notifications_outlined,
          iconColor: Colors.purple,
          title: 'Notifications',
          trailing: Switch(
            value: ctrl.notificationsEnabled,
            onChanged: (val) {
              ctrl.notificationsEnabled = val;
              ctrl.update();
            },
            activeColor: AppColors.primary,
          ),
        ),

        SettingsItem(
          icon: Icons.language_outlined,
          iconColor: AppColors.warning,
          title: 'Language',
          trailing: const Text(
            'English',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      children: [
        SettingsItem(
          icon: Icons.lock_outline,
          iconColor: AppColors.success,
          title: 'Change Password',
          onTap: () {},
        ),
        SettingsItem(
          icon: Icons.help_outline,
          iconColor: AppColors.info,
          title: 'Help & Support',
          onTap: () {},
        ),
      ],
    );
  }
}
