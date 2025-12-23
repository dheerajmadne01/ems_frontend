import 'package:emp_management/admin/attendence/controller/attendance_controller.dart';
import 'package:emp_management/admin/attendence/model/attendance_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:emp_management/core/text_styles.dart';
import 'package:emp_management/core/app_colors.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late AttendanceController controller;
  String _selectedDept = 'All';

  @override
  void initState() {
    super.initState();
    controller = Get.find<AttendanceController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final isInitialLoading =
              controller.isLoading.value && controller.employees.isEmpty;

          if (isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = controller.employees;

          // Build distinct department filters (excluding null / empty)
          final departments = <String>{
            for (final e in list)
              if ((e.dept ?? '').trim().isNotEmpty) (e.dept ?? '').trim(),
          }.toList()
            ..sort();

          // Attendance summary for header cards
          int presentCount = 0;
          int absentCount = 0;
          for (final e in list) {
            final st = controller.computeTodayStatus(e);
            if (st.status == 'Present') {
              presentCount++;
            } else if (st.status == 'Absent') {
              absentCount++;
            }
          }

          final totalCount = list.length;

          // Apply department filter to list
          final filteredEmployees = _selectedDept == 'All'
              ? list
              : list.where((e) => (e.dept ?? '').trim() == _selectedDept).toList();

          return RefreshIndicator(
            onRefresh: () async => controller.loadAttendance(showLoader: false),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 16),

                // Top bar (title + actions)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Attendance',
                        style: AppTextStyles.heading2
                            .copyWith(color: AppColors.primary),
                      ),
                      // const Spacer(),
                      // Container(
                      //   padding: const EdgeInsets.all(8),
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey.shade100,
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: const Icon(Icons.search,
                      //       color: AppColors.textSecondary, size: 20),
                      // ),
                      // const SizedBox(width: 8),
                      // Container(
                      //   padding: const EdgeInsets.all(8),
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey.shade100,
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: const Icon(Icons.calendar_today_outlined,
                      //       color: AppColors.textSecondary, size: 20),
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Date selector style card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GestureDetector(
                    onTap: () async {
                      final initialDate = controller.selectedDate.value;
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: DateTime(2020, 1, 1),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        await controller.loadAttendance(date: picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.calendar_today_outlined,
                                size: 18, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEE, dd MMM yyyy')
                                .format(controller.selectedDate.value),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Summary cards row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          label: 'Total',
                          value: totalCount.toString(),
                          color: AppColors.primary,
                          background: AppColors.primary.withOpacity(0.06),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _summaryCard(
                          label: 'Present',
                          value: presentCount.toString(),
                          color: Colors.green,
                          background: Colors.green.withOpacity(0.06),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _summaryCard(
                          label: 'Absent',
                          value: absentCount.toString(),
                          color: Colors.red,
                          background: Colors.red.withOpacity(0.06),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Department filter chips
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _deptChip('All'),
                        for (final d in departments) _deptChip(d),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Employee cards list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      for (final emp in filteredEmployees)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _employeeCard(emp),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// ---------------- LIST HEADER ----------------
  Widget _summaryCard({
    required String label,
    required String value,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.check_circle, color: color, size: 18),
              const SizedBox(width: 4),
              Text(
                value,
                style: AppTextStyles.heading3.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deptChip(String label) {
    final bool isSelected = _selectedDept == label;
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedDept = label;
          });
        },
        selectedColor: AppColors.primary.withOpacity(0.12),
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _employeeCard(EmployeeModel emp) {
    final st = controller.computeTodayStatus(emp);

    Color statusColor;
    if (st.status == 'Present') {
      statusColor = Colors.green;
    } else if (st.status == 'On Leave') {
      statusColor = Colors.blue;
    } else {
      statusColor = Colors.red;
    }

    final punchInText = st.punchIn != null && st.punchIn!.punchInTime != null
        ? controller.formatTime(st.punchIn!.punchInTime!)
        : '--';

    final punchOutText =
        st.punchOut != null && st.punchOut!.punchOutTime != null
            ? controller.formatTime(st.punchOut!.punchOutTime!)
            : '--';

    String totalDurationText = '--';
    if (st.punchIn?.punchInTime != null &&
        st.punchOut?.punchOutTime != null) {
      final diff =
          st.punchOut!.punchOutTime!.difference(st.punchIn!.punchInTime!);
      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      if (hours > 0 || minutes > 0) {
        totalDurationText =
            '${hours}h ${minutes.toString().padLeft(2, '0')}m';
      }
    }

    return InkWell(
      onTap: () => _showEmployeeDetails(emp, st),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: emp.profilePhoto != null
                      ? NetworkImage(emp.profilePhoto!)
                      : null,
                  backgroundColor: Colors.grey.shade300,
                  child: emp.profilePhoto == null
                      ? Text(
                          emp.name.isNotEmpty ? emp.name[0] : '?',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emp.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emp.jobRole ?? emp.dept ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    st.status,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeColumn('Punch In', punchInText),
                _timeColumn('Punch Out', punchOutText),
                _timeColumn('Total', totalDurationText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// ---------------- BOTTOM SHEET ----------------
  void _showEmployeeDetails(EmployeeModel emp, dynamic st) {
    final status = st as dynamic;

    final Map<String, List<PunchModel>> punchesByDate = {};
    for (var punch in emp.punches) {
      final dateTime =
          punch.punchInTime ?? punch.punchOutTime;
      if (dateTime != null) {
        final dateKey =
            DateFormat('yyyy-MM-dd').format(dateTime);
        punchesByDate.putIfAbsent(
            dateKey, () => []);
        punchesByDate[dateKey]!.add(punch);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        emp.profilePhoto != null
                            ? NetworkImage(
                                emp.profilePhoto!)
                            : null,
                    child: emp.profilePhoto == null
                        ? Text(emp.name[0])
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(emp.name,
                      style:
                          AppTextStyles.heading3),
                ],
              ),

              const SizedBox(height: 16),

              ListTile(
                title: const Text('Status'),
                trailing: Text(status.status),
              ),

              const SizedBox(height: 10),

              const Text('Punch Details',
                  style: AppTextStyles.heading3),

              const SizedBox(height: 10),

              if (status.punchIn != null)
                _buildDetailedPunchItem(
                    'Punch In',
                    status.punchIn!),

              if (status.punchOut != null)
                _buildDetailedPunchItem(
                    'Punch Out',
                    status.punchOut!),

              const SizedBox(height: 20),

              for (var entry in punchesByDate
                  .entries)
                _buildDatePunchSection(
                    entry.key, entry.value),

              const SizedBox(height: 12),

              Center(
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailedPunchItem(
      String label, PunchModel punch) {
    final time =
        punch.punchInTime ?? punch.punchOutTime;

    final timeString = time != null
        ? DateFormat('hh:mm a').format(time)
        : '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: punch.type
                          .toUpperCase() ==
                      'IN'
                  ? Colors.green
                  : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$label : $timeString',
            style: AppTextStyles.bodyMedium
                .copyWith(
                    fontWeight:
                        FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget _buildDatePunchSection(
      String date,
      List<PunchModel> punches) {

    punches.sort((a, b) {
      final timeA =
          a.punchInTime ??
              a.punchOutTime;
      final timeB =
          b.punchInTime ??
              b.punchOutTime;
      if (timeA == null)
        return 1;
      if (timeB == null)
        return -1;
      return timeA.compareTo(timeB);
    });

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat(
                      'MMM dd, yyyy')
                  .format(DateTime.parse(
                      date)),
              style: AppTextStyles
                  .bodyMedium
                  .copyWith(
                      fontWeight:
                          FontWeight.bold),
            ),
            const SizedBox(
                height: 8),
            for (var punch
                in punches)
              _buildPunchItem(
                  punch),
          ],
        ),
      ),
    );
  }

  Widget _buildPunchItem(
      PunchModel punch) {
    final time =
        punch.punchInTime ??
            punch.punchOutTime;

    final timeString = time != null
        ? DateFormat('hh:mm a')
            .format(time)
        : '-';

    final type = punch.type
        .toUpperCase();

    final color = type == 'IN'
        ? Colors.green
        : Colors.red;

    return Padding(
      padding: const EdgeInsets
          .symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape:
                  BoxShape.circle,
            ),
          ),
          const SizedBox(
              width: 8),
          Text(
            '$type - $timeString',
            style: AppTextStyles
                .bodyMedium,
          ),
        ],
      ),
    );
  }
}
