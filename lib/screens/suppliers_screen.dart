import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
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

  List<Map<String, dynamic>> suppliers = [];

  bool isLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  // ============================================================
  // LOAD SUPPLIERS
  // ============================================================

  Future<void> _loadSuppliers() async {
    try {
      final data = await DatabaseHelper.instance.getSuppliers();

      if (!mounted) return;

      setState(() {
        suppliers = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Failed to load suppliers.');
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshSuppliers() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    await _loadSuppliers();
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<Map<String, dynamic>> get filteredSuppliers {
    final search = searchController.text.trim().toLowerCase();

    if (search.isEmpty) {
      return suppliers;
    }

    return suppliers.where((supplier) {
      final name = supplier['name']?.toString().toLowerCase() ?? '';

      final phone = supplier['phone']?.toString().toLowerCase() ?? '';

      final category = supplier['category']?.toString().toLowerCase() ?? '';

      return name.contains(search) ||
          phone.contains(search) ||
          category.contains(search);
    }).toList();
  }

  // ============================================================
  // TOTAL PAYABLE
  // ============================================================

  double get totalPayable {
    return suppliers.fold(0.0, (sum, supplier) {
      final payable = (supplier['payable'] as num?)?.toDouble() ?? 0.0;

      return sum + payable;
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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: deepForest),
        ),

        title: const Text(
          'Suppliers',
          style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: _refreshSuppliers,
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
                onRefresh: _refreshSuppliers,
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
                          // SUPPLIER LIST HEADER
                          // ========================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Supplier List',
                                style: TextStyle(
                                  color: deepForest,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              ElevatedButton.icon(
                                onPressed: _showAddSupplierDialog,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Supplier'),
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
                              hintText: 'Search suppliers',
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
                          // SUPPLIER LIST
                          // ========================================
                          if (filteredSuppliers.isEmpty)
                            _buildEmptyState()
                          else
                            ...filteredSuppliers.map(_buildSupplierCard),
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
              Icons.storefront_outlined,
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
                  'Supplier Payments',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 5),

                Text(
                  '₹${totalPayable.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Total amount to pay',
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
  // SUPPLIER CARD
  // ============================================================

  Widget _buildSupplierCard(Map<String, dynamic> supplier) {
    final double payable = (supplier['payable'] as num?)?.toDouble() ?? 0.0;

    final bool hasPendingPayment = payable > 0;

    final String name = supplier['name']?.toString() ?? 'Unknown';

    final String phone = supplier['phone']?.toString() ?? 'Not provided';

    final String category = supplier['category']?.toString() ?? 'Other';

    return InkWell(
      onTap: () {
        _showSupplierDetails(supplier);
      },
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
            // ICON
            // ======================================================

            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: gold,
                size: 25,
              ),
            ),

            const SizedBox(width: 13),

            // ======================================================
            // DETAILS
            // ======================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
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
                        Icons.category_outlined,
                        size: 13,
                        color: mutedText,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          category,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: mutedText,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

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
                          phone,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: mutedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ======================================================
            // PAYABLE
            // ======================================================
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hasPendingPayment ? '₹${payable.toStringAsFixed(0)}' : 'Paid',
                  style: TextStyle(
                    color: hasPendingPayment ? gold : mainGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  hasPendingPayment ? 'To pay' : 'No pending',
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
  // SUPPLIER DETAILS / EDIT / DELETE
  // ============================================================

  void _showSupplierDetails(Map<String, dynamic> supplier) {
    final int? supplierId = (supplier['id'] as num?)?.toInt();

    if (supplierId == null) {
      _showMessage('This supplier does not have a valid database ID.');
      return;
    }

    final nameController = TextEditingController(
      text: supplier['name']?.toString() ?? '',
    );

    final phoneController = TextEditingController(
      text: supplier['phone']?.toString() ?? '',
    );

    final categoryController = TextEditingController(
      text: supplier['category']?.toString() ?? '',
    );

    final payableController = TextEditingController(
      text: ((supplier['payable'] as num?)?.toDouble() ?? 0).toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
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
                  color: Color(0xFFFFF8E1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_outlined, color: gold),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Supplier Details',
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
                  label: 'Supplier Name',
                  icon: Icons.storefront_outlined,
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
                  controller: categoryController,
                  label: 'Supply Category',
                  icon: Icons.category_outlined,
                  capitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 14),

                _buildDialogTextField(
                  controller: payableController,
                  label: 'Amount to Pay',
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
            // ======================================================
            // DELETE
            // ======================================================

            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);

                try {
                  await DatabaseHelper.instance.deleteSupplier(supplierId);

                  if (!mounted) return;

                  navigator.pop();

                  await _loadSuppliers();

                  if (!mounted) return;

                  _showMessage('Supplier deleted successfully.');
                } catch (e) {
                  if (!mounted) return;

                  _showMessage('Failed to delete supplier.');
                }
              },
              child: const Text('Delete', style: TextStyle(color: errorRed)),
            ),

            // ======================================================
            // CANCEL
            // ======================================================
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel', style: TextStyle(color: mutedText)),
            ),

            // ======================================================
            // SAVE
            // ======================================================
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();

                final phone = phoneController.text.trim();

                final category = categoryController.text.trim();

                final double? payable = double.tryParse(
                  payableController.text.trim(),
                );

                if (name.isEmpty) {
                  _showDialogMessage(
                    dialogContext,
                    'Please enter supplier name.',
                  );
                  return;
                }

                if (payable == null || payable < 0) {
                  _showDialogMessage(
                    dialogContext,
                    'Please enter a valid payable amount.',
                  );
                  return;
                }

                final navigator = Navigator.of(dialogContext);

                try {
                  await DatabaseHelper.instance.updateSupplier(supplierId, {
                    'name': name,
                    'phone': phone.isEmpty ? 'Not provided' : phone,
                    'category': category.isEmpty ? 'Other' : category,
                    'payable': payable,
                  });

                  if (!mounted) return;

                  navigator.pop();

                  await _loadSuppliers();

                  if (!mounted) return;

                  _showMessage('Supplier updated successfully 🌱');
                } catch (e) {
                  if (!mounted) return;

                  _showMessage('Failed to update supplier.');
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
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      phoneController.dispose();
      categoryController.dispose();
      payableController.dispose();
    });
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final bool hasSuppliers = suppliers.isNotEmpty;

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
          const Icon(Icons.storefront_outlined, size: 55, color: olive),

          const SizedBox(height: 14),

          Text(
            hasSuppliers ? 'No suppliers found' : 'No suppliers yet',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: deepForest,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            hasSuppliers
                ? 'Try a different search.'
                : 'Add your first supplier to get started.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: mutedText),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD SUPPLIER
  // ============================================================

  void _showAddSupplierDialog() {
    final nameController = TextEditingController();

    final phoneController = TextEditingController();

    final categoryController = TextEditingController();

    final payableController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: softCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Add Supplier',
            style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                  controller: nameController,
                  label: 'Supplier Name',
                  icon: Icons.storefront_outlined,
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
                  controller: categoryController,
                  label: 'Supply Category',
                  icon: Icons.category_outlined,
                  capitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 14),

                _buildDialogTextField(
                  controller: payableController,
                  label: 'Amount to Pay',
                  hint: 'Enter payable amount',
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
            // ======================================================
            // CANCEL
            // ======================================================

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel', style: TextStyle(color: mutedText)),
            ),

            // ======================================================
            // ADD
            // ======================================================
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();

                final phone = phoneController.text.trim();

                final category = categoryController.text.trim();

                final double? payable = double.tryParse(
                  payableController.text.trim(),
                );

                if (name.isEmpty) {
                  _showDialogMessage(
                    dialogContext,
                    'Please enter supplier name.',
                  );
                  return;
                }

                if (payable == null || payable < 0) {
                  _showDialogMessage(
                    dialogContext,
                    'Please enter a valid payable amount.',
                  );
                  return;
                }

                final navigator = Navigator.of(dialogContext);

                try {
                  await DatabaseHelper.instance.insertSupplier({
                    'name': name,
                    'phone': phone.isEmpty ? 'Not provided' : phone,
                    'category': category.isEmpty ? 'Other' : category,
                    'payable': payable,
                  });

                  if (!mounted) return;

                  navigator.pop();

                  await _loadSuppliers();

                  if (!mounted) return;

                  _showMessage('Supplier added successfully 🌱');
                } catch (e) {
                  if (!mounted) return;

                  navigator.pop();

                  _showMessage('Failed to add supplier.');
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
    ).then((_) {
      nameController.dispose();
      phoneController.dispose();
      categoryController.dispose();
      payableController.dispose();
    });
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
