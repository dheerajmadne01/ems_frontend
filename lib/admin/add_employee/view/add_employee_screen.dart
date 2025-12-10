import 'package:emp_management/admin/add_employee/controller/employee_controller.dart';
import 'package:emp_management/admin/widgets/custom_dropdown.dart';
import 'package:emp_management/admin/widgets/custom_text_field.dart';
import 'package:emp_management/admin/widgets/primary_button.dart';
import 'package:emp_management/admin/widgets/upload_photo_widget.dart';
import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({Key? key}) : super(key: key);

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  // ⛔ No binding – we directly put controller here
  late final EmployeeController controller;

  final List<String> _departments = [
    'Design',
    'Engineering',
    'Product',
    'HR',
    'Marketing',
    'Sales',
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<EmployeeController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add New Employee',
          style: AppTextStyles.heading1.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UploadPhotoWidget(onTap: () {}),
              const SizedBox(height: 32),
              _buildFormFields(),
              const SizedBox(height: 32),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Full Name',
          controller: controller.fullName,
          hintText: 'e.g. Sarah Johnson',
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter full name' : null,
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Employee ID',
                controller: controller.employeeId,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomDropdown<String>(
                label: 'Department',
                value: controller.selectedDepartment,
                items: _departments
                    .map((dep) =>
                        DropdownMenuItem(value: dep, child: Text(dep)))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    controller.selectedDepartment = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select department' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        CustomTextField(
          label: 'Job Role',
          controller: controller.jobRole,
          hintText: 'e.g. Senior Designer',
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter job role' : null,
        ),
        const SizedBox(height: 20),

        CustomTextField(
          label: 'Email Address',
          controller: controller.email,
          hintText: 'name@company.com',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter email';
            if (!value.contains('@')) return 'Invalid email';
            return null;
          },
        ),
        const SizedBox(height: 20),

        CustomTextField(
          label: 'Phone Number',
          controller: controller.phone,
          hintText: '+1 234 567 890',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),

        CustomTextField(
          label: 'Monthly Salary (\$)',
          controller: controller.salary,
          hintText: '5000',
          keyboardType: TextInputType.number,
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter salary' : null,
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return GetBuilder<EmployeeController>(
      builder: (c) {
        return PrimaryButton(
          label: c.isLoading.value
              ? 'Creating...'
              : 'Create Employee Profile',
          onPressed: () => c.createEmployee(formKey: _formKey),
        );
      },
    );
  }
}
