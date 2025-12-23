import 'package:emp_management/admin/all_emp/controller/employee_controller.dart';
import 'package:emp_management/admin/widgets/employee_card.dart';
import 'package:emp_management/admin/widgets/search_bar.dart';
import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({Key? key}) : super(key: key);

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final EmployeeListController controller = Get.find<EmployeeListController>();
  final TextEditingController _searchController = TextEditingController();

  List filteredList = [];
  String _selectedFilter = 'All';

  final List<String> _filters = const [
    'All',
    'Active',
    'On Leave',
    'Remote',
    'Deactivated',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterEmployees);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterEmployees);
    _searchController.dispose();
    super.dispose();
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredList = controller.employees.where((e) {
        final matchesSearch = e.name.toLowerCase().contains(query) ||
            (e.jobRole?.toLowerCase() ?? '').contains(query) ||
            (e.department?.toLowerCase() ?? '').contains(query);

        if (!matchesSearch) return false;

        if (_selectedFilter == 'All') return true;
        final status = e.role.toLowerCase();
        switch (_selectedFilter) {
          case 'Active':
            return status == 'active';
          case 'On Leave':
            return status == 'on_leave' || status == 'on leave';
          case 'Remote':
            return status == 'remote';
          case 'Deactivated':
            return status == 'deactivated' || status == 'inactive';
        }
        return true;
      }).toList();
    });
  }

  Future<void> _handleRefresh() async {
    await controller.loadEmployees(showLoader: false);
    _filterEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employees',
                        style: AppTextStyles.heading3.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.employees.length} people',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // keep for future filter sheet
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomSearchBar(
                hintText: 'Search by name or ID...',
                controller: _searchController,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      _filterEmployees();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final baseList = _searchController.text.isEmpty &&
                        _selectedFilter == 'All'
                    ? controller.employees
                    : (filteredList.isEmpty &&
                            _searchController.text.isEmpty &&
                            _selectedFilter != 'All'
                        ? controller.employees
                        : filteredList);

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: baseList.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Center(
                                child: Text(
                                  'No employees found',
                                  style:
                                      AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          itemCount: baseList.length,
                          itemBuilder: (context, index) {
                            final employee = baseList[index];

                            return EmployeeCard(
                              name: employee.name,
                              role: employee.jobRole ?? 'Job',
                              employeeId: employee.empId,
                              department: employee.department ?? '',
                              status: employee.role,
                              onPhonePressed: () {},
                              onEmailPressed: () {},
                              onMorePressed: () {},
                            );
                          },
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
