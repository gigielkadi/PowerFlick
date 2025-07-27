import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/k_colors.dart';
import '../../../widgets/powerflick_bottom_nav_bar.dart';
import '../../domain/models/electricity_bill.dart';
import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';
import '../widgets/payment_method_selector.dart';
import 'bill_payment_page.dart';
import 'add_utility_provider_page.dart';

class BillManagementPage extends ConsumerStatefulWidget {
  const BillManagementPage({super.key});

  @override
  ConsumerState<BillManagementPage> createState() => _BillManagementPageState();
}

class _BillManagementPageState extends ConsumerState<BillManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(userBillsProvider);
    final upcomingBillsAsync = ref.watch(upcomingBillsProvider);
    final billHistoryAsync = ref.watch(billHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Electricity Bills',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddUtilityProviderPage(),
                ),
              );
            },
            icon: const Icon(Icons.add, color: Colors.black),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: KColors.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: KColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Current'),
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Current Bills Tab
          _buildCurrentBillsTab(billsAsync),
          
          // Upcoming Bills Tab
          _buildUpcomingBillsTab(upcomingBillsAsync),
          
          // History Tab
          _buildHistoryTab(billHistoryAsync),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQuickPayDialog();
        },
        backgroundColor: KColors.primary,
        icon: const Icon(Icons.flash_on, color: Colors.white),
        label: const Text(
          'Quick Pay',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: const PowerFlickBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildCurrentBillsTab(AsyncValue<List<ElectricityBill>> billsAsync) {
    return billsAsync.when(
      data: (bills) {
        final currentBills = bills.where((bill) => 
          bill.status == BillStatus.pending || bill.status == BillStatus.overdue
        ).toList();

        if (currentBills.isEmpty) {
          return _buildEmptyState(
            'No Current Bills',
            'All your bills are up to date!',
            Icons.check_circle,
            KColors.success,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(userBillsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Card
              _buildBillSummaryCard(currentBills),
              const SizedBox(height: 20),
              
              // Bills List
              ...currentBills.map((bill) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BillCard(
                  bill: bill,
                  onPayNow: () => _navigateToPayment(bill),
                  onViewDetails: () => _showBillDetails(bill),
                ),
              )),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildUpcomingBillsTab(AsyncValue<List<ElectricityBill>> upcomingBillsAsync) {
    return upcomingBillsAsync.when(
      data: (bills) {
        if (bills.isEmpty) {
          return _buildEmptyState(
            'No Upcoming Bills',
            'We\'ll notify you when new bills arrive',
            Icons.schedule,
            Colors.blue,
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Auto-pay Settings Card
            _buildAutoPayCard(),
            const SizedBox(height: 20),
            
            // Upcoming Bills
            ...bills.map((bill) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BillCard(
                bill: bill,
                onPayNow: () => _navigateToPayment(bill),
                onViewDetails: () => _showBillDetails(bill),
                isUpcoming: true,
              ),
            )),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildHistoryTab(AsyncValue<List<ElectricityBill>> historyAsync) {
    return historyAsync.when(
      data: (bills) {
        final paidBills = bills.where((bill) => bill.status == BillStatus.paid).toList();
        
        if (paidBills.isEmpty) {
          return _buildEmptyState(
            'No Payment History',
            'Your payment history will appear here',
            Icons.history,
            Colors.grey,
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Monthly Summary
            _buildMonthlySummary(paidBills),
            const SizedBox(height: 20),
            
            // Payment History
            ...paidBills.map((bill) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BillCard(
                bill: bill,
                onViewDetails: () => _showBillDetails(bill),
                isPaid: true,
              ),
            )),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildBillSummaryCard(List<ElectricityBill> bills) {
    final totalAmount = bills.fold<double>(0, (sum, bill) => sum + bill.amount);
    final overdueBills = bills.where((bill) => bill.status == BillStatus.overdue).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: overdueBills > 0 
            ? [Colors.red, Colors.red.withOpacity(0.8)]
            : [KColors.primary, KColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (overdueBills > 0 ? Colors.red : KColors.primary).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Due',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (overdueBills > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$overdueBills Overdue',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: totalAmount > 0 ? () => _payAllBills(bills) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: overdueBills > 0 ? Colors.red : KColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Pay All Bills',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoPayCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.autorenew,
                  color: KColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Pay',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Never miss a payment again',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: false, // Get from provider
                onChanged: (value) {
                  // Implement auto-pay toggle
                },
                activeColor: KColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(List<ElectricityBill> paidBills) {
    final thisMonth = DateTime.now().month;
    final thisYear = DateTime.now().year;
    final thisMonthBills = paidBills.where((bill) => 
      bill.dueDate.month == thisMonth && bill.dueDate.year == thisYear
    ).toList();
    
    final monthlyTotal = thisMonthBills.fold<double>(0, (sum, bill) => sum + bill.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Paid',
                  '\$${monthlyTotal.toStringAsFixed(2)}',
                  Icons.payments,
                  KColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'Bills Paid',
                  '${thisMonthBills.length}',
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(userBillsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _navigateToPayment(ElectricityBill bill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillPaymentPage(bill: bill),
      ),
    );
  }

  void _showBillDetails(ElectricityBill bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BillDetailsSheet(bill: bill),
    );
  }

  void _showQuickPayDialog() {
    showDialog(
      context: context,
      builder: (context) => const _QuickPayDialog(),
    );
  }

  void _payAllBills(List<ElectricityBill> bills) {
    // Navigate to bulk payment page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillPaymentPage(bills: bills),
      ),
    );
  }
}

class _BillDetailsSheet extends StatelessWidget {
  final ElectricityBill bill;

  const _BillDetailsSheet({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Bill Details',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add bill details content here
                  _buildDetailRow('Provider', bill.providerName),
                  _buildDetailRow('Account Number', bill.accountNumber),
                  _buildDetailRow('Billing Period', '${DateFormat('MMM dd').format(bill.billingPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(bill.billingPeriodEnd)}'),
                  _buildDetailRow('Due Date', DateFormat('MMM dd, yyyy').format(bill.dueDate)),
                  _buildDetailRow('Amount', '\$${bill.amount.toStringAsFixed(2)}'),
                  _buildDetailRow('Usage', '${bill.usageKwh.toStringAsFixed(0)} kWh'),
                  // Add more details as needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPayDialog extends StatelessWidget {
  const _QuickPayDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quick Pay'),
      content: const Text('Enter your account number to quickly pay your electricity bill.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigate to quick pay flow
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
} 