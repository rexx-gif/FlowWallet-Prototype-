import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/transaction_model.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    
    // Assign colors and icons based on category
    IconData getIcon() {
      switch (transaction.category) {
        case 'Makan & Minum': return Icons.restaurant;
        case 'Transport': return Icons.directions_car;
        case 'Belanja': return Icons.shopping_bag;
        case 'Gaji': return Icons.account_balance_wallet;
        default: return Icons.receipt;
      }
    }
    
    Color getIconColor() {
      switch (transaction.category) {
        case 'Makan & Minum': return AppColors.iconOrange;
        case 'Transport': return AppColors.iconBlue;
        case 'Belanja': return AppColors.iconPurple;
        case 'Gaji': return AppColors.iconGreen;
        default: return AppColors.primary;
      }
    }

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: getIconColor().withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          getIcon(),
          color: getIconColor(),
        ),
      ),
      title: Text(
        transaction.title,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          DateFormatter.getRelativeDate(transaction.date),
          style: AppTextStyles.bodySmall,
        ),
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}${CurrencyFormatter.formatRupiah(transaction.amount)}',
        style: isIncome ? AppTextStyles.amountIncome : AppTextStyles.amountExpense,
      ),
    );
  }
}
