enum BillStatus {
  pending,
  overdue,
  paid,
  processing,
  failed,
  refunded
}

enum UtilityProvider {
  pge('Pacific Gas & Electric', 'PG&E'),
  sdge('San Diego Gas & Electric', 'SDG&E'),
  sce('Southern California Edison', 'SCE'),
  ladwp('Los Angeles Department of Water and Power', 'LADWP'),
  conEd('Consolidated Edison', 'Con Ed'),
  nationalgrid('National Grid', 'National Grid'),
  dominion('Dominion Energy', 'Dominion'),
  duke('Duke Energy', 'Duke Energy'),
  fpl('Florida Power & Light', 'FPL'),
  teco('Tampa Electric', 'TECO'),
  other('Other', 'Other');

  const UtilityProvider(this.fullName, this.displayName);
  final String fullName;
  final String displayName;
}

class ElectricityBill {
  final String id;
  final String userId;
  final String accountNumber;
  final UtilityProvider provider;
  final String providerName;
  final double amount;
  final double usageKwh;
  final DateTime billingPeriodStart;
  final DateTime billingPeriodEnd;
  final DateTime dueDate;
  final DateTime issueDate;
  final BillStatus status;
  final String? barcode;
  final String? referenceNumber;
  final double? previousBalance;
  final double? payments;
  final double? adjustments;
  final double? lateCharges;
  final double? taxes;
  final Map<String, dynamic>? rateStructure;
  final Map<String, dynamic>? usageBreakdown;
  final String? billPdfUrl;
  final DateTime? paidDate;
  final String? paymentMethod;
  final String? transactionId;
  final bool? isAutoPay;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ElectricityBill({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.provider,
    required this.providerName,
    required this.amount,
    required this.usageKwh,
    required this.billingPeriodStart,
    required this.billingPeriodEnd,
    required this.dueDate,
    required this.issueDate,
    required this.status,
    this.barcode,
    this.referenceNumber,
    this.previousBalance,
    this.payments,
    this.adjustments,
    this.lateCharges,
    this.taxes,
    this.rateStructure,
    this.usageBreakdown,
    this.billPdfUrl,
    this.paidDate,
    this.paymentMethod,
    this.transactionId,
    this.isAutoPay,
    this.createdAt,
    this.updatedAt,
  });

  factory ElectricityBill.fromJson(Map<String, dynamic> json) {
    return ElectricityBill(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountNumber: json['account_number'] as String,
      provider: UtilityProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => UtilityProvider.other,
      ),
      providerName: json['provider_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      usageKwh: (json['usage_kwh'] as num).toDouble(),
      billingPeriodStart: DateTime.parse(json['billing_period_start'] as String),
      billingPeriodEnd: DateTime.parse(json['billing_period_end'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      issueDate: DateTime.parse(json['issue_date'] as String),
      status: BillStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => BillStatus.pending,
      ),
      barcode: json['barcode'] as String?,
      referenceNumber: json['reference_number'] as String?,
      previousBalance: (json['previous_balance'] as num?)?.toDouble(),
      payments: (json['payments'] as num?)?.toDouble(),
      adjustments: (json['adjustments'] as num?)?.toDouble(),
      lateCharges: (json['late_charges'] as num?)?.toDouble(),
      taxes: (json['taxes'] as num?)?.toDouble(),
      rateStructure: json['rate_structure'] as Map<String, dynamic>?,
      usageBreakdown: json['usage_breakdown'] as Map<String, dynamic>?,
      billPdfUrl: json['bill_pdf_url'] as String?,
      paidDate: json['paid_date'] != null ? DateTime.parse(json['paid_date'] as String) : null,
      paymentMethod: json['payment_method'] as String?,
      transactionId: json['transaction_id'] as String?,
      isAutoPay: json['is_auto_pay'] as bool?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_number': accountNumber,
      'provider': provider.name,
      'provider_name': providerName,
      'amount': amount,
      'usage_kwh': usageKwh,
      'billing_period_start': billingPeriodStart.toIso8601String(),
      'billing_period_end': billingPeriodEnd.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'issue_date': issueDate.toIso8601String(),
      'status': status.name,
      'barcode': barcode,
      'reference_number': referenceNumber,
      'previous_balance': previousBalance,
      'payments': payments,
      'adjustments': adjustments,
      'late_charges': lateCharges,
      'taxes': taxes,
      'rate_structure': rateStructure,
      'usage_breakdown': usageBreakdown,
      'bill_pdf_url': billPdfUrl,
      'paid_date': paidDate?.toIso8601String(),
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'is_auto_pay': isAutoPay,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

enum PaymentType {
  creditCard,
  debitCard,
  bankAccount,
  paypal,
  applePay,
  googlePay,
  venmo,
  zelle
}

class PaymentMethod {
  final String id;
  final String userId;
  final PaymentType type;
  final String name;
  final String? last4Digits;
  final String? bankName;
  final String? cardBrand;
  final DateTime? expiryDate;
  final bool isDefault;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.last4Digits,
    this.bankName,
    this.cardBrand,
    this.expiryDate,
    required this.isDefault,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: PaymentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PaymentType.creditCard,
      ),
      name: json['name'] as String,
      last4Digits: json['last4_digits'] as String?,
      bankName: json['bank_name'] as String?,
      cardBrand: json['card_brand'] as String?,
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date'] as String) : null,
      isDefault: json['is_default'] as bool,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded
}

class UtilityAccount {
  final String id;
  final String userId;
  final String accountNumber;
  final UtilityProvider provider;
  final String customerName;
  final String serviceAddress;
  final String? nickname;
  final bool? isActive;
  final bool? isAutoBillEnabled;
  final String? defaultPaymentMethodId;
  final DateTime? createdAt;

  const UtilityAccount({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.provider,
    required this.customerName,
    required this.serviceAddress,
    this.nickname,
    this.isActive,
    this.isAutoBillEnabled,
    this.defaultPaymentMethodId,
    this.createdAt,
  });

  factory UtilityAccount.fromJson(Map<String, dynamic> json) {
    return UtilityAccount(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountNumber: json['account_number'] as String,
      provider: UtilityProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => UtilityProvider.other,
      ),
      customerName: json['customer_name'] as String,
      serviceAddress: json['service_address'] as String,
      nickname: json['nickname'] as String?,
      isActive: json['is_active'] as bool?,
      isAutoBillEnabled: json['is_auto_bill_enabled'] as bool?,
      defaultPaymentMethodId: json['default_payment_method_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }
} 