import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'All';

  List<Map<String, dynamic>> transactions = [];

  bool isLoading = true;

  // ============================================================
  // LOAD TRANSACTIONS FROM SQLITE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final data = await DatabaseHelper.instance.getTransactions();

      if (!mounted) return;

      setState(() {
        transactions = data.map((transaction) {
          final bool isIncome = transaction['type'] == 'income';

          return {
            'id': transaction['id'],
            'title': _getTransactionTitle(transaction),
            'category': transaction['category'] ?? 'Other',
            'date': _formatDate(transaction['date']),
            'payment': transaction['paymentMethod'] ?? 'Cash',
            'amount': (transaction['amount'] as num).toDouble(),
            'isIncome': isIncome,
            'partyName': transaction['partyName'] ?? '',
            'description': transaction['description'] ?? '',
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Failed to load transactions.');
    }
  }

  // ============================================================
  // TRANSACTION TITLE
  // ============================================================

  String _getTransactionTitle(Map<String, dynamic> transaction) {
    final String description =
        transaction['description']?.toString().trim() ?? '';

    final String category =
        transaction['category']?.toString().trim() ?? 'Other';

    final String partyName = transaction['partyName']?.toString().trim() ?? '';

    if (description.isNotEmpty) {
      return description;
    }

    if (partyName.isNotEmpty) {
      return partyName;
    }

    return category;
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) {
      return '';
    }

    try {
      final DateTime date = DateTime.parse(dateValue.toString());

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (e) {
      return dateValue.toString();
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshTransactions() async {
    setState(() {
      isLoading = true;
    });

    await _loadTransactions();
  }

  // ============================================================
  // TOTAL INCOME
  // ============================================================

  double get totalIncome {
    return transactions
        .where((transaction) => transaction['isIncome'] == true)
        .fold(
          0.0,
          (sum, transaction) => sum + (transaction['amount'] as num).toDouble(),
        );
  }

  // ============================================================
  // TOTAL EXPENSES
  // ============================================================

  double get totalExpenses {
    return transactions
        .where((transaction) => transaction['isIncome'] == false)
        .fold(
          0.0,
          (sum, transaction) => sum + (transaction['amount'] as num).toDouble(),
        );
  }

  // ============================================================
  // CURRENT BALANCE
  // ============================================================

  double get currentBalance {
    return totalIncome - totalExpenses;
  }

  // ============================================================
  // FILTERED TRANSACTIONS
  // ============================================================

  List<Map<String, dynamic>> get filteredTransactions {
    final searchText = searchController.text.trim().toLowerCase();

    return transactions.where((transaction) {
      final bool matchesFilter =
          selectedFilter == 'All' ||
          (selectedFilter == 'Income' && transaction['isIncome'] == true) ||
          (selectedFilter == 'Expense' && transaction['isIncome'] == false);

      final bool matchesSearch =
          searchText.isEmpty ||
          transaction['title'].toString().toLowerCase().contains(searchText) ||
          transaction['category'].toString().toLowerCase().contains(
            searchText,
          ) ||
          transaction['payment'].toString().toLowerCase().contains(
            searchText,
          ) ||
          transaction['partyName'].toString().toLowerCase().contains(
            searchText,
          ) ||
          transaction['description'].toString().toLowerCase().contains(
            searchText,
          );

      return matchesFilter && matchesSearch;
    }).toList();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF26332A),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ledger',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshTransactions,
            icon: const Icon(Icons.refresh, color: Color(0xFF1B5E20)),
            tooltip: 'Refresh',
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              )
            : RefreshIndicator(
                color: const Color(0xFF2E7D32),
                onRefresh: _refreshTransactions,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // =================================================
                          // BALANCE CARD
                          // =================================================

                          _buildBalanceCard(),

                          const SizedBox(height: 18),

                          // =================================================
                          // SUMMARY CARDS
                          // =================================================
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Income',
                                  amount: totalIncome,
                                  icon: Icons.arrow_downward,
                                  color: const Color(0xFF2E7D32),
                                  backgroundColor: const Color(0xFFE8F5E9),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Expenses',
                                  amount: totalExpenses,
                                  icon: Icons.arrow_upward,
                                  color: const Color(0xFFC62828),
                                  backgroundColor: const Color(0xFFFFEBEE),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // =================================================
                          // TRANSACTIONS TITLE
                          // =================================================
                          const Text(
                            'Transactions',
                            style: TextStyle(
                              color: Color(0xFF26332A),
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // =================================================
                          // SEARCH
                          // =================================================
                          TextField(
                            controller: searchController,
                            onChanged: (_) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: 'Search transactions',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF2E7D32),
                              ),
                              suffixIcon: searchController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        searchController.clear();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.clear),
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2E7D32),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // =================================================
                          // FILTERS
                          // =================================================
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('All'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Income'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Expense'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // =================================================
                          // TRANSACTIONS
                          // =================================================
                          if (filteredTransactions.isEmpty)
                            _buildEmptyState()
                          else
                            ...filteredTransactions.map(
                              (transaction) =>
                                  _buildTransactionCard(transaction),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // ============================================================
  // BALANCE CARD
  // ============================================================

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 8),

          Text(
            '₹${currentBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Based on all recorded transactions',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 21),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                const SizedBox(height: 4),

                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF26332A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER CHIP
  // ============================================================

  Widget _buildFilterChip(String filter) {
    final bool isSelected = selectedFilter == filter;

    return ChoiceChip(
      label: Text(filter),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          selectedFilter = filter;
        });
      },
      selectedColor: const Color(0xFF2E7D32),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF26332A),
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade200,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // ============================================================
  // TRANSACTION CARD
  // ============================================================

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final bool isIncome = transaction['isIncome'] == true;

    final Color color = isIncome
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);

    final Color backgroundColor = isIncome
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE);

    final IconData icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    final double amount = (transaction['amount'] as num).toDouble();

    final String partyName = transaction['partyName'].toString().trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // ========================================================
          // ICON
          // ========================================================

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),

          const SizedBox(width: 13),

          // ========================================================
          // DETAILS
          // ========================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'].toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${transaction['category']} • '
                  '${transaction['date']}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 3),

                Text(
                  partyName.isNotEmpty
                      ? '${transaction['payment']} • $partyName'
                      : transaction['payment'].toString(),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ========================================================
          // AMOUNT
          // ========================================================
          Text(
            '${isIncome ? '+' : '-'} '
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final bool hasTransactions = transactions.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 55,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 14),

          Text(
            hasTransactions ? 'No transactions found' : 'No transactions yet',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26332A),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            hasTransactions
                ? 'Try a different search or filter.'
                : 'Add an income or expense to see it here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
