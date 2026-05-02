import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Ganti Nama', style: AppTextStyles.headlineSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Nama baru',
            hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              await Provider.of<AuthProvider>(context, listen: false).updateName(name);
            },
            child: Text('Simpan', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Profil', style: AppTextStyles.headlineSmall),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 32),
            _buildStats(context),
            const SizedBox(height: 32),
            _buildMenuSection(
              title: 'AKUN',
              items: [
                _buildMenuItem(Icons.account_balance_wallet, 'Dompet'),
                _buildMenuItem(Icons.category, 'Kategori'),
                _buildMenuItem(Icons.import_export, 'Export Data'),
              ],
            ),
            const SizedBox(height: 24),
            _buildMenuSection(
              title: 'PREFERENSI',
              items: [
                _buildMenuItem(Icons.attach_money, 'Mata Uang', trailing: 'IDR'),
                _buildMenuItem(Icons.language, 'Bahasa', trailing: 'Indonesia'),
              ],
            ),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final userName = auth.user?.name ?? 'User';
        final userEmail = auth.user?.email ?? '';
        return Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(userName, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 4),
            Text(userEmail, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showEditNameDialog(context, userName),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceDarker),
                ),
                child: Text('Edit Profil', style: AppTextStyles.labelMedium),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStats(BuildContext context) {
    return Consumer2<TransactionProvider, AuthProvider>(
      builder: (context, txProvider, authProvider, _) {
        final transactions = txProvider.transactions;
        final totalTx = transactions.length;
        final months = transactions.map((t) => '${t.date.year}-${t.date.month}').toSet().length;
        return Row(
          children: [
            Expanded(child: _buildStatItem(totalTx.toString(), 'Total Transaksi', Icons.receipt)),
            Container(width: 1, height: 40, color: AppColors.surfaceDarker),
            Expanded(child: _buildStatItem(months.toString(), 'Bulan Aktif', Icons.calendar_today)),
            Container(width: 1, height: 40, color: AppColors.surfaceDarker),
            Expanded(child: _buildStatItem(
              transactions.where((t) => t.type == 'income').length.toString(),
              'Pemasukan',
              Icons.arrow_downward,
            )),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.labelLarge),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildMenuSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? trailing}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) Text(trailing, style: AppTextStyles.bodyMedium),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () async {
          await Provider.of<AuthProvider>(context, listen: false).signOut();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.logout, color: AppColors.danger),
        label: Text('Keluar', style: AppTextStyles.labelLarge.copyWith(color: AppColors.danger)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.danger),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
