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
  int selectedIndex = 0;

  double totalIncome = 0.0;

  double totalExpenses = 0.0;

  double totalReceivable = 0.0;

  double totalPayable = 0.0;

  List<Map<String, dynamic>> recentTransactions = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadDashboardData();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),

      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: Colors.transparent,

        elevation: 0,

        titleSpacing: 20,

        title: Row(
          children: [
            Container(
              width: 42,

              height: 42,

              padding: const EdgeInsets.all(5),

              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),

                shape: BoxShape.circle,
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
                    color: Color(0xFF1B5E20),

                    fontSize: 16,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  'Garden Accounts',

                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: _refreshDashboard,

            icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),

            tooltip: 'Refresh',
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF2E7D32),

          onRefresh: _refreshDashboard,

          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),

                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),

                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 390),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            greeting,

                            style: TextStyle(
                              color: Colors.grey.shade600,

                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Welcome back, ${widget.ownerName} 👋',

                            style: const TextStyle(
                              color: Color(0xFF1B5E20),

                              fontSize: 24,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 24),

                          _buildBalanceCard(),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Total Income',

                                  amount: totalIncome,

                                  icon: Icons.arrow_downward,

                                  iconColor: const Color(0xFF2E7D32),

                                  backgroundColor: const Color(0xFFE8F5E9),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Total Expenses',

                                  amount: totalExpenses,

                                  icon: Icons.arrow_upward,

                                  iconColor: const Color(0xFFC62828),

                                  backgroundColor: const Color(0xFFFFEBEE),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            'Quick Actions',

                            style: TextStyle(
                              color: Color(0xFF26332A),

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

                                  color: const Color(0xFF2E7D32),

                                  onTap: _openIncomeScreen,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _buildQuickAction(
                                  title: 'Add Expense',

                                  icon: Icons.remove_circle_outline,

                                  color: const Color(0xFFC62828),

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

                                  color: const Color(0xFF2E7D32),

                                  onTap: _openCustomersScreen,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _buildQuickAction(
                                  title: 'Suppliers',

                                  icon: Icons.storefront_outlined,

                                  color: const Color(0xFFAD6800),

                                  onTap: _openSuppliersScreen,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text(
                                'Pending Payments',

                                style: TextStyle(
                                  color: Color(0xFF26332A),

                                  fontSize: 18,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              TextButton(
                                onPressed: _openCustomersScreen,

                                child: const Text(
                                  'View All',

                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),

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

                            color: const Color(0xFFE65100),

                            backgroundColor: const Color(0xFFFFF3E0),
                          ),

                          const SizedBox(height: 10),

                          _buildPendingCard(
                            title: 'Supplier Payments',

                            subtitle: 'Amount to pay',

                            amount: totalPayable,

                            icon: Icons.storefront_outlined,

                            color: const Color(0xFFAD6800),

                            backgroundColor: const Color(0xFFFFF8E1),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text(
                                'Recent Transactions',

                                style: TextStyle(
                                  color: Color(0xFF26332A),

                                  fontSize: 18,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              TextButton(
                                onPressed: _openLedgerScreen,

                                child: const Text(
                                  'View All',

                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),

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

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,

        backgroundColor: Colors.white,

        indicatorColor: const Color(0xFFE8F5E9),

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
            icon: Icon(Icons.home_outlined),

            selectedIcon: Icon(Icons.home, color: Color(0xFF2E7D32)),

            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),

            selectedIcon: Icon(Icons.menu_book, color: Color(0xFF2E7D32)),

            label: 'Ledger',
          ),

          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),

            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF2E7D32)),

            label: 'Reports',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),

            selectedIcon: Icon(Icons.person, color: Color(0xFF2E7D32)),

            label: 'Profile',
          ),
        ],
      ),
    );
  }

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
                  color: Colors.white.withValues(alpha: 0.15),

                  borderRadius: BorderRadius.circular(20),
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

                color: Colors.white70,

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

        border: Border.all(color: Colors.grey.shade100),
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

          Text(
            title,

            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),

          const SizedBox(height: 5),

          Text(
            '₹${amount.toStringAsFixed(0)}',

            style: const TextStyle(
              color: Color(0xFF26332A),

              fontSize: 20,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

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

          border: Border.all(color: Colors.grey.shade100),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

        border: Border.all(color: Colors.grey.shade100),
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
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,

                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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

  Widget _buildNoTransactions() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.grey.shade100),
      ),

      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,

            size: 48,

            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          const Text(
            'No transactions yet',

            style: TextStyle(
              fontSize: 15,

              fontWeight: FontWeight.bold,

              color: Color(0xFF26332A),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Add your first income or expense.',

            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildTransaction({
    required String title,

    required String subtitle,

    required double amount,

    required IconData icon,

    required bool isIncome,
  }) {
    final color = isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.grey.shade100),
      ),

      child: Row(
        children: [
          Container(
            width: 42,

            height: 42,

            decoration: BoxDecoration(
              color: isIncome
                  ? const Color(0xFFE8F5E9)
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
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
