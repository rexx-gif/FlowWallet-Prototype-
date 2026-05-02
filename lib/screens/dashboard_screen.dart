import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final uid = Provider.of<AuthProvider>(context, listen: false).user?.uid ?? '';
            await Provider.of<TransactionProvider>(context, listen: false).loadTransactions(uid);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildBalanceCard(context),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildBudgetProgress(context),
                const SizedBox(height: 32),
                _buildRecentTransactions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final userName = auth.user?.name ?? 'User';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $userName!',
                  style: AppTextStyles.headlineSmall,
                ),
                Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        );
      }
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.surfaceDarker),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Balance', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatRupiah(provider.totalBalance),
                    style: AppTextStyles.amountLarge,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '+Rp 320k', // Mock data
                      style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('Income', CurrencyFormatter.formatCompact(provider.monthlyIncome), Icons.arrow_downward, AppColors.success),
                  _buildStatItem('Expense', CurrencyFormatter.formatCompact(provider.monthlyExpense), Icons.arrow_upward, AppColors.danger),
                  _buildStatItem('Saving', '1.5jt', Icons.savings, AppColors.info),
                ],
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatItem(String label, String amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            Text(amount, style: AppTextStyles.labelLarge),
          ],
        )
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem('Tambah', Icons.add),
        _buildActionItem('Transfer', Icons.swap_horiz),
        _buildActionItem('Tujuan', Icons.flag),
        _buildActionItem('Laporan', Icons.pie_chart),
      ],
    );
  }

  Widget _buildActionItem(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildBudgetProgress(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final progress = provider.budgetProgress.clamp(0.0, 1.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budget Bulanan', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tersisa ${CurrencyFormatter.formatRupiah(provider.budgetLimit - provider.monthlyExpense)}',
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transaksi Terakhir', style: AppTextStyles.labelLarge),
                TextButton(
                  onPressed: () {}, // Navigate to full transactions list handled by bottom nav
                  child: Text('Lihat semua', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text('Belum ada transaksi', style: AppTextStyles.bodyMedium),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.transactions.length > 5 ? 5 : provider.transactions.length,
                separatorBuilder: (context, index) => const Divider(color: AppColors.surfaceDarker),
                itemBuilder: (context, index) {
                  return TransactionTile(transaction: provider.transactions[index]);
                },
              ),
          ],
        );
      }
    );
  }
}
