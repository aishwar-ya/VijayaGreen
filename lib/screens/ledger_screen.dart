import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  // ============================================================
  // GOLDEN GREEN THEME
  // ============================================================

  static const Color deepForest = Color(0xFF123524);
  static const Color mainGreen = Color(0xFF24543A);
  static const Color gold = Color(0xFFD4A72C);
  static const Color olive = Color(0xFF7B8F3A);
  static const Color cream = Color(0xFFF7F3E7);
  static const Color softCream = Color(0xFFFCFAF3);
  static const Color mutedText = Color(0xFF687267);
  static const Color borderGreen = Color(0xFFD7E2D5);
  static const Color errorRed = Color(0xFFC62828);

  // ============================================================
  // STATE
  // ============================================================

  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'Everything';

  List<Map<String, dynamic>> transactions = [];

  bool isLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD TRANSACTIONS
  // ============================================================

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

      _showMessage('Could not load transactions.');
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
  // TOTAL MONEY RECEIVED
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
  // TOTAL MONEY SPENT
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
  // AVAILABLE BALANCE
  // ============================================================

  double get currentBalance {
    return totalIncome - totalExpenses;
  }

  // ============================================================
  // FILTERED TRANSACTIONS
  // ============================================================

  List<Map<String, dynamic>> get filteredTransactions {
    final String searchText = searchController.text.trim().toLowerCase();

    return transactions.where((transaction) {
      final bool matchesFilter =
          selectedFilter == 'Everything' ||
          (selectedFilter == 'Money In' && transaction['isIncome'] == true) ||
          (selectedFilter == 'Money Out' && transaction['isIncome'] == false);

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
  // DELETE TRANSACTION
  // ============================================================

  Future<void> _deleteTransaction(Map<String, dynamic> transaction) async {
    final bool isIncome = transaction['isIncome'] == true;

    final double amount = (transaction['amount'] as num).toDouble();

    final String transactionType = isIncome ? 'money received' : 'money spent';

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: softCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Transaction?',
            style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this '
            '$transactionType of ₹${amount.toStringAsFixed(2)}?',
            style: const TextStyle(color: mutedText, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel', style: TextStyle(color: mutedText)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final int transactionId = (transaction['id'] as num).toInt();

      await DatabaseHelper.instance.deleteTransaction(transactionId);

      if (!mounted) return;

      await _loadTransactions();

      if (!mounted) return;

      _showMessage('Transaction deleted successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Could not delete transaction.');
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: deepForest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: const Text(
          'Ledger',
          style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: _refreshTransactions,
            icon: const Icon(Icons.refresh, color: deepForest),
            tooltip: 'Refresh',
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : RefreshIndicator(
                color: gold,
                backgroundColor: softCream,
                onRefresh: _refreshTransactions,

                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),

                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),

                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 390),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // ======================================
                          // BALANCE
                          // ======================================

                          _buildBalanceCard(),

                          const SizedBox(height: 18),

                          // ======================================
                          // MONEY IN / MONEY OUT
                          // ======================================
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Money Received',
                                  amount: totalIncome,
                                  icon: Icons.south_west_rounded,
                                  color: mainGreen,
                                  backgroundColor: const Color(0xFFE8F0E8),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Money Spent',
                                  amount: totalExpenses,
                                  icon: Icons.north_east_rounded,
                                  color: errorRed,
                                  backgroundColor: const Color(0xFFFFEBEE),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ======================================
                          // TRANSACTIONS HEADING
                          // ======================================
                          const Text(
                            'Your Transactions',
                            style: TextStyle(
                              color: deepForest,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'See all money received and money spent.',
                            style: TextStyle(color: mutedText, fontSize: 12),
                          ),

                          const SizedBox(height: 14),

                          // ======================================
                          // SEARCH
                          // ======================================
                          TextField(
                            controller: searchController,

                            onChanged: (_) {
                              setState(() {});
                            },

                            decoration: InputDecoration(
                              hintText: 'Search by person, category or payment',
                              hintStyle: const TextStyle(
                                color: mutedText,
                                fontSize: 12,
                              ),

                              prefixIcon: const Icon(
                                Icons.search,
                                color: olive,
                              ),

                              suffixIcon: searchController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        searchController.clear();

                                        setState(() {});
                                      },
                                      icon: const Icon(
                                        Icons.clear,
                                        color: mutedText,
                                      ),
                                    )
                                  : null,

                              filled: true,
                              fillColor: Colors.white,

                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: borderGreen,
                                ),
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: borderGreen,
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: gold,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ======================================
                          // FILTERS
                          // ======================================
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,

                            child: Row(
                              children: [
                                _buildFilterChip('Everything'),

                                const SizedBox(width: 8),

                                _buildFilterChip('Money In'),

                                const SizedBox(width: 8),

                                _buildFilterChip('Money Out'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ======================================
                          // TRANSACTION LIST
                          // ======================================
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
          colors: [deepForest, mainGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: gold, width: 1),

        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'AVAILABLE BALANCE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            currentBalance < 0
                ? '-₹${currentBalance.abs().toStringAsFixed(2)}'
                : '₹${currentBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                currentBalance >= 0
                    ? Icons.account_balance_wallet_outlined
                    : Icons.warning_amber_rounded,
                color: gold,
                size: 18,
              ),

              const SizedBox(width: 7),

              Text(
                currentBalance >= 0
                    ? 'Money received minus money spent'
                    : 'Expenses are higher than income',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
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
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: borderGreen),

        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),

                child: Icon(icon, color: color, size: 20),
              ),

              const Spacer(),

              Icon(
                Icons.chevron_right,
                color: mutedText.withValues(alpha: 0.5),
                size: 18,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: deepForest,
              fontSize: 18,
              fontWeight: FontWeight.bold,
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

      selectedColor: deepForest,
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,

      labelStyle: TextStyle(
        color: isSelected ? Colors.white : deepForest,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),

      side: BorderSide(color: isSelected ? gold : borderGreen),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // ============================================================
  // TRANSACTION CARD
  // ============================================================

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final bool isIncome = transaction['isIncome'] == true;

    final Color color = isIncome ? mainGreen : errorRed;

    final Color backgroundColor = isIncome
        ? const Color(0xFFE8F0E8)
        : const Color(0xFFFFEBEE);

    final IconData icon = isIncome
        ? Icons.south_west_rounded
        : Icons.north_east_rounded;

    final double amount = (transaction['amount'] as num).toDouble();

    final String partyName = transaction['partyName'].toString().trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(17),

        border: Border.all(color: borderGreen),

        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.035),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ================================================
              // ICON
              // ================================================

              Container(
                width: 46,
                height: 46,

                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),

                child: Icon(icon, color: color, size: 22),
              ),

              const SizedBox(width: 12),

              // ================================================
              // DETAILS
              // ================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      transaction['title'].toString(),

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: deepForest,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      transaction['category'].toString(),

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(fontSize: 11, color: mutedText),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      partyName.isNotEmpty
                          ? '${transaction['payment']} • $partyName'
                          : transaction['payment'].toString(),

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(fontSize: 11, color: mutedText),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      transaction['date'].toString(),

                      style: TextStyle(
                        fontSize: 10,
                        color: mutedText.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ================================================
              // AMOUNT + MENU
              // ================================================
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,

                    icon: const Icon(
                      Icons.more_vert,
                      color: mutedText,
                      size: 21,
                    ),

                    color: softCream,

                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteTransaction(transaction);
                      }
                    },

                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'delete',

                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: errorRed,
                              size: 20,
                            ),

                            const SizedBox(width: 10),

                            const Text(
                              'Delete',
                              style: TextStyle(
                                color: errorRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Text(
                    '${isIncome ? '+' : '-'}₹${amount.toStringAsFixed(0)}',

                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    isIncome ? 'RECEIVED' : 'SPENT',

                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ],
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

        border: Border.all(color: borderGreen),
      ),

      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 55, color: olive),

          const SizedBox(height: 14),

          Text(
            hasTransactions ? 'No transactions found' : 'No transactions yet',

            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: deepForest,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            hasTransactions
                ? 'Try another search or filter.'
                : 'Add money received or money spent '
                      'to see it here.',

            textAlign: TextAlign.center,

            style: const TextStyle(fontSize: 12, color: mutedText),
          ),
        ],
      ),
    );
  }
}
