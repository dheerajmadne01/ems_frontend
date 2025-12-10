import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:emp_management/employee/widgets/payslip_item.dart';
import 'package:emp_management/employee/widgets/salary_card.dart';
import 'package:flutter/material.dart';
class EmployeeSalaryScreen extends StatefulWidget {
  const EmployeeSalaryScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeSalaryScreen> createState() => _EmployeeSalaryScreenState();
}

class _EmployeeSalaryScreenState extends State<EmployeeSalaryScreen> {
  final List<Map<String, String>> _payslips = [
    {
      'month': 'October 2023',
      'date': 'Nov 01, 2023',
      'amount': '\$5200',
    },
    {
      'month': 'September 2023',
      'date': 'Oct 01, 2023',
      'amount': '\$5200',
    },
    {
      'month': 'August 2023',
      'date': 'Sep 01, 2023',
      'amount': '\$5200',
    },
    {
      'month': 'July 2023',
      'date': 'Aug 01, 2023',
      'amount': '\$5000',
    },
  ];

  void _downloadPayslip(String month) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading payslip for $month'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Salary History',
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SalaryCard(
                amount: '\$5,200.00',
                date: 'Nov 01, 2023',
              ),
              const SizedBox(height: 32),
              Text(
                'Payslips',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._payslips.map((payslip) => PayslipItem(
                    month: payslip['month']!,
                    date: payslip['date']!,
                    amount: payslip['amount']!,
                    onDownload: () => _downloadPayslip(payslip['month']!),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

