import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:emp_management/employee/leave/controller/leave_controller.dart';
import 'package:emp_management/employee/widgets/leave_balance_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Leave types used by the leave screen
const List<String> _leaveTypes = <String>[
  'Casual Leave',
  'Sick Leave',
  'Annual Leave',
  'Emergency Leave',
];

class EmployeeLeaveScreen extends StatefulWidget {
  const EmployeeLeaveScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeLeaveScreen> createState() => _EmployeeLeaveScreenState();

}

class _EmployeeLeaveScreenState extends State<EmployeeLeaveScreen> {
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeaveController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apply Leave',
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildLeaveTypeField(controller),
              const SizedBox(height: 20),
              _buildDateFields(controller, context),
              const SizedBox(height: 20),
              _buildReasonField(controller),
              const SizedBox(height: 24),
              _buildLeaveBalanceSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveTypeField(LeaveController controller) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave Type',
            style: AppTextStyles.inputLabel,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedLeaveType.value,
                hint: const Text('Select leave type'),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                items: _leaveTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  controller.selectedLeaveType.value = newValue;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFields(LeaveController controller, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Date',
                style: AppTextStyles.inputLabel,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => controller.pickStartDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Obx(
                        () => Text(
                          controller.startDateLabel ?? 'Pick date',
                          style: TextStyle(
                            color: controller.startDate.value != null
                                ? Colors.black
                                : Colors.grey[500],
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'End Date',
                style: AppTextStyles.inputLabel,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => controller.pickEndDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Obx(
                        () => Text(
                          controller.endDateLabel ?? 'Pick date',
                          style: TextStyle(
                            color: controller.endDate.value != null
                                ? Colors.black
                                : Colors.grey[500],
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField(LeaveController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason For Leave',
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _reasonController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Please describe the reason...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leave Balance',
          style: AppTextStyles.heading3.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LeaveBalanceItem(leaveType: 'Casual Leave', days: '8 Days'),
        LeaveBalanceItem(leaveType: 'Sick Leave', days: '5 Days'),
        LeaveBalanceItem(leaveType: 'Annual Leave', days: '12 Days'),
      ],
    );
  }

  Widget _buildSubmitButton(LeaveController controller) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Obx(
        () => ElevatedButton(
            onPressed: controller.isSubmitting.value
              ? null
              : () => controller.submitLeave(reason: _reasonController.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isSubmitting.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Submit Request',
                  style: AppTextStyles.buttonLarge,
                ),
        ),
      ),
    );
  }
}

