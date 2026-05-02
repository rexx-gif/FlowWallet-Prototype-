import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/transaction_model.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isExpense = true;
  String _amount = '0';
  String _selectedCategory = 'Makan & Minum';
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Makan', 'icon': Icons.restaurant, 'color': AppColors.iconOrange},
    {'name': 'Transport', 'icon': Icons.directions_car, 'color': AppColors.iconBlue},
    {'name': 'Belanja', 'icon': Icons.shopping_bag, 'color': AppColors.iconPurple},
    {'name': 'Rumah', 'icon': Icons.home, 'color': AppColors.iconRed},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Gaji', 'icon': Icons.account_balance_wallet, 'color': AppColors.iconGreen},
    {'name': 'Bonus', 'icon': Icons.card_giftcard, 'color': AppColors.iconOrange},
    {'name': 'Investasi', 'icon': Icons.trending_up, 'color': AppColors.iconBlue},
    {'name': 'Lainnya', 'icon': Icons.category, 'color': AppColors.iconPurple},
  ];

  void _appendAmount(String value) {
    setState(() {
      if (_amount == '0') {
        _amount = value;
      } else {
        _amount += value;
      }
    });
  }

  void _deleteAmount() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
  }

  void _saveTransaction() async {
    final double amount = double.tryParse(_amount) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    final transaction = TransactionModel(
      uid: Provider.of<AuthProvider>(context, listen: false).user?.uid ?? '',
      title: _noteController.text.isNotEmpty ? _noteController.text : _selectedCategory,
      amount: amount,
      category: _selectedCategory,
      type: _isExpense ? 'expense' : 'income',
      date: DateTime.now(),
      note: _noteController.text,
    );

    await Provider.of<TransactionProvider>(context, listen: false).addTransaction(transaction);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTypeToggle(),
                  _buildAmountInput(),
                  _buildCategoryGrid(),
                  _buildDetailsForm(),
                  _buildNumpad(),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Tambah Transaksi', style: AppTextStyles.headlineSmall),
          const SizedBox(width: 48), // To balance the close button
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isExpense = true;
                _selectedCategory = _expenseCategories[0]['name'];
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isExpense ? AppColors.danger.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Pengeluaran',
                    style: TextStyle(
                      color: _isExpense ? AppColors.danger : AppColors.textSecondary,
                      fontWeight: _isExpense ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isExpense = false;
                _selectedCategory = _incomeCategories[0]['name'];
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isExpense ? AppColors.success.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Pemasukan',
                    style: TextStyle(
                      color: !_isExpense ? AppColors.success : AppColors.textSecondary,
                      fontWeight: !_isExpense ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text('Nominal', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Rp ',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                _amount,
                style: AppTextStyles.headlineLarge.copyWith(fontSize: 48),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = _isExpense ? _expenseCategories : _incomeCategories;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['name']),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? cat['color'].withOpacity(0.2) : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? cat['color'] : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(cat['icon'], color: isSelected ? cat['color'] : AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'],
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            controller: _noteController,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Tambahkan catatan (opsional)...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.edit_note, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text('Hari ini', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text('Dompet', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.background,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNumpadButton('1'),
              _buildNumpadButton('2'),
              _buildNumpadButton('3'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNumpadButton('4'),
              _buildNumpadButton('5'),
              _buildNumpadButton('6'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNumpadButton('7'),
              _buildNumpadButton('8'),
              _buildNumpadButton('9'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNumpadButton('000'),
              _buildNumpadButton('0'),
              _buildNumpadButton('<', isIcon: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(String label, {bool isIcon = false}) {
    return GestureDetector(
      onTap: () {
        if (isIcon) {
          _deleteAmount();
        } else {
          _appendAmount(label);
        }
      },
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: isIcon
              ? const Icon(Icons.backspace_outlined, color: AppColors.textPrimary)
              : Text(label, style: AppTextStyles.headlineSmall),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.background,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _saveTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'Simpan Transaksi',
            style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
