import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> customers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

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

  Future<void> _refreshCustomers() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    await _loadCustomers();
  }

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

  double get totalReceivable {
    return customers.fold(0.0, (sum, customer) {
      final receivable = (customer['receivable'] as num?)?.toDouble() ?? 0.0;
      return sum + receivable;
    });
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
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
        ),
        title: const Text(
          'Customers',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshCustomers,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Customer List',
                                style: TextStyle(
                                  color: Color(0xFF26332A),
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _showAddCustomerDialog,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Customer'),
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
                          TextField(
                            controller: searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search customers',
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
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF2E7D32),
                size: 25,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer['name']?.toString() ?? 'Unnamed Customer',
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
                        Icons.phone_outlined,
                        size: 13,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          customer['phone']?.toString() ?? 'Not provided',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hasPendingPayment
                      ? '₹${receivable.toStringAsFixed(0)}'
                      : 'Paid',
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
                  hasPendingPayment ? 'To receive' : 'No pending',
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

  // Customer details now has editable Name, Phone Number,
  // and Amount to Receive fields.
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
        final messenger = ScaffoldMessenger.of(context);

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
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Customer Details',
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
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Customer Name',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF2E7D32),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: receivableController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount to Receive',
                    prefixText: '₹ ',
                    hintText: 'Enter receivable amount',
                    prefixIcon: const Icon(
                      Icons.currency_rupee,
                      color: Color(0xFF2E7D32),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF6FAF6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 1.5,
                      ),
                    ),
                  ),
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

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Customer deleted successfully.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFFC62828),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFC62828)),
              ),
            ),
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                final amount = double.tryParse(
                  receivableController.text.trim(),
                );

                if (name.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter customer name.'),
                    ),
                  );
                  return;
                }

                if (amount == null || amount < 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount.'),
                    ),
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

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Customer details updated successfully 🌱'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
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
    );
  }

  Widget _buildEmptyState() {
    final hasCustomers = customers.isNotEmpty;

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
          Icon(Icons.people_outline, size: 55, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            hasCustomers ? 'No customers found' : 'No customers yet',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26332A),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            hasCustomers
                ? 'Try a different search.'
                : 'Add your first customer to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final receivableController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final navigator = Navigator.of(dialogContext);
        final messenger = ScaffoldMessenger.of(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add Customer',
            style: TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF2E7D32),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
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
              TextField(
                controller: receivableController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount to Receive',
                  hintText: 'Enter receivable amount',
                  prefixText: '₹ ',
                  prefixIcon: const Icon(
                    Icons.currency_rupee,
                    color: Color(0xFF2E7D32),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                final amount = double.tryParse(
                  receivableController.text.trim(),
                );

                if (name.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Please enter customer name.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF26332A),
                    ),
                  );
                  return;
                }

                if (amount == null || amount < 0) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF26332A),
                    ),
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

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Customer added successfully 🌱'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  navigator.pop();

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Failed to add customer.'),
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
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
