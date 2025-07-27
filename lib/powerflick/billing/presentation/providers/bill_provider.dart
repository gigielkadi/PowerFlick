import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/electricity_bill.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Current user's bills
final userBillsProvider = FutureProvider<List<ElectricityBill>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    throw Exception('User not authenticated');
  }

  try {
    // Try to fetch from bills table, create sample data if table doesn't exist
    final response = await supabase
        .from('electricity_bills')
        .select()
        .eq('user_id', user.id)
        .order('due_date', ascending: true);

    final bills = (response as List)
        .map((json) => ElectricityBill.fromJson(json))
        .toList();

    return bills;
  } catch (e) {
    // If table doesn't exist, return sample data
    return _getSampleBills(user.id);
  }
});

// Upcoming bills (next 60 days)
final upcomingBillsProvider = FutureProvider<List<ElectricityBill>>((ref) async {
  final allBills = await ref.watch(userBillsProvider.future);
  final now = DateTime.now();
  final futureLimit = now.add(const Duration(days: 60));
  
  return allBills.where((bill) {
    return bill.dueDate.isAfter(now) && 
           bill.dueDate.isBefore(futureLimit) &&
           bill.status == BillStatus.pending;
  }).toList();
});

// Bill history (paid bills)
final billHistoryProvider = FutureProvider<List<ElectricityBill>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    throw Exception('User not authenticated');
  }

  try {
    final response = await supabase
        .from('electricity_bills')
        .select()
        .eq('user_id', user.id)
        .eq('status', 'paid')
        .order('paid_date', ascending: false)
        .limit(50);

    final bills = (response as List)
        .map((json) => ElectricityBill.fromJson(json))
        .toList();

    return bills;
  } catch (e) {
    return _getSamplePaidBills(user.id);
  }
});

// User's payment methods
final paymentMethodsProvider = FutureProvider<List<PaymentMethod>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    throw Exception('User not authenticated');
  }

  try {
    final response = await supabase
        .from('payment_methods')
        .select()
        .eq('user_id', user.id)
        .eq('is_active', true)
        .order('is_default', ascending: false);

    final methods = (response as List)
        .map((json) => PaymentMethod.fromJson(json))
        .toList();

    return methods;
  } catch (e) {
    return _getSamplePaymentMethods(user.id);
  }
});

// Utility accounts
final utilityAccountsProvider = FutureProvider<List<UtilityAccount>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    throw Exception('User not authenticated');
  }

  try {
    final response = await supabase
        .from('utility_accounts')
        .select()
        .eq('user_id', user.id)
        .eq('is_active', true);

    final accounts = (response as List)
        .map((json) => UtilityAccount.fromJson(json))
        .toList();

    return accounts;
  } catch (e) {
    return _getSampleUtilityAccounts(user.id);
  }
});

// Bill payment processing
final billPaymentProvider = StateNotifierProvider<BillPaymentNotifier, BillPaymentState>((ref) {
  return BillPaymentNotifier(ref.read(supabaseClientProvider));
});

class BillPaymentState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const BillPaymentState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  BillPaymentState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return BillPaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class BillPaymentNotifier extends StateNotifier<BillPaymentState> {
  final SupabaseClient _supabase;

  BillPaymentNotifier(this._supabase) : super(const BillPaymentState());

  Future<bool> payBill({
    required ElectricityBill bill,
    required PaymentMethod paymentMethod,
    double? customAmount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final paymentAmount = customAmount ?? bill.amount;
      
      // Simulate payment processing (replace with real payment gateway)
      await Future.delayed(const Duration(seconds: 2));
      
      // Update bill status in database
      await _supabase
          .from('electricity_bills')
          .update({
            'status': 'paid',
            'paid_date': DateTime.now().toIso8601String(),
            'payment_method': paymentMethod.name,
            'transaction_id': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
          })
          .eq('id', bill.id);

      // Record payment transaction
      await _supabase.from('bill_payments').insert({
        'id': 'PAY_${DateTime.now().millisecondsSinceEpoch}',
        'bill_id': bill.id,
        'user_id': bill.userId,
        'amount': paymentAmount,
        'status': 'completed',
        'payment_method_id': paymentMethod.id,
        'processed_date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Payment of \$${paymentAmount.toStringAsFixed(2)} completed successfully!',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Payment failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> payMultipleBills({
    required List<ElectricityBill> bills,
    required PaymentMethod paymentMethod,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final totalAmount = bills.fold<double>(0, (sum, bill) => sum + bill.amount);
      
      // Simulate bulk payment processing
      await Future.delayed(const Duration(seconds: 3));
      
      final transactionId = 'BULK_${DateTime.now().millisecondsSinceEpoch}';
      final paidDate = DateTime.now().toIso8601String();
      
      // Update all bills
      for (final bill in bills) {
        await _supabase
            .from('electricity_bills')
            .update({
              'status': 'paid',
              'paid_date': paidDate,
              'payment_method': paymentMethod.name,
              'transaction_id': transactionId,
            })
            .eq('id', bill.id);

        // Record individual payment
        await _supabase.from('bill_payments').insert({
          'id': 'PAY_${bill.id}_${DateTime.now().millisecondsSinceEpoch}',
          'bill_id': bill.id,
          'user_id': bill.userId,
          'amount': bill.amount,
          'status': 'completed',
          'payment_method_id': paymentMethod.id,
          'processed_date': paidDate,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Bulk payment of \$${totalAmount.toStringAsFixed(2)} for ${bills.length} bills completed!',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Bulk payment failed: ${e.toString()}',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

// Sample data generators
List<ElectricityBill> _getSampleBills(String userId) {
  final now = DateTime.now();
  
  return [
    ElectricityBill(
      id: 'bill_1',
      userId: userId,
      accountNumber: '1234567890',
      provider: UtilityProvider.pge,
      providerName: 'Pacific Gas & Electric',
      amount: 187.45,
      usageKwh: 756,
      billingPeriodStart: DateTime(now.year, now.month - 1, 15),
      billingPeriodEnd: DateTime(now.year, now.month, 14),
      dueDate: DateTime(now.year, now.month, 25),
      issueDate: DateTime(now.year, now.month, 1),
      status: BillStatus.pending,
      referenceNumber: 'REF123456',
      previousBalance: 0,
      lateCharges: 0,
      taxes: 12.45,
      createdAt: DateTime.now(),
    ),
    ElectricityBill(
      id: 'bill_2',
      userId: userId,
      accountNumber: '1234567890',
      provider: UtilityProvider.pge,
      providerName: 'Pacific Gas & Electric',
      amount: 245.78,
      usageKwh: 892,
      billingPeriodStart: DateTime(now.year, now.month - 2, 15),
      billingPeriodEnd: DateTime(now.year, now.month - 1, 14),
      dueDate: DateTime(now.year, now.month - 1, 25),
      issueDate: DateTime(now.year, now.month - 1, 1),
      status: BillStatus.overdue,
      referenceNumber: 'REF123455',
      previousBalance: 0,
      lateCharges: 15.50,
      taxes: 16.28,
      createdAt: DateTime.now(),
    ),
  ];
}

List<ElectricityBill> _getSamplePaidBills(String userId) {
  final now = DateTime.now();
  
  return [
    ElectricityBill(
      id: 'bill_paid_1',
      userId: userId,
      accountNumber: '1234567890',
      provider: UtilityProvider.pge,
      providerName: 'Pacific Gas & Electric',
      amount: 156.23,
      usageKwh: 634,
      billingPeriodStart: DateTime(now.year, now.month - 3, 15),
      billingPeriodEnd: DateTime(now.year, now.month - 2, 14),
      dueDate: DateTime(now.year, now.month - 2, 25),
      issueDate: DateTime(now.year, now.month - 2, 1),
      status: BillStatus.paid,
      paidDate: DateTime(now.year, now.month - 2, 20),
      paymentMethod: 'Credit Card ****1234',
      transactionId: 'TXN_PAID_123',
      createdAt: DateTime.now(),
    ),
  ];
}

List<PaymentMethod> _getSamplePaymentMethods(String userId) {
  return [
    PaymentMethod(
      id: 'pm_1',
      userId: userId,
      type: PaymentType.creditCard,
      name: 'Visa Credit Card',
      last4Digits: '1234',
      cardBrand: 'Visa',
      expiryDate: DateTime(2027, 12, 31),
      isDefault: true,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    PaymentMethod(
      id: 'pm_2',
      userId: userId,
      type: PaymentType.bankAccount,
      name: 'Chase Checking',
      last4Digits: '5678',
      bankName: 'Chase Bank',
      isDefault: false,
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];
}

List<UtilityAccount> _getSampleUtilityAccounts(String userId) {
  return [
    UtilityAccount(
      id: 'acc_1',
      userId: userId,
      accountNumber: '1234567890',
      provider: UtilityProvider.pge,
      customerName: 'John Doe',
      serviceAddress: '123 Main St, San Francisco, CA 94105',
      nickname: 'Home',
      isActive: true,
      isAutoBillEnabled: false,
      createdAt: DateTime.now(),
    ),
  ];
} 