import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // ============================================================
  // GOLDEN GREEN THEME
  // ============================================================

  static const Color deepForest = Color(0xFF123524);
  static const Color gold = Color(0xFFD4A72C);
  static const Color cream = Color(0xFFF7F3E7);
  static const Color softCream = Color(0xFFFCFAF3);
  static const Color mutedText = Color(0xFF687267);
  static const Color borderGreen = Color(0xFFD7E2D5);
  static const Color errorRed = Color(0xFFC62828);

  // ============================================================
  // CONTROLLERS
  // ============================================================

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

  // ============================================================
  // DISPOSE
  // ============================================================

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
            colorScheme: const ColorScheme.light(
              primary: errorRed,
              onPrimary: Colors.white,
              surface: softCream,
              onSurface: deepForest,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: softCream),
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
          backgroundColor: softCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: gold.withValues(alpha: 0.45), width: 1),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gold.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 44,
                  color: errorRed,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Expense Added',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: deepForest,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '₹${amount.toStringAsFixed(2)} has been recorded as an expense.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: mutedText,
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
                    backgroundColor: deepForest,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: gold.withValues(alpha: 0.30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: gold, width: 1),
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
        backgroundColor: deepForest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
      hintStyle: const TextStyle(color: mutedText, fontSize: 15),
      prefixIcon: Icon(icon, color: errorRed),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderGreen),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderGreen),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: deepForest,
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
          'Add Expense',
          style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
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
                  // ==================================================
                  // HEADER CARD
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF7E8E8), Color(0xFFF4EEE0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: gold.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: softCream,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: gold.withValues(alpha: 0.45),
                            ),
                          ),
                          child: const Icon(
                            Icons.trending_down,
                            size: 30,
                            color: errorRed,
                          ),
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Record Garden Expense',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: deepForest,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                'Add money spent by Vijaya Garden.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ==================================================
                  // AMOUNT
                  // ==================================================
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

                  // ==================================================
                  // CATEGORY
                  // ==================================================
                  _buildLabel('Expense Category'),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    isExpanded: true,
                    dropdownColor: softCream,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: errorRed,
                    ),
                    decoration: _inputDecoration(
                      hint: '',
                      icon: Icons.category_outlined,
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: deepForest,
                            fontSize: 14,
                          ),
                        ),
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

                  // ==================================================
                  // SUPPLIER
                  // ==================================================
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

                  // ==================================================
                  // DATE
                  // ==================================================
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
                        style: const TextStyle(fontSize: 14, color: deepForest),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // PAYMENT METHOD
                  // ==================================================
                  _buildLabel('Payment Method'),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: selectedPaymentMethod,
                    isExpanded: true,
                    dropdownColor: softCream,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: errorRed,
                    ),
                    decoration: _inputDecoration(
                      hint: '',
                      icon: Icons.payment_outlined,
                    ),
                    items: paymentMethods.map((method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(
                          method,
                          style: const TextStyle(
                            color: deepForest,
                            fontSize: 14,
                          ),
                        ),
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

                  // ==================================================
                  // NOTES
                  // ==================================================
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

                  // ==================================================
                  // SAVE BUTTON
                  // ==================================================
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
                        backgroundColor: deepForest,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: gold.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: gold, width: 1),
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
