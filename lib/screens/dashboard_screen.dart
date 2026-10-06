import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import 'income_screen.dart';
import 'expense_screen.dart';
import 'ledger_screen.dart';
import 'customers_screen.dart';
import 'suppliers_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String ownerName;
  final String gardenName;

  const DashboardScreen({
    super.key,
    required this.ownerName,
    required this.gardenName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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

  int selectedIndex = 0;

  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  double totalReceivable = 0.0;
  double totalPayable = 0.0;

  List<Map<String, dynamic>> recentTransactions = [];

  bool isLoading = true;

  // ============================================================
  // INITIAL LOAD
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // ============================================================
  // LOAD DASHBOARD DATA
  // ============================================================

  Future<void> _loadDashboardData() async {
    try {
      final income = await DatabaseHelper.instance.getTotalIncome();

      final expenses = await DatabaseHelper.instance.getTotalExpenses();

      final customers = await DatabaseHelper.instance.getCustomers();

      final suppliers = await DatabaseHelper.instance.getSuppliers();

      final transactions = await DatabaseHelper.instance.getTransactions();

      double receivable = 0.0;

      for (final customer in customers) {
        receivable += (customer['receivable'] as num?)?.toDouble() ?? 0.0;
      }

      double payable = 0.0;

      for (final supplier in suppliers) {
        payable += (supplier['payable'] as num?)?.toDouble() ?? 0.0;
      }

      if (!mounted) return;

      setState(() {
        totalIncome = income;
        totalExpenses = expenses;
        totalReceivable = receivable;
        totalPayable = payable;
        recentTransactions = transactions.take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Failed to load dashboard data.');
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
  }

  double get currentBalance {
    return totalIncome - totalExpenses;
  }

  // ============================================================
  // GREETING
  // ============================================================

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning 🌱';
    } else if (hour < 17) {
      return 'Good afternoon ☀️';
    } else if (hour < 21) {
      return 'Good evening 🌿';
    } else {
      return 'Good night 🌙';
    }
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
        automaticallyImplyLeading: false,
        backgroundColor: cream,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,

        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: softCream,
                shape: BoxShape.circle,
                border: Border.all(
                  color: gold.withValues(alpha: 0.45),
                  width: 1,
                ),
              ),
              child: Image.asset(
                'assets/images/vijayagreen_icon.png',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.gardenName,
                  style: const TextStyle(
                    color: deepForest,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Garden Accounts',
                  style: TextStyle(color: mutedText, fontSize: 11),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: _refreshDashboard,
            icon: const Icon(Icons.refresh, color: mainGreen),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: RefreshIndicator(
          color: gold,
          backgroundColor: softCream,
          onRefresh: _refreshDashboard,
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: mainGreen))
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 390),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // GREETING
                          // ==================================================

                          Text(
                            greeting,
                            style: const TextStyle(
                              color: mutedText,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Welcome back, ${widget.ownerName} 👋',
                            style: const TextStyle(
                              color: deepForest,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // BALANCE CARD
                          // ==================================================
                          _buildBalanceCard(),

                          const SizedBox(height: 18),

                          // ==================================================
                          // INCOME / EXPENSE
                          // ==================================================
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Total Income',
                                  amount: totalIncome,
                                  icon: Icons.arrow_downward,
                                  iconColor: mainGreen,
                                  backgroundColor: const Color(0xFFE7EFE5),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Total Expenses',
                                  amount: totalExpenses,
                                  icon: Icons.arrow_upward,
                                  iconColor: errorRed,
                                  backgroundColor: const Color(0xFFFFEBEE),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // QUICK ACTIONS
                          // ==================================================
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              color: deepForest,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickAction(
                                  title: 'Add Income',
                                  icon: Icons.add_circle_outline,
                                  color: mainGreen,
                                  onTap: _openIncomeScreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickAction(
                                  title: 'Add Expense',
                                  icon: Icons.remove_circle_outline,
                                  color: errorRed,
                                  onTap: _openExpenseScreen,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickAction(
                                  title: 'Customers',
                                  icon: Icons.people_outline,
                                  color: mainGreen,
                                  onTap: _openCustomersScreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickAction(
                                  title: 'Suppliers',
                                  icon: Icons.storefront_outlined,
                                  color: olive,
                                  onTap: _openSuppliersScreen,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // PENDING PAYMENTS
                          // ==================================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pending Payments',
                                style: TextStyle(
                                  color: deepForest,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              TextButton(
                                onPressed: _showPendingPaymentsDialog,
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                    color: mainGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          _buildPendingCard(
                            title: 'Customer Payments',
                            subtitle: 'Amount to receive',
                            amount: totalReceivable,
                            icon: Icons.person_outline,
                            color: olive,
                            backgroundColor: const Color(0xFFF0F2DF),
                          ),

                          const SizedBox(height: 10),

                          _buildPendingCard(
                            title: 'Supplier Payments',
                            subtitle: 'Amount to pay',
                            amount: totalPayable,
                            icon: Icons.storefront_outlined,
                            color: gold,
                            backgroundColor: const Color(0xFFFFF8E1),
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // RECENT TRANSACTIONS
                          // ==================================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Transactions',
                                style: TextStyle(
                                  color: deepForest,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              TextButton(
                                onPressed: _openLedgerScreen,
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                    color: mainGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          if (recentTransactions.isEmpty)
                            _buildNoTransactions()
                          else
                            ...recentTransactions.map(
                              _buildDatabaseTransaction,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: softCream,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFE8E6D5),

        onDestinationSelected: (index) async {
          setState(() {
            selectedIndex = index;
          });

          if (index == 0) {
            await _refreshDashboard();
          } else if (index == 1) {
            await _openLedgerScreen();
          } else if (index == 2) {
            await _openReportsScreen();
          } else if (index == 3) {
            await _openProfileScreen();
          }

          if (!mounted) return;

          setState(() {
            selectedIndex = 0;
          });

          await _refreshDashboard();
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: mutedText),
            selectedIcon: Icon(Icons.home, color: mainGreen),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: mutedText),
            selectedIcon: Icon(Icons.menu_book, color: mainGreen),
            label: 'Ledger',
          ),

          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, color: mutedText),
            selectedIcon: Icon(Icons.bar_chart, color: mainGreen),
            label: 'Reports',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline, color: mutedText),
            selectedIcon: Icon(Icons.person, color: mainGreen),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Future<void> _openIncomeScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IncomeScreen()),
    );

    if (!mounted) return;

    await _loadDashboardData();
  }

  Future<void> _openExpenseScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExpenseScreen()),
    );

    if (!mounted) return;

    await _loadDashboardData();
  }

  Future<void> _openLedgerScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LedgerScreen()),
    );

    if (!mounted) return;

    await _loadDashboardData();
  }

  Future<void> _openReportsScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportsScreen()),
    );

    if (!mounted) return;

    await _loadDashboardData();
  }

  // ============================================================
  // PENDING PAYMENTS DIALOG
  // ============================================================

  Future<void> _showPendingPaymentsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: softCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: gold.withValues(alpha: 0.45), width: 1),
          ),
          title: const Text(
            'Pending Payments',
            style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPendingDialogItem(
                title: 'Customer Payments',
                subtitle: 'Amount to receive',
                amount: totalReceivable,
                icon: Icons.person_outline,
                color: olive,
                backgroundColor: const Color(0xFFF0F2DF),
              ),

              const SizedBox(height: 12),

              _buildPendingDialogItem(
                title: 'Supplier Payments',
                subtitle: 'Amount to pay',
                amount: totalPayable,
                icon: Icons.storefront_outlined,
                color: gold,
                backgroundColor: const Color(0xFFFFF8E1),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingDialogItem({
    required String title,
    required String subtitle,
    required double amount,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderGreen),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: deepForest,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: mutedText),
                ),
              ],
            ),
          ),

          Text(
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

  Future<void> _openCustomersScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomersScreen()),
    );

    if (!mounted) return;

    await _loadDashboardData();
  }

  Future<void> _openSuppliersScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SuppliersScreen()),
    );

    if (!mounted) return;

    await _loadDashboardData();
  }

  Future<void> _openProfileScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );

    if (!mounted) return;

    await _loadDashboardData();
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
        border: Border.all(color: gold.withValues(alpha: 0.75), width: 1),
        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: gold.withValues(alpha: 0.45),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'All Transactions',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '₹${currentBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                currentBalance >= 0 ? Icons.trending_up : Icons.trending_down,
                color: gold,
                size: 18,
              ),

              const SizedBox(width: 5),

              Text(
                currentBalance >= 0
                    ? 'Your garden is growing'
                    : 'Expenses are higher than income',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
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
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGreen),
        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),

          const SizedBox(height: 12),

          Text(title, style: const TextStyle(color: mutedText, fontSize: 12)),

          const SizedBox(height: 5),

          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: deepForest,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTION
  // ============================================================

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderGreen),
          boxShadow: [
            BoxShadow(
              color: deepForest.withValues(alpha: 0.025),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 25),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: deepForest,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PENDING CARD
  // ============================================================

  Widget _buildPendingCard({
    required String title,
    required String subtitle,
    required double amount,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGreen),
        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.025),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: deepForest,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: mutedText),
                ),
              ],
            ),
          ),

          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATABASE TRANSACTION
  // ============================================================

  Widget _buildDatabaseTransaction(Map<String, dynamic> transaction) {
    final String type = transaction['type']?.toString() ?? '';

    final bool isIncome = type == 'income';

    final double amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;

    final String category =
        transaction['category']?.toString() ?? 'Transaction';

    final String description = transaction['description']?.toString() ?? '';

    final String partyName = transaction['partyName']?.toString() ?? '';

    final String paymentMethod = transaction['paymentMethod']?.toString() ?? '';

    final String title = description.isNotEmpty ? description : category;

    final String subtitle = _buildTransactionSubtitle(
      transaction,
      partyName,
      paymentMethod,
    );

    return _buildTransaction(
      title: title,
      subtitle: subtitle,
      amount: amount,
      icon: _getTransactionIcon(category),
      isIncome: isIncome,
    );
  }

  String _buildTransactionSubtitle(
    Map<String, dynamic> transaction,
    String partyName,
    String paymentMethod,
  ) {
    String dateText = '';

    final dateValue = transaction['date'];

    if (dateValue != null) {
      try {
        final date = DateTime.parse(dateValue.toString());

        dateText =
            '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';
      } catch (_) {
        dateText = '';
      }
    }

    final List<String> parts = [];

    if (dateText.isNotEmpty) {
      parts.add(dateText);
    }

    if (paymentMethod.isNotEmpty) {
      parts.add(paymentMethod);
    }

    if (partyName.isNotEmpty && partyName != 'Not provided') {
      parts.add(partyName);
    }

    if (parts.isEmpty) {
      return 'Transaction';
    }

    return parts.join(' • ');
  }

  // ============================================================
  // TRANSACTION ICON
  // ============================================================

  IconData _getTransactionIcon(String category) {
    final value = category.toLowerCase();

    if (value.contains('plant') || value.contains('seedling')) {
      return Icons.local_florist_outlined;
    }

    if (value.contains('fertilizer')) {
      return Icons.science_outlined;
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

    if (value.contains('maintenance')) {
      return Icons.build_outlined;
    }

    if (value.contains('sale')) {
      return Icons.local_florist_outlined;
    }

    return Icons.receipt_long_outlined;
  }

  // ============================================================
  // NO TRANSACTIONS
  // ============================================================

  Widget _buildNoTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGreen),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: olive.withValues(alpha: 0.55),
          ),

          const SizedBox(height: 12),

          const Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: deepForest,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Add your first income or expense.',
            style: TextStyle(fontSize: 12, color: mutedText),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTION CARD
  // ============================================================

  Widget _buildTransaction({
    required String title,
    required String subtitle,
    required double amount,
    required IconData icon,
    required bool isIncome,
  }) {
    final color = isIncome ? mainGreen : errorRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGreen),
        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.025),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isIncome
                  ? const Color(0xFFE7EFE5)
                  : const Color(0xFFFFEBEE),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: deepForest,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: mutedText),
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
}
