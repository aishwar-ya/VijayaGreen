import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  final double totalIncome = 11000;
  final double totalExpenses = 3500;

  double get currentBalance => totalIncome - totalExpenses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),
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
                    'Vijaya Garden • October 2026',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),

                  const SizedBox(height: 20),

                  _buildBalanceCard(),

                  const SizedBox(height: 18),

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

                  const Text(
                    'Income by Category',
                    style: TextStyle(
                      color: Color(0xFF26332A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildCategoryCard(
                    title: 'Plant Sales',
                    amount: 6000,
                    percentage: 55,
                    icon: Icons.local_florist_outlined,
                    color: const Color(0xFF2E7D32),
                    backgroundColor: const Color(0xFFE8F5E9),
                  ),

                  _buildCategoryCard(
                    title: 'Landscaping',
                    amount: 3000,
                    percentage: 27,
                    icon: Icons.grass_outlined,
                    color: const Color(0xFF388E3C),
                    backgroundColor: const Color(0xFFE8F5E9),
                  ),

                  _buildCategoryCard(
                    title: 'Indoor Plants',
                    amount: 2000,
                    percentage: 18,
                    icon: Icons.eco_outlined,
                    color: const Color(0xFF558B2F),
                    backgroundColor: const Color(0xFFF1F8E9),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Expenses by Category',
                    style: TextStyle(
                      color: Color(0xFF26332A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildCategoryCard(
                    title: 'Fertilizer',
                    amount: 1200,
                    percentage: 34,
                    icon: Icons.science_outlined,
                    color: const Color(0xFFC62828),
                    backgroundColor: const Color(0xFFFFEBEE),
                  ),

                  _buildCategoryCard(
                    title: 'Garden Maintenance',
                    amount: 1500,
                    percentage: 43,
                    icon: Icons.handyman_outlined,
                    color: const Color(0xFFE65100),
                    backgroundColor: const Color(0xFFFFF3E0),
                  ),

                  _buildCategoryCard(
                    title: 'Pots & Containers',
                    amount: 800,
                    percentage: 23,
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFFAD6800),
                    backgroundColor: const Color(0xFFFFF8E1),
                  ),

                  const SizedBox(height: 22),

                  _buildProfitCard(),
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
          const Text(
            'Income minus expenses',
            style: TextStyle(color: Colors.white70, fontSize: 11),
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
                    value: percentage / 100,
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

  Widget _buildProfitCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFC8E6C9)),
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
            child: const Icon(
              Icons.trending_up,
              color: Color(0xFF2E7D32),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Net Result',
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${currentBalance.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Positive balance this month',
                  style: TextStyle(color: Color(0xFF558B2F), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
