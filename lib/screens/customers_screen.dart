import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
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

  List<Map<String, dynamic>> customers = [];

  bool isLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  // ============================================================
  // LOAD CUSTOMERS
  // ============================================================

  Future<void> _loadCustomers() async {
    try {
      final data = await DatabaseHelper.instance.getCustomers();

      if (!mounted) return;

      setState(() {
        customers = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Failed to load customers.');
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshCustomers() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    await _loadCustomers();
  }

  // ============================================================
  // FILTERED CUSTOMERS
  // ============================================================

  List<Map<String, dynamic>> get filteredCustomers {
    final search = searchController.text.trim().toLowerCase();

    if (search.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      final name = customer['name']?.toString().toLowerCase() ?? '';

      final phone = customer['phone']?.toString().toLowerCase() ?? '';

      return name.contains(search) || phone.contains(search);
    }).toList();
  }

  // ============================================================
  // TOTAL RECEIVABLE
  // ============================================================

  double get totalReceivable {
    return customers.fold(0.0, (sum, customer) {
      final receivable = (customer['receivable'] as num?)?.toDouble() ?? 0.0;

      return sum + receivable;
    });
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
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: deepForest),
        ),

        title: const Text(
          'Customers',
          style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: _refreshCustomers,
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
                onRefresh: _refreshCustomers,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 390),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(),

                          const SizedBox(height: 22),

                          // ========================================
                          // CUSTOMER LIST HEADER
                          // ========================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Customer List',
                                style: TextStyle(
                                  color: deepForest,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              ElevatedButton.icon(
                                onPressed: _showAddCustomerDialog,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Customer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: deepForest,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: gold),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // ========================================
                          // SEARCH
                          // ========================================
                          TextField(
                            controller: searchController,
                            onChanged: (_) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: 'Search customers',
                              hintStyle: const TextStyle(color: mutedText),
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

                          const SizedBox(height: 18),

                          // ========================================
                          // CUSTOMER LIST
                          // ========================================
                          if (filteredCustomers.isEmpty)
                            _buildEmptyState()
                          else
                            ...filteredCustomers.map(_buildCustomerCard),
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
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [deepForest, mainGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold, width: 1),
        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: gold.withValues(alpha: 0.45)),
            ),
            child: const Icon(
              Icons.people_outline,
              color: Colors.white,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Payments',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 5),

                Text(
                  '₹${totalReceivable.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Total amount to receive',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CUSTOMER CARD
  // ============================================================

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final receivable = (customer['receivable'] as num?)?.toDouble() ?? 0.0;

    final hasPendingPayment = receivable > 0;

    return InkWell(
      onTap: () => _showCustomerDetails(customer),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // ======================================================
            // CUSTOMER ICON
            // ======================================================

            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F0E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: mainGreen,
                size: 25,
              ),
            ),

            const SizedBox(width: 13),

            // ======================================================
            // CUSTOMER DETAILS
            // ======================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer['name']?.toString() ?? 'Unnamed Customer',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: deepForest,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: mutedText,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          customer['phone']?.toString() ?? 'Not provided',
                          style: const TextStyle(
                            fontSize: 11,
                            color: mutedText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ======================================================
            // RECEIVABLE
            // ======================================================
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hasPendingPayment
                      ? '₹${receivable.toStringAsFixed(0)}'
                      : 'Paid',
                  style: TextStyle(
                    color: hasPendingPayment ? gold : mainGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  hasPendingPayment ? 'To receive' : 'No pending',
                  style: const TextStyle(color: mutedText, fontSize: 10),
                ),
              ],
            ),

            const SizedBox(width: 8),

            const Icon(Icons.chevron_right, color: mutedText, size: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CUSTOMER DETAILS / EDIT
  // ============================================================

  void _showCustomerDetails(Map<String, dynamic> customer) {
    final customerId = (customer['id'] as num?)?.toInt();

    if (customerId == null) {
      _showMessage('This customer does not have a valid database ID.');
      return;
    }

    final nameController = TextEditingController(
      text: customer['name']?.toString() ?? '',
    );

    final phoneController = TextEditingController(
      text: customer['phone']?.toString() ?? '',
    );

    final receivableController = TextEditingController(
      text: ((customer['receivable'] as num?)?.toDouble() ?? 0).toStringAsFixed(
        0,
      ),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        final navigator = Navigator.of(dialogContext);

        return AlertDialog(
          backgroundColor: softCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F0E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: mainGreen),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Customer Details',
                  style: TextStyle(
                    color: deepForest,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                  controller: nameController,
                  label: 'Customer Name',
                  icon: Icons.person_outline,
                  capitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 14),

                _buildDialogTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 14),

                _buildDialogTextField(
                  controller: receivableController,
                  label: 'Amount to Receive',
                  hint: 'Enter receivable amount',
                  icon: Icons.currency_rupee,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixText: '₹ ',
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.deleteCustomer(customerId);

                if (!mounted) return;

                navigator.pop();

                await _loadCustomers();

                if (!mounted) return;

                _showMessage('Customer deleted successfully.');
              },
              child: const Text('Delete', style: TextStyle(color: errorRed)),
            ),

            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('Cancel', style: TextStyle(color: mutedText)),
            ),

            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();

                final phone = phoneController.text.trim();

                final amount = double.tryParse(
                  receivableController.text.trim(),
                );

                if (name.isEmpty) {
                  _showDialogMessage(
                    dialogContext,
                    'Please enter customer name.',
                  );
                  return;
                }

                if (amount == null || amount < 0) {
                  _showDialogMessage(
                    dialogContext,
                    'Please enter a valid amount.',
                  );
                  return;
                }

                await DatabaseHelper.instance.updateCustomer(customerId, {
                  'name': name,
                  'phone': phone.isEmpty ? 'Not provided' : phone,
                  'receivable': amount,
                });

                if (!mounted) return;

                navigator.pop();

                await _loadCustomers();

                if (!mounted) return;

                _showMessage('Customer details updated successfully 🌱');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: deepForest,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: gold),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ADD CUSTOMER DIALOG
  // ============================================================

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();

    final phoneController = TextEditingController();

    final receivableController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final navigator = Navigator.of(dialogContext);

        return AlertDialog(
          backgroundColor: softCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Add Customer',
            style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                  controller: nameController,
                  label: 'Customer Name',
                  icon: Icons.person_outline,
                  capitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 14),

                _buildDialogTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 14),

                _buildDialogTextField(
                  controller: receivableController,
                  label: 'Amount to Receive',
                  hint: 'Enter receivable amount',
                  icon: Icons.currency_rupee,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixText: '₹ ',
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('Cancel', style: TextStyle(color: mutedText)),
            ),

            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();

                final phone = phoneController.text.trim();

                final amount = double.tryParse(
                  receivableController.text.trim(),
                );

                if (name.isEmpty) {
                  _showDialogMessage(
                    dialogContext,
                    'Please enter customer name.',
                  );
                  return;
                }

                if (amount == null || amount < 0) {
                  _showDialogMessage(
                    dialogContext,
                    'Please enter a valid amount.',
                  );
                  return;
                }

                try {
                  await DatabaseHelper.instance.insertCustomer({
                    'name': name,
                    'phone': phone.isEmpty ? 'Not provided' : phone,
                    'receivable': amount,
                  });

                  if (!mounted) return;

                  navigator.pop();

                  final data = await DatabaseHelper.instance.getCustomers();

                  if (!mounted) return;

                  setState(() {
                    customers = data;
                    isLoading = false;
                  });

                  _showMessage('Customer added successfully 🌱');
                } catch (e) {
                  if (!mounted) return;

                  navigator.pop();

                  _showMessage('Failed to add customer.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: deepForest,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: gold),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DIALOG TEXT FIELD
  // ============================================================

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    String? prefixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,

        prefixIcon: Icon(icon, color: mainGreen),

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGreen),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGreen),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
      ),
    );
  }

  // ============================================================
  // DIALOG MESSAGE
  // ============================================================

  void _showDialogMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: deepForest,
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final hasCustomers = customers.isNotEmpty;

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
          const Icon(Icons.people_outline, size: 55, color: olive),

          const SizedBox(height: 14),

          Text(
            hasCustomers ? 'No customers found' : 'No customers yet',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: deepForest,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            hasCustomers
                ? 'Try a different search.'
                : 'Add your first customer to get started.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: mutedText),
          ),
        ],
      ),
    );
  }
}
