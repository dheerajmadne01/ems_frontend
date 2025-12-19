import 'package:emp_management/admin/all_emp/controller/employee_controller.dart';
import 'package:emp_management/admin/widgets/employee_card.dart';
import 'package:emp_management/admin/widgets/screen_header.dart';
import 'package:emp_management/admin/widgets/search_bar.dart';
import 'package:emp_management/core/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterEmployees);
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredList = controller.employees.where((e) {
        return e.name.toLowerCase().contains(query) ||
            (e.jobRole?.toLowerCase() ?? '').contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ScreenHeader(
                title: 'Employees',
                trailing: IconButton(
                  icon: const Icon(
                      Icons.filter_list,
                      color: AppColors.textSecondary
                  ),
                  onPressed: () {},
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomSearchBar(
                hintText: 'Search employees...',
                controller: _searchController,
              ),
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = _searchController.text.isEmpty
                    ? controller.employees
                    : filteredList;

                if (list.isEmpty) {
                  return const Center(child: Text("No Employees Found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final employee = list[index];

                    return EmployeeCard(
                      name: employee.name,
                      role:
                          "${employee.jobRole ?? 'Job'} • ${employee.department ?? 'Dept'}",
                      status: employee.role,
                      statusColor: Colors.green,
                      onPhonePressed: () {},
                      onEmailPressed: () {},
                      onMorePressed: () {},
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/admin/add-employee');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
