import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedCategory = 'Fertilizer';
  String selectedPaymentMethod = 'Cash';

  DateTime selectedDate = DateTime.now();

  final List<String> categories = [
    'Plants / Seedlings',
    'Fertilizer',
    'Pots & Containers',
    'Transport',
    'Electricity',
    'Labour',
    'Garden Maintenance',
    'Water',
    'Other',
  ];

  final List<String> paymentMethods = [
    'Cash',
    'UPI',
    'Bank Transfer',
    'Card',
    'Other',
  ];

  @override
  void dispose() {
    amountController.dispose();
    supplierController.dispose();
    notesController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFC62828)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // ============================================================
  // SAVE EXPENSE
  // ============================================================

  Future<void> _saveExpense() async {
    final amount = amountController.text.trim();

    if (amount.isEmpty) {
      _showMessage('Please enter the expense amount.');
      return;
    }

    final parsedAmount = double.tryParse(amount);

    if (parsedAmount == null || parsedAmount <= 0) {
      _showMessage('Please enter a valid amount.');
      return;
    }

    try {
      await DatabaseHelper.instance.insertTransaction({
        'type': 'expense',
        'category': selectedCategory,
        'description': notesController.text.trim(),
        'amount': parsedAmount,
        'date': selectedDate.toIso8601String(),
        'partyName': supplierController.text.trim(),
        'paymentMethod': selectedPaymentMethod,
      });

      if (!mounted) return;

      _showSuccessDialog(parsedAmount);
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to save expense.');
    }
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 44,
                  color: Color(0xFFC62828),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Expense Added',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB71C1C),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '₹${amount.toStringAsFixed(2)} has been recorded as an expense.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF26332A),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFC62828)),
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
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
        ),
        title: const Text(
          'Add Expense',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // HEADER
                  // =================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.trending_down,
                          size: 34,
                          color: Color(0xFFC62828),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Record Garden Expense',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB71C1C),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Add money spent by Vijaya Garden.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B756B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // =================================================
                  // AMOUNT
                  // =================================================
                  _buildLabel('Amount'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _inputDecoration(
                      hint: 'Enter amount',
                      icon: Icons.currency_rupee,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // CATEGORY
                  // =================================================
                  _buildLabel('Expense Category'),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      hint: '',
                      icon: Icons.category_outlined,
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // SUPPLIER
                  // =================================================
                  _buildLabel('Supplier Name (Optional)'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: supplierController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      hint: 'Enter supplier name',
                      icon: Icons.storefront_outlined,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // DATE
                  // =================================================
                  _buildLabel('Date'),

                  const SizedBox(height: 8),

                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: _inputDecoration(
                        hint: '',
                        icon: Icons.calendar_today_outlined,
                      ),
                      child: Text(
                        '${selectedDate.day.toString().padLeft(2, '0')}/'
                        '${selectedDate.month.toString().padLeft(2, '0')}/'
                        '${selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF26332A),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // PAYMENT METHOD
                  // =================================================
                  _buildLabel('Payment Method'),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: selectedPaymentMethod,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      hint: '',
                      icon: Icons.payment_outlined,
                    ),
                    items: paymentMethods.map((method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedPaymentMethod = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // NOTES
                  // =================================================
                  _buildLabel('Notes (Optional)'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: notesController,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDecoration(
                      hint: 'Add any additional details',
                      icon: Icons.notes_outlined,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =================================================
                  // SAVE BUTTON
                  // =================================================
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _saveExpense,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'Save Expense',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
