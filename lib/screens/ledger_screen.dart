import 'package:flutter/material.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'All';

  final List<Map<String, dynamic>> transactions = [
    {
      'title': 'Plant Sale',
      'category': 'Plant Sales',
      'date': '06/10/2026',
      'payment': 'UPI',
      'amount': 2500.0,
      'isIncome': true,
    },
    {
      'title': 'Fertilizer',
      'category': 'Fertilizer',
      'date': '05/10/2026',
      'payment': 'Cash',
      'amount': 1200.0,
      'isIncome': false,
    },
    {
      'title': 'Plant Pots',
      'category': 'Pots & Containers',
      'date': '05/10/2026',
      'payment': 'UPI',
      'amount': 800.0,
      'isIncome': false,
    },
    {
      'title': 'Indoor Plants',
      'category': 'Plant Sales',
      'date': '04/10/2026',
      'payment': 'Cash',
      'amount': 3500.0,
      'isIncome': true,
    },
    {
      'title': 'Garden Maintenance',
      'category': 'Garden Maintenance',
      'date': '03/10/2026',
      'payment': 'Bank Transfer',
      'amount': 1500.0,
      'isIncome': false,
    },
    {
      'title': 'Landscaping Service',
      'category': 'Landscaping',
      'date': '02/10/2026',
      'payment': 'UPI',
      'amount': 5000.0,
      'isIncome': true,
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  double get totalIncome {
    return transactions
        .where((transaction) => transaction['isIncome'] == true)
        .fold(
          0.0,
          (sum, transaction) => sum + (transaction['amount'] as double),
        );
  }

  double get totalExpenses {
    return transactions
        .where((transaction) => transaction['isIncome'] == false)
        .fold(
          0.0,
          (sum, transaction) => sum + (transaction['amount'] as double),
        );
  }

  double get currentBalance {
    return totalIncome - totalExpenses;
  }

  List<Map<String, dynamic>> get filteredTransactions {
    final searchText = searchController.text.trim().toLowerCase();

    return transactions.where((transaction) {
      final matchesFilter =
          selectedFilter == 'All' ||
          (selectedFilter == 'Income' && transaction['isIncome'] == true) ||
          (selectedFilter == 'Expense' && transaction['isIncome'] == false);

      final matchesSearch =
          searchText.isEmpty ||
          transaction['title'].toString().toLowerCase().contains(searchText) ||
          transaction['category'].toString().toLowerCase().contains(
            searchText,
          ) ||
          transaction['payment'].toString().toLowerCase().contains(searchText);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),

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
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF1B5E20)),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(),

                  const SizedBox(height: 18),

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

                  const Text(
                    'Transactions',
                    style: TextStyle(
                      color: Color(0xFF26332A),
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

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
                        borderSide: BorderSide(color: Colors.grey.shade200),
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

                  if (filteredTransactions.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredTransactions.map(
                      (transaction) => _buildTransactionCard(transaction),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;

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

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final bool isIncome = transaction['isIncome'] == true;

    final Color color = isIncome
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);

    final Color backgroundColor = isIncome
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE);

    final IconData icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    final double amount = transaction['amount'] as double;

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
                  '${transaction['category']} • ${transaction['date']}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 3),

                Text(
                  transaction['payment'].toString(),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            '${isIncome ? '+' : '-'} ₹${amount.toStringAsFixed(0)}',
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

  Widget _buildEmptyState() {
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
          const Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26332A),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Try a different search or filter.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
