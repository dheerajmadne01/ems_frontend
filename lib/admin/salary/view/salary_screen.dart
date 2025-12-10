import 'package:emp_management/admin/widgets/primary_button.dart';
import 'package:emp_management/admin/widgets/screen_header.dart';
import 'package:emp_management/admin/widgets/summary_card.dart';
import 'package:emp_management/admin/widgets/transaction_item.dart';
import 'package:emp_management/core/text_styles.dart';
import 'package:flutter/material.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({Key? key}) : super(key: key);

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final List<_TransactionData> _transactions = [
    _TransactionData('Sarah Johnson', 'UX Designer', '\$5200', 'Paid', Colors.green),
    _TransactionData('Michael Chen', 'Frontend Dev', '\$4800', 'Paid', Colors.green),
    _TransactionData('Emma Wilson', 'Product Manager', '\$6500', 'Pending', Colors.orange),
    _TransactionData('James Rod', 'Backend Dev', '\$5000', 'Paid', Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Salary',
                trailing: PrimaryButton(
                  label: 'Run Payroll',
                  isFullWidth: false,
                  onPressed: () {},
                  verticalPadding: 12,
                ),
              ),
              const SizedBox(height: 24),
              SummaryCard(
                title: 'Total Disbursed',
                amount: '\$115,400',
                trendText: '+2.5% from last month',
                icon: Icons.attach_money,
              ),
              const SizedBox(height: 24),
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: AppTextStyles.heading3.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._transactions.map((transaction) {
          return TransactionItem(
            name: transaction.name,
            role: transaction.role,
            amount: transaction.amount,
            status: transaction.status,
            statusColor: transaction.statusColor,
            onDownloadPressed: () {},
          );
        }).toList(),
      ],
    );
  }
}

class _TransactionData {
  final String name;
  final String role;
  final String amount;
  final String status;
  final Color statusColor;

  _TransactionData(this.name, this.role, this.amount, this.status, this.statusColor);
}