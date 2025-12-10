import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/employee/home/view/employee_home_screen.dart';
import 'package:emp_management/employee/leave/view/employee_leave_screen.dart';
import 'package:emp_management/employee/profile/view/employee_profile_screen.dart';
import 'package:emp_management/employee/salary/view/employee_salary_screen.dart';
import 'package:flutter/material.dart';


class EmployeeNavigation extends StatefulWidget {
  const EmployeeNavigation({Key? key}) : super(key: key);

  @override
  State<EmployeeNavigation> createState() => _EmployeeNavigationState();
}

class _EmployeeNavigationState extends State<EmployeeNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const EmployeeHomeScreen(),
    const EmployeeLeaveScreen(),
    const EmployeeSalaryScreen(),
    const EmployeeProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If not on home screen, navigate to home instead of closing app
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false; // Prevent default back button behavior
        }
        // If already on home screen, allow back button to close app
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Leave',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_outlined),
              activeIcon: Icon(Icons.attach_money),
              label: 'Salary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      ),
    );
  }
}

