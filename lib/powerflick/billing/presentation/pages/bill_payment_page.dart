import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/k_colors.dart';
import '../../domain/models/electricity_bill.dart';
import '../providers/bill_provider.dart';
import '../widgets/payment_method_selector.dart';

class BillPaymentPage extends ConsumerStatefulWidget {
  final ElectricityBill? bill;
  final List<ElectricityBill>? bills;

  const BillPaymentPage({
    super.key,
    this.bill,
    this.bills,
  });

  @override
  ConsumerState<BillPaymentPage> createState() => _BillPaymentPageState();
}

class _BillPaymentPageState extends ConsumerState<BillPaymentPage> {
  PaymentMethod? selectedPaymentMethod;
  final _amountController = TextEditingController();

  bool get isBulkPayment => widget.bills != null && widget.bills!.length > 1;
  
  List<ElectricityBill> get billsToProcess {
    return widget.bills ?? [widget.bill!];
  }

  double get totalAmount {
    return billsToProcess.fold<double>(0, (sum, bill) => sum + bill.amount);
  }

  @override
  void initState() {
    super.initState();
    _amountController.text = totalAmount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);
    final paymentState = ref.watch(billPaymentProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(
          isBulkPayment ? 'Pay Multiple Bills' : 'Pay Bill',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBillsSummary(),
            const SizedBox(height: 24),
            
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            paymentMethodsAsync.when(
              data: (methods) => PaymentMethodSelector(
                paymentMethods: methods,
                selectedMethod: selectedPaymentMethod,
                onMethodSelected: (method) {
                  setState(() {
                    selectedPaymentMethod = method;
                  });
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            
            const SizedBox(height: 24),
            
            if (paymentState.error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(paymentState.error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: selectedPaymentMethod != null && !paymentState.isLoading
                ? _processPayment
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: KColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: paymentState.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Pay \$${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillsSummary() {
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
            isBulkPayment ? 'Bills to Pay (${billsToProcess.length})' : 'Bill Details',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          if (isBulkPayment) ...[
            ...billsToProcess.map((bill) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${bill.providerName} (${bill.accountNumber.substring(bill.accountNumber.length - 4)})'),
                  Text('\$${bill.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            )),
          ] else ...[
            Text('Provider: ${widget.bill!.providerName}'),
            const SizedBox(height: 8),
            Text('Account: ${widget.bill!.accountNumber}'),
            const SizedBox(height: 8),
            Text('Due Date: ${DateFormat('MMM dd, yyyy').format(widget.bill!.dueDate)}'),
          ],
          
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('\$${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: KColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (selectedPaymentMethod == null) return;

    final success = isBulkPayment
        ? await ref.read(billPaymentProvider.notifier).payMultipleBills(
            bills: billsToProcess,
            paymentMethod: selectedPaymentMethod!,
          )
        : await ref.read(billPaymentProvider.notifier).payBill(
            bill: widget.bill!,
            paymentMethod: selectedPaymentMethod!,
          );

    if (success) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context);
        ref.refresh(userBillsProvider);
      }
    }
  }
} 