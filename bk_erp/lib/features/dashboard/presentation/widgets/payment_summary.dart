import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/app_data.dart';

class PaymentSummary extends StatelessWidget {
  final AppData appData;
  final NumberFormat nf;

  const PaymentSummary({super.key, required this.appData, required this.nf});

  Widget _paymentRow(IconData icon, String label, double amount, Color color, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(count, style: TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
          Text(nf.format(amount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cashIn = appData.customerCashPaid;
    final onlineIn = appData.customerOnlinePaid;
    final cashOut = appData.supplierCashPaid;
    final onlineOut = appData.supplierOnlinePaid;
    final totalIn = cashIn + onlineIn;
    final totalOut = cashOut + onlineOut;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.surfaceBorder),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: AppColors.tableHeaderBg,
            child: Row(
              children: const [
                Icon(Icons.payments, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('Payment Summary (Cash vs Online)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.tableHeaderText)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          // ── Received from Customers ──
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text('RECEIVED FROM CUSTOMERS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          _paymentRow(Icons.money, 'Cash Received', cashIn, AppColors.success, '${appData.customerCashCount} customers'),
          _paymentRow(Icons.account_balance, 'Online Received', onlineIn, AppColors.info, '${appData.customerOnlineCount} customers'),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Received', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Text(nf.format(totalIn), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          // ── Paid to Suppliers ──
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text('PAID TO SUPPLIERS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          _paymentRow(Icons.money, 'Cash Paid', cashOut, AppColors.warning, '${appData.supplierCashCount} suppliers'),
          _paymentRow(Icons.account_balance, 'Online Paid', onlineOut, AppColors.info, '${appData.supplierOnlineCount} suppliers'),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Paid', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Text(nf.format(totalOut), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warning)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
