import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/k_colors.dart';
import '../../domain/models/electricity_bill.dart';

class BillCard extends StatelessWidget {
  final ElectricityBill bill;
  final VoidCallback? onPayNow;
  final VoidCallback? onViewDetails;
  final bool isUpcoming;
  final bool isPaid;

  const BillCard({
    super.key,
    required this.bill,
    this.onPayNow,
    this.onViewDetails,
    this.isUpcoming = false,
    this.isPaid = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = bill.status == BillStatus.overdue;
    final cardColor = _getCardColor();
    final accentColor = _getAccentColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOverdue ? Border.all(color: Colors.red, width: 2) : null,
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
        children: [
          // Header with provider and status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getProviderIcon(),
                    color: cardColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.providerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Account: ${bill.accountNumber.substring(bill.accountNumber.length - 4)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
          ),

          // Bill details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount Due',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${bill.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isPaid ? 'Paid Date' : 'Due Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPaid 
                            ? DateFormat('MMM dd, yyyy').format(bill.paidDate ?? bill.dueDate)
                            : DateFormat('MMM dd, yyyy').format(bill.dueDate),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isOverdue ? Colors.red : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Usage and billing period
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Usage',
                          '${bill.usageKwh.toStringAsFixed(0)} kWh',
                          Icons.flash_on,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Period',
                          '${DateFormat('MMM dd').format(bill.billingPeriodStart)} - ${DateFormat('MMM dd').format(bill.billingPeriodEnd)}',
                          Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isPaid) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (onViewDetails != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onViewDetails,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      if (onViewDetails != null && onPayNow != null)
                        const SizedBox(width: 12),
                      if (onPayNow != null)
                        Expanded(
                          flex: isUpcoming ? 1 : 2,
                          child: ElevatedButton(
                            onPressed: onPayNow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isUpcoming ? Colors.blue : accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            child: Text(
                              isUpcoming ? 'Schedule Payment' : 'Pay Now',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],

                if (isPaid) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: KColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Paid via ${bill.paymentMethod ?? 'Card'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: KColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (onViewDetails != null)
                        TextButton(
                          onPressed: onViewDetails,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View Receipt',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String chipText;

    switch (bill.status) {
      case BillStatus.pending:
        chipColor = Colors.orange;
        chipText = 'Pending';
        break;
      case BillStatus.overdue:
        chipColor = Colors.red;
        chipText = 'Overdue';
        break;
      case BillStatus.paid:
        chipColor = KColors.success;
        chipText = 'Paid';
        break;
      case BillStatus.processing:
        chipColor = Colors.blue;
        chipText = 'Processing';
        break;
      default:
        chipColor = Colors.grey;
        chipText = bill.status.name.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        chipText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getCardColor() {
    if (isPaid) return KColors.success;
    if (bill.status == BillStatus.overdue) return Colors.red;
    if (isUpcoming) return Colors.blue;
    return KColors.primary;
  }

  Color _getAccentColor() {
    if (isPaid) return KColors.success;
    if (bill.status == BillStatus.overdue) return Colors.red;
    if (isUpcoming) return Colors.blue;
    return KColors.primary;
  }

  IconData _getProviderIcon() {
    switch (bill.provider) {
      case UtilityProvider.pge:
      case UtilityProvider.sdge:
      case UtilityProvider.sce:
        return Icons.flash_on;
      case UtilityProvider.ladwp:
        return Icons.water_drop;
      default:
        return Icons.electrical_services;
    }
  }
} 