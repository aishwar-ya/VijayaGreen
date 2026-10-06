import 'package:flutter/material.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final TextEditingController amountController = TextEditingController();

  final TextEditingController customerController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  String selectedCategory = 'Plant Sales';
  String selectedPaymentMethod = 'Cash';

  DateTime selectedDate = DateTime.now();

  final List<String> categories = [
    'Plant Sales',
    'Seeds',
    'Pots & Containers',
    'Gardening Supplies',
    'Landscaping',
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
    customerController.dispose();
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
            colorScheme: const ColorScheme.light(primary: Color(0xFF2E7D32)),
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
  // SAVE INCOME
  // ============================================================

  void _saveIncome() {
    final amount = amountController.text.trim();

    if (amount.isEmpty) {
      _showMessage('Please enter the income amount.');
      return;
    }

    final parsedAmount = double.tryParse(amount);

    if (parsedAmount == null || parsedAmount <= 0) {
      _showMessage('Please enter a valid amount.');
      return;
    }

    _showSuccessDialog(parsedAmount);
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
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 44,
                  color: Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Income Added',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '₹${amount.toStringAsFixed(2)} has been recorded as income.',
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
                    backgroundColor: const Color(0xFF2E7D32),
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
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
      suffixIcon: suffix,
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
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
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
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: _inputDecoration(hint: '', icon: Icons.category_outlined),
      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(item.toString()));
      }).toList(),
      onChanged: onChanged,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------
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
          'Add Income',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // BODY
      // ----------------------------------------------------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // HEADER
                  // ------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 34,
                          color: Color(0xFF2E7D32),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Record Garden Income',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Add money received by Vijaya Garden.',
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

                  // ------------------------------------------------
                  // AMOUNT
                  // ------------------------------------------------
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

                  // ------------------------------------------------
                  // CATEGORY
                  // ------------------------------------------------
                  _buildLabel('Income Category'),

                  const SizedBox(height: 8),

                  _buildDropdown<String>(
                    value: selectedCategory,
                    items: categories,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // CUSTOMER
                  // ------------------------------------------------
                  _buildLabel('Customer Name (Optional)'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: customerController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      hint: 'Enter customer name',
                      icon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // DATE
                  // ------------------------------------------------
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

                  // ------------------------------------------------
                  // PAYMENT METHOD
                  // ------------------------------------------------
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

                  // ------------------------------------------------
                  // NOTES
                  // ------------------------------------------------
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

                  // ------------------------------------------------
                  // SAVE BUTTON
                  // ------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _saveIncome,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'Save Income',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
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
