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
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = controller.employees;

          return RefreshIndicator(
            onRefresh: () async => controller.loadAttendance(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(
                        'Attendance',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.filter_list,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Today — ${DateTime.now().toLocal().toString().split(' ')[0]}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _buildListHeader(),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final emp = list[index];
                      final st = controller.computeTodayStatus(emp);

                      Color statusColor;
                      if (st.status == 'Present') {
                        statusColor = Colors.green;
                      } else if (st.status == 'On Leave') {
                        statusColor = Colors.blue;
                      } else {
                        statusColor = Colors.red;
                      }

                      final punchInText = st.punchIn != null
                          ? controller
                              .formatTime(st.punchIn!.punchInTime!)
                          : '-';

                      final punchOutText = st.punchOut != null
                          ? controller
                              .formatTime(st.punchOut!.punchOutTime!)
                          : '-';

                      return InkWell(
                        onTap: () =>
                            _showEmployeeDetails(emp, st),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              /// ---------------- EMPLOYEE ----------------
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          emp.profilePhoto != null
                                              ? NetworkImage(
                                                  emp.profilePhoto!)
                                              : null,
                                      backgroundColor:
                                          Colors.grey.shade300,
                                      child: emp.profilePhoto ==
                                              null
                                          ? Text(
                                              emp.name.isNotEmpty
                                                  ? emp.name[0]
                                                  : '?',
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          emp.name,
                                          style: AppTextStyles
                                              .bodyMedium
                                              .copyWith(
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          emp.dept ??
                                              emp.jobRole ??
                                              '',
                                          style: AppTextStyles
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              /// ---------------- STATUS ----------------
                              Expanded(
                                child: Center(
                                  child: Text(
                                    st.status,
                                    style: AppTextStyles
                                        .bodyMedium
                                        .copyWith(
                                      color: statusColor,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              /// ---------------- TIMES ----------------
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'In: $punchInText',
                                      style: AppTextStyles
                                          .bodySmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Out: $punchOutText',
                                      style: AppTextStyles
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// ---------------- LIST HEADER ----------------
  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Employee',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Status',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Times',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
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
