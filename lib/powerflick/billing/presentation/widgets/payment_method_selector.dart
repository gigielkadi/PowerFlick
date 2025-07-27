import 'package:flutter/material.dart';

import '../../../../core/constants/k_colors.dart';
import '../../domain/models/electricity_bill.dart';

class PaymentMethodSelector extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.paymentMethods,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (paymentMethods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.credit_card_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No Payment Methods',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a payment method to continue',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add payment method
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Payment Method'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: paymentMethods.map((method) {
        final isSelected = selectedMethod?.id == method.id;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? KColors.primary : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: KColors.primary.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ListTile(
            onTap: () => onMethodSelected(method),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPaymentTypeColor(method.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getPaymentTypeIcon(method.type),
                color: _getPaymentTypeColor(method.type),
                size: 24,
              ),
            ),
            title: Text(
              method.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? KColors.primary : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (method.last4Digits != null)
                  Text(
                    '•••• •••• •••• ${method.last4Digits}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                if (method.expiryDate != null)
                  Text(
                    'Expires ${method.expiryDate!.month.toString().padLeft(2, '0')}/${method.expiryDate!.year.toString().substring(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (method.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: KColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: KColors.primary,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? KColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? KColors.primary : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getPaymentTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.creditCard:
        return Icons.credit_card;
      case PaymentType.debitCard:
        return Icons.credit_card;
      case PaymentType.bankAccount:
        return Icons.account_balance;
      case PaymentType.paypal:
        return Icons.payment;
      case PaymentType.applePay:
        return Icons.phone_iphone;
      case PaymentType.googlePay:
        return Icons.payment;
      case PaymentType.venmo:
        return Icons.payment;
      case PaymentType.zelle:
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentTypeColor(PaymentType type) {
    switch (type) {
      case PaymentType.creditCard:
        return Colors.blue;
      case PaymentType.debitCard:
        return Colors.green;
      case PaymentType.bankAccount:
        return Colors.purple;
      case PaymentType.paypal:
        return Colors.indigo;
      case PaymentType.applePay:
        return Colors.black;
      case PaymentType.googlePay:
        return Colors.orange;
      case PaymentType.venmo:
        return Colors.blue;
      case PaymentType.zelle:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 