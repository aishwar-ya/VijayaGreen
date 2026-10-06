import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> suppliers = [];
  bool isLoading = true;

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
        backgroundColor: const Color(0xFF26332A),
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
          'Suppliers',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _refreshSuppliers,
            icon: const Icon(Icons.refresh, color: Color(0xFF1B5E20)),
            tooltip: 'Refresh',
          ),
        ],
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              )
            : RefreshIndicator(
                color: const Color(0xFF2E7D32),
                onRefresh: _refreshSuppliers,

                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),

                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),

                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          _buildSummaryCard(),

                          const SizedBox(height: 22),

                          // SUPPLIER LIST HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text(
                                'Supplier List',
                                style: TextStyle(
                                  color: Color(0xFF26332A),
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              ElevatedButton.icon(
                                onPressed: _showAddSupplierDialog,

                                icon: const Icon(Icons.add, size: 18),

                                label: const Text('Add Supplier'),

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  elevation: 0,

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // SEARCH
                          TextField(
                            controller: searchController,

                            onChanged: (_) {
                              setState(() {});
                            },

                            decoration: InputDecoration(
                              hintText: 'Search suppliers',

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

                          const SizedBox(height: 18),

                          // SUPPLIER LIST
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
          colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.18),
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
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
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

          border: Border.all(color: Colors.grey.shade100),
        ),

        child: Row(
          children: [
            // ICON
            Container(
              width: 48,
              height: 48,

              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E1),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.storefront_outlined,
                color: Color(0xFFAD6800),
                size: 25,
              ),
            ),

            const SizedBox(width: 13),

            // DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    name,

                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF26332A),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 13,
                        color: Colors.grey.shade500,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          category,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: Colors.grey.shade500,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          phone,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // PAYABLE
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                Text(
                  hasPendingPayment ? '₹${payable.toStringAsFixed(0)}' : 'Paid',

                  style: TextStyle(
                    color: hasPendingPayment
                        ? const Color(0xFFE65100)
                        : const Color(0xFF2E7D32),

                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  hasPendingPayment ? 'To pay' : 'No pending',

                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ),

            const SizedBox(width: 8),

            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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

                child: const Icon(
                  Icons.storefront_outlined,
                  color: Color(0xFFAD6800),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Supplier Details',

                  style: TextStyle(
                    color: Color(0xFF1B5E20),
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
                // SUPPLIER NAME
                TextField(
                  controller: nameController,

                  textCapitalization: TextCapitalization.words,

                  decoration: InputDecoration(
                    labelText: 'Supplier Name',

                    prefixIcon: const Icon(
                      Icons.storefront_outlined,
                      color: Color(0xFF2E7D32),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // PHONE
                TextField(
                  controller: phoneController,

                  keyboardType: TextInputType.phone,

                  decoration: InputDecoration(
                    labelText: 'Phone Number',

                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF2E7D32),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // CATEGORY
                TextField(
                  controller: categoryController,

                  textCapitalization: TextCapitalization.words,

                  decoration: InputDecoration(
                    labelText: 'Supply Category',

                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      color: Color(0xFF2E7D32),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // AMOUNT TO PAY
                TextField(
                  controller: payableController,

                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  decoration: InputDecoration(
                    labelText: 'Amount to Pay',

                    prefixIcon: const Icon(
                      Icons.currency_rupee,
                      color: Color(0xFFAD6800),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            // DELETE
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);

                final messenger = ScaffoldMessenger.of(context);

                try {
                  await DatabaseHelper.instance.deleteSupplier(supplierId);

                  if (!mounted) return;

                  navigator.pop();

                  await _loadSuppliers();

                  if (!mounted) return;

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Supplier deleted successfully.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFFC62828),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete supplier.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFFC62828),
                    ),
                  );
                }
              },

              child: const Text(
                'Delete',

                style: TextStyle(color: Color(0xFFC62828)),
              ),
            ),

            // CANCEL
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),

            // SAVE
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();

                final phone = phoneController.text.trim();

                final category = categoryController.text.trim();

                final double? payable = double.tryParse(
                  payableController.text.trim(),
                );

                if (name.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter supplier name.'),
                    ),
                  );

                  return;
                }

                // Only ONE payable validation.
                if (payable == null || payable < 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid payable amount.'),
                    ),
                  );

                  return;
                }

                final navigator = Navigator.of(dialogContext);

                final messenger = ScaffoldMessenger.of(context);

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

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Supplier updated successfully 🌱'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update supplier.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFFC62828),
                    ),
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),

                foregroundColor: Colors.white,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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

        border: Border.all(color: Colors.grey.shade100),
      ),

      child: Column(
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 55,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 14),

          Text(
            hasSuppliers ? 'No suppliers found' : 'No suppliers yet',

            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26332A),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            hasSuppliers
                ? 'Try a different search.'
                : 'Add your first supplier to get started.',

            textAlign: TextAlign.center,

            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Add Supplier',

            style: TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                // NAME
                TextField(
                  controller: nameController,

                  textCapitalization: TextCapitalization.words,

                  decoration: InputDecoration(
                    labelText: 'Supplier Name',

                    prefixIcon: const Icon(
                      Icons.storefront_outlined,
                      color: Color(0xFF2E7D32),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // PHONE
                TextField(
                  controller: phoneController,

                  keyboardType: TextInputType.phone,

                  decoration: InputDecoration(
                    labelText: 'Phone Number',

                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF2E7D32),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // CATEGORY
                TextField(
                  controller: categoryController,

                  textCapitalization: TextCapitalization.words,

                  decoration: InputDecoration(
                    labelText: 'Supply Category',

                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      color: Color(0xFF2E7D32),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // AMOUNT TO PAY
                TextField(
                  controller: payableController,

                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  decoration: InputDecoration(
                    labelText: 'Amount to Pay',

                    prefixIcon: const Icon(
                      Icons.currency_rupee,
                      color: Color(0xFFAD6800),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            // CANCEL
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),

            // ADD
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();

                final phone = phoneController.text.trim();

                final category = categoryController.text.trim();

                final double? payable = double.tryParse(
                  payableController.text.trim(),
                );

                if (name.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter supplier name.'),
                    ),
                  );

                  return;
                }

                if (payable == null || payable < 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid payable amount.'),
                    ),
                  );

                  return;
                }

                final navigator = Navigator.of(dialogContext);

                final messenger = ScaffoldMessenger.of(context);

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

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Supplier added successfully 🌱'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  navigator.pop();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Failed to add supplier.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFFC62828),
                    ),
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),

                foregroundColor: Colors.white,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
}
