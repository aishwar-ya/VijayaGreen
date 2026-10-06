import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // ============================================================
  // DATABASE DATA
  // ============================================================

  double totalIncome = 0.0;
  double totalExpenses = 0.0;

  List<Map<String, dynamic>> incomeCategories = [];
  List<Map<String, dynamic>> expenseCategories = [];

  bool isLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  // ============================================================
  // LOAD REPORT DATA
  // ============================================================

  Future<void> _loadReportData() async {
    try {
      final income = await DatabaseHelper.instance.getTotalIncome();

      final expenses = await DatabaseHelper.instance.getTotalExpenses();

      final transactions = await DatabaseHelper.instance.getTransactions();

      final incomeMap = <String, double>{};
      final expenseMap = <String, double>{};

      for (final transaction in transactions) {
        final type = transaction['type']?.toString() ?? '';

        final category = transaction['category']?.toString() ?? 'Other';

        final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;

        if (amount <= 0) {
          continue;
        }

        if (type == 'income') {
          incomeMap[category] = (incomeMap[category] ?? 0.0) + amount;
        } else if (type == 'expense') {
          expenseMap[category] = (expenseMap[category] ?? 0.0) + amount;
        }
      }

      final incomeList = _buildCategoryList(incomeMap, income);

      final expenseList = _buildCategoryList(expenseMap, expenses);

      if (!mounted) return;

      setState(() {
        totalIncome = income;
        totalExpenses = expenses;
        incomeCategories = incomeList;
        expenseCategories = expenseList;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Failed to load report data.');
    }
  }

  // ============================================================
  // BUILD CATEGORY LIST
  // ============================================================

  List<Map<String, dynamic>> _buildCategoryList(
    Map<String, double> categoryMap,
    double total,
  ) {
    final list = categoryMap.entries.map((entry) {
      final percentage = total > 0 ? ((entry.value / total) * 100).round() : 0;

      return {
        'title': entry.key,
        'amount': entry.value,
        'percentage': percentage,
      };
    }).toList();

    list.sort(
      (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
    );

    return list;
  }

  // ============================================================
  // CURRENT BALANCE
  // ============================================================

  double get currentBalance {
    return totalIncome - totalExpenses;
  }

  // ============================================================
  // CURRENT MONTH
  // ============================================================

  String get currentMonthYear {
    final now = DateTime.now();

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[now.month - 1]} ${now.year}';
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF26332A),
      ),
    );
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _getCategoryIcon(String category, bool isIncome) {
    final value = category.toLowerCase();

    if (value.contains('plant') || value.contains('seedling')) {
      return Icons.local_florist_outlined;
    }

    if (value.contains('landscap')) {
      return Icons.grass_outlined;
    }

    if (value.contains('indoor')) {
      return Icons.eco_outlined;
    }

    if (value.contains('fertilizer')) {
      return Icons.science_outlined;
    }

    if (value.contains('maintenance')) {
      return Icons.handyman_outlined;
    }

    if (value.contains('pot') || value.contains('container')) {
      return Icons.inventory_2_outlined;
    }

    if (value.contains('transport')) {
      return Icons.local_shipping_outlined;
    }

    if (value.contains('electricity')) {
      return Icons.bolt_outlined;
    }

    if (value.contains('labour') || value.contains('labor')) {
      return Icons.people_outline;
    }

    if (value.contains('water')) {
      return Icons.water_drop_outlined;
    }

    if (isIncome) {
      return Icons.trending_up;
    }

    return Icons.receipt_long_outlined;
  }

  // ============================================================
  // CATEGORY COLORS
  // ============================================================

  Color _getCategoryColor(int index, bool isIncome) {
    if (isIncome) {
      const colors = [
        Color(0xFF2E7D32),
        Color(0xFF388E3C),
        Color(0xFF558B2F),
        Color(0xFF689F38),
        Color(0xFF1B5E20),
      ];

      return colors[index % colors.length];
    }

    const colors = [
      Color(0xFFC62828),
      Color(0xFFE65100),
      Color(0xFFAD6800),
      Color(0xFF8D6E63),
      Color(0xFF6D4C41),
    ];

    return colors[index % colors.length];
  }

  // ============================================================
  // CATEGORY BACKGROUND COLORS
  // ============================================================

  Color _getCategoryBackground(int index, bool isIncome) {
    if (isIncome) {
      const colors = [
        Color(0xFFE8F5E9),
        Color(0xFFE8F5E9),
        Color(0xFFF1F8E9),
        Color(0xFFF1F8E9),
        Color(0xFFE8F5E9),
      ];

      return colors[index % colors.length];
    }

    const colors = [
      Color(0xFFFFEBEE),
      Color(0xFFFFF3E0),
      Color(0xFFFFF8E1),
      Color(0xFFFBE9E7),
      Color(0xFFEFEBE9),
    ];

    return colors[index % colors.length];
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
        ),

        title: const Text(
          'Reports',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _loadReportData,
            icon: const Icon(Icons.refresh, color: Color(0xFF1B5E20)),
            tooltip: 'Refresh',
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              )
            : RefreshIndicator(
                color: const Color(0xFF2E7D32),
                onRefresh: _loadReportData,

                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),

                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),

                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // ==================================================
                          // TITLE
                          // ==================================================

                          const Text(
                            'Financial Overview',
                            style: TextStyle(
                              color: Color(0xFF26332A),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Vijaya Garden • $currentMonthYear',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // BALANCE
                          // ==================================================
                          _buildBalanceCard(),

                          const SizedBox(height: 18),

                          // ==================================================
                          // SUMMARY
                          // ==================================================
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Total Income',
                                  amount: totalIncome,
                                  icon: Icons.trending_up,
                                  color: const Color(0xFF2E7D32),
                                  backgroundColor: const Color(0xFFE8F5E9),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Total Expenses',
                                  amount: totalExpenses,
                                  icon: Icons.trending_down,
                                  color: const Color(0xFFC62828),
                                  backgroundColor: const Color(0xFFFFEBEE),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // INCOME BY CATEGORY
                          // ==================================================
                          const Text(
                            'Income by Category',
                            style: TextStyle(
                              color: Color(0xFF26332A),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          if (incomeCategories.isEmpty)
                            _buildEmptyCategoryState('No income data yet.')
                          else
                            ...incomeCategories.asMap().entries.map((entry) {
                              final index = entry.key;

                              final category = entry.value;

                              return _buildCategoryCard(
                                title: category['title'].toString(),

                                amount: category['amount'] as double,

                                percentage: category['percentage'] as int,

                                icon: _getCategoryIcon(
                                  category['title'].toString(),
                                  true,
                                ),

                                color: _getCategoryColor(index, true),

                                backgroundColor: _getCategoryBackground(
                                  index,
                                  true,
                                ),
                              );
                            }),

                          const SizedBox(height: 12),

                          // ==================================================
                          // EXPENSES BY CATEGORY
                          // ==================================================
                          const Text(
                            'Expenses by Category',
                            style: TextStyle(
                              color: Color(0xFF26332A),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          if (expenseCategories.isEmpty)
                            _buildEmptyCategoryState('No expense data yet.')
                          else
                            ...expenseCategories.asMap().entries.map((entry) {
                              final index = entry.key;

                              final category = entry.value;

                              return _buildCategoryCard(
                                title: category['title'].toString(),

                                amount: category['amount'] as double,

                                percentage: category['percentage'] as int,

                                icon: _getCategoryIcon(
                                  category['title'].toString(),
                                  false,
                                ),

                                color: _getCategoryColor(index, false),

                                backgroundColor: _getCategoryBackground(
                                  index,
                                  false,
                                ),
                              );
                            }),

                          const SizedBox(height: 22),

                          // ==================================================
                          // PROFIT / LOSS
                          // ==================================================
                          _buildProfitCard(),
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
    final bool isPositive = currentBalance >= 0;

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
            color: const Color(0xFF2E7D32).withValues(alpha: 0.18),

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
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 8),

          Text(
            '₹${currentBalance.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isPositive
                ? 'Income minus expenses'
                : 'Expenses are higher than income',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
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
  // CATEGORY CARD
  // ============================================================

  Widget _buildCategoryCard({
    required String title,
    required double amount,
    required int percentage,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.grey.shade100),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,

                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),

                child: Icon(icon, color: color, size: 20),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: LinearProgressIndicator(
                    value: (percentage / 100).clamp(0.0, 1.0),

                    minHeight: 7,

                    backgroundColor: Colors.grey.shade100,

                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                '$percentage%',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY CATEGORY STATE
  // ============================================================

  Widget _buildEmptyCategoryState(String message) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),

      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.grey.shade100),
      ),

      child: Column(
        children: [
          Icon(Icons.bar_chart_outlined, size: 40, color: Colors.grey.shade400),

          const SizedBox(height: 8),

          Text(
            message,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFIT / LOSS CARD
  // ============================================================

  Widget _buildProfitCard() {
    final bool isPositive = currentBalance >= 0;

    final Color mainColor = isPositive
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);

    final Color lightColor = isPositive
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE);

    final Color borderColor = isPositive
        ? const Color(0xFFC8E6C9)
        : const Color(0xFFFFCDD2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: lightColor,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: borderColor),
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),

            child: Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: mainColor,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Net Result',
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFC62828),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '₹${currentBalance.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  isPositive ? 'Positive balance' : 'Negative balance',
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF558B2F)
                        : const Color(0xFFC62828),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
