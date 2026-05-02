import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedCategory = 'Semua';
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['Semua', 'Pemasukan', 'Pengeluaran'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _prevMonth() => setState(() {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      });

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedMonth.year < now.year ||
        (_selectedMonth.year == now.year && _selectedMonth.month < now.month)) {
      setState(() {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Cari transaksi...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Text('Transaksi', style: AppTextStyles.headlineSmall),
        centerTitle: !_isSearching,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColors.textPrimary,
            ),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchQuery = '';
                _searchController.clear();
              }
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isSearching) _buildMonthSelector(),
          if (!_isSearching) const SizedBox(height: 16),
          _buildCategoryFilters(),
          const SizedBox(height: 16),
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final now = DateTime.now();
    final isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: _prevMonth,
          ),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth),
            style: AppTextStyles.labelLarge,
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isCurrentMonth ? AppColors.textSecondary : AppColors.textPrimary,
            ),
            onPressed: isCurrentMonth ? null : _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionList() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var list = provider.transactions;

        // Filter by month (skip when searching)
        if (!_isSearching) {
          list = list
              .where((t) =>
                  t.date.year == _selectedMonth.year &&
                  t.date.month == _selectedMonth.month)
              .toList();
        }

        // Filter by category
        if (_selectedCategory == 'Pemasukan') {
          list = list.where((t) => t.type == 'income').toList();
        } else if (_selectedCategory == 'Pengeluaran') {
          list = list.where((t) => t.type == 'expense').toList();
        }

        // Filter by search
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          list = list
              .where((t) =>
                  t.title.toLowerCase().contains(q) ||
                  t.category.toLowerCase().contains(q))
              .toList();
        }

        if (list.isEmpty) {
          return Center(
            child: Text('Tidak ada transaksi', style: AppTextStyles.bodyMedium),
          );
        }

        final uid = Provider.of<AuthProvider>(context, listen: false).user?.uid ?? '';

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(color: AppColors.surfaceDarker),
          itemBuilder: (context, index) {
            final tx = list[index];
            return Dismissible(
              key: Key(tx.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline, color: AppColors.danger),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: Text('Hapus Transaksi', style: AppTextStyles.headlineSmall),
                    content: Text('Yakin ingin menghapus "${tx.title}"?',
                        style: AppTextStyles.bodyMedium),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Batal',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.textSecondary)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Hapus',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.danger)),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) {
                provider.deleteTransaction(tx.id!, uid);
              },
              child: TransactionTile(transaction: tx),
            );
          },
        );
      },
    );
  }
}
