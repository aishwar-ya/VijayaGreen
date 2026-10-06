import 'package:flutter/material.dart';

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

  // ============================================================
  // DEMO DATA
  // ============================================================

  final double totalIncome = 25500;
  final double totalExpenses = 9200;

  double get currentBalance => totalIncome - totalExpenses;

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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,

        title: Row(
          children: [
            // ======================================================
            // VIJAYAGREEN APP ICON
            // ======================================================

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

            // ======================================================
            // GARDEN NAME
            // ======================================================
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
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====================================================
              // GREETING
              // ====================================================

              Text(
                greeting,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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

              // ====================================================
              // BALANCE CARD
              // ====================================================
              _buildBalanceCard(),

              const SizedBox(height: 18),

              // ====================================================
              // INCOME / EXPENSE SUMMARY
              // ====================================================
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

              // ====================================================
              // QUICK ACTIONS
              // ====================================================
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

              // ====================================================
              // PENDING PAYMENTS
              // ====================================================
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
                    onPressed: () {},
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
                amount: 4500,
                icon: Icons.person_outline,
                color: const Color(0xFFE65100),
                backgroundColor: const Color(0xFFFFF3E0),
              ),

              const SizedBox(height: 10),

              _buildPendingCard(
                title: 'Supplier Payments',
                subtitle: 'Amount to pay',
                amount: 2200,
                icon: Icons.storefront_outlined,
                color: const Color(0xFFAD6800),
                backgroundColor: const Color(0xFFFFF8E1),
              ),

              const SizedBox(height: 28),

              // ====================================================
              // RECENT TRANSACTIONS
              // ====================================================
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
                    onPressed: () {},
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

              _buildTransaction(
                title: 'Plant Sale',
                subtitle: 'Today • UPI',
                amount: 2500,
                icon: Icons.local_florist_outlined,
                isIncome: true,
              ),

              _buildTransaction(
                title: 'Fertilizer',
                subtitle: 'Yesterday • Cash',
                amount: 1200,
                icon: Icons.science_outlined,
                isIncome: false,
              ),

              _buildTransaction(
                title: 'Plant Pots',
                subtitle: 'Yesterday • UPI',
                amount: 800,
                icon: Icons.inventory_2_outlined,
                isIncome: false,
              ),
            ],
          ),
        ),
      ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8F5E9),

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });

          if (index == 0) {
            return;
          } else if (index == 1) {
            _openLedgerScreen();
          } else if (index == 2) {
            _openIncomeScreen();
          } else if (index == 3) {
            _openReportsScreen();
          } else if (index == 4) {
            _openProfileScreen();
          }
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
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: Color(0xFF2E7D32)),
            label: 'Add',
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

  // ============================================================
  // NAVIGATION METHODS
  // ============================================================

  void _openIncomeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IncomeScreen()),
    );
  }

  void _openExpenseScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExpenseScreen()),
    );
  }

  void _openLedgerScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LedgerScreen()),
    );
  }

  void _openReportsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportsScreen()),
    );
  }

  void _openCustomersScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomersScreen()),
    );
  }

  void _openSuppliersScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SuppliersScreen()),
    );
  }

  void _openProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
                  'This Month',
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

          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white70, size: 18),
              SizedBox(width: 5),
              Text(
                'Your garden is growing',
                style: TextStyle(color: Colors.white70, fontSize: 12),
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

  // ============================================================
  // PENDING PAYMENT CARD
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
