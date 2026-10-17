import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
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

  // DATABASE DATA

  // ============================================================

  double totalIncome = 0.0;

  double totalExpenses = 0.0;

  List<Map<String, dynamic>> incomeCategories = [];

  List<Map<String, dynamic>> expenseCategories = [];

  bool isLoading = true;

  DateTime selectedReportDate = DateTime.now();

  DateTime rangeStartDate = DateTime.now();

  DateTime rangeEndDate = DateTime.now();

  // ============================================================

  // INIT

  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadReportData();
  }

  // ============================================================

  // LOAD REPORT DATA

  // ============================================================

  Future<void> _loadReportData() async {
    try {
      final income = await DatabaseHelper.instance.getTotalIncome();

      final expenses = await DatabaseHelper.instance.getTotalExpenses();

      final transactions = await DatabaseHelper.instance.getTransactions();

      final incomeMap = <String, double>{};

      final expenseMap = <String, double>{};

      for (final transaction in transactions) {
        final type = transaction['type']?.toString() ?? '';

        final category = transaction['category']?.toString() ?? 'Other';

        final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;

        if (amount <= 0) {
          continue;
        }

        if (type == 'income') {
          incomeMap[category] = (incomeMap[category] ?? 0.0) + amount;
        } else if (type == 'expense') {
          expenseMap[category] = (expenseMap[category] ?? 0.0) + amount;
        }
      }

      final incomeList = _buildCategoryList(incomeMap, income);

      final expenseList = _buildCategoryList(expenseMap, expenses);

      if (!mounted) return;

      setState(() {
        totalIncome = income;

        totalExpenses = expenses;

        incomeCategories = incomeList;

        expenseCategories = expenseList;

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Failed to load report data.');
    }
  }

  // ============================================================

  // BUILD CATEGORY LIST

  // ============================================================

  List<Map<String, dynamic>> _buildCategoryList(
    Map<String, double> categoryMap,

    double total,
  ) {
    final list = categoryMap.entries.map((entry) {
      final percentage = total > 0 ? ((entry.value / total) * 100).round() : 0;

      return {
        'title': entry.key,

        'amount': entry.value,

        'percentage': percentage,
      };
    }).toList();

    list.sort(
      (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
    );

    return list;
  }

  // ============================================================

  // CURRENT BALANCE

  // ============================================================

  double get currentBalance {
    return totalIncome - totalExpenses;
  }

  // ============================================================

  // CURRENT MONTH

  // ============================================================

  String get currentMonthYear {
    final now = DateTime.now();

    const months = [
      'January',

      'February',

      'March',

      'April',

      'May',

      'June',

      'July',

      'August',

      'September',

      'October',

      'November',

      'December',
    ];

    return '${months[now.month - 1]} ${now.year}';
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
  // REPORT DATE SELECTION
  // ============================================================

  String _formatReportDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _selectDailyReportDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedReportDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      selectedReportDate = picked;
    });
  }

  Future<void> _selectRangeStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: rangeStartDate,
      firstDate: DateTime(2020),
      lastDate: rangeEndDate,
    );

    if (picked == null) return;

    setState(() {
      rangeStartDate = picked;
    });
  }

  Future<void> _selectRangeEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: rangeEndDate,
      firstDate: rangeStartDate,
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      rangeEndDate = picked;
    });
  }

  // ============================================================

  // CATEGORY ICON

  // ============================================================

  IconData _getCategoryIcon(String category, bool isIncome) {
    final value = category.toLowerCase();

    if (value.contains('plant') || value.contains('seedling')) {
      return Icons.local_florist_outlined;
    }

    if (value.contains('landscap')) {
      return Icons.grass_outlined;
    }

    if (value.contains('indoor')) {
      return Icons.eco_outlined;
    }

    if (value.contains('fertilizer')) {
      return Icons.science_outlined;
    }

    if (value.contains('maintenance')) {
      return Icons.handyman_outlined;
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

    if (isIncome) {
      return Icons.trending_up;
    }

    return Icons.receipt_long_outlined;
  }

  // ============================================================

  // CATEGORY COLOR

  // ============================================================

  Color _getCategoryColor(int index, bool isIncome) {
    if (isIncome) {
      const colors = [
        mainGreen,

        olive,

        deepForest,

        Color(0xFF587A45),

        Color(0xFF8A9A4A),
      ];

      return colors[index % colors.length];
    }

    const colors = [
      errorRed,

      Color(0xFFB85C38),

      Color(0xFF9A6B2F),

      Color(0xFF8A735D),

      Color(0xFF765548),
    ];

    return colors[index % colors.length];
  }

  // ============================================================

  // CATEGORY BACKGROUND

  // ============================================================

  Color _getCategoryBackground(int index, bool isIncome) {
    if (isIncome) {
      const colors = [
        Color(0xFFE8F0E8),

        Color(0xFFF1F4E5),

        Color(0xFFE6EEE9),

        Color(0xFFF2F5E9),

        Color(0xFFE9EFE5),
      ];

      return colors[index % colors.length];
    }

    const colors = [
      Color(0xFFFFEBEE),

      Color(0xFFFFF1E8),

      Color(0xFFFFF8E1),

      Color(0xFFFBE9E7),

      Color(0xFFF1EAE5),
    ];

    return colors[index % colors.length];
  }

  // ============================================================

  // ============================================================

  // ============================================================
  // PDF REPORT GENERATION
  // ============================================================

  Future<void> _generateDailyPdf() async {
    final start = DateTime(
      selectedReportDate.year,
      selectedReportDate.month,
      selectedReportDate.day,
    );

    final end = start.add(const Duration(days: 1));

    await _generatePdfReport(
      title: 'Daily Financial Report',
      periodLabel: _formatLongDate(start),
      startDate: start,
      endDate: end,
    );
  }

  Future<void> _generateRangePdf() async {
    final start = DateTime(
      rangeStartDate.year,
      rangeStartDate.month,
      rangeStartDate.day,
    );

    final end = DateTime(
      rangeEndDate.year,
      rangeEndDate.month,
      rangeEndDate.day,
    ).add(const Duration(days: 1));

    await _generatePdfReport(
      title: 'Financial Report',
      periodLabel:
          '${_formatLongDate(start)} - ${_formatLongDate(end.subtract(const Duration(days: 1)))}',
      startDate: start,
      endDate: end,
    );
  }

  String _formatLongDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatPdfDate(String value) {
    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return value;
    }

    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')}/'
        '${parsed.year}';
  }

  String _formatPdfTime(String value) {
    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return '';
    }

    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _pdfAmount(double amount) {
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }

  Future<void> _generatePdfReport({
    required String title,
    required String periodLabel,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!mounted) return;

    try {
      final allTransactions = await DatabaseHelper.instance.getTransactions();

      final transactions = allTransactions.where((transaction) {
        final rawDate = transaction['date']?.toString() ?? '';
        final transactionDate = DateTime.tryParse(rawDate);

        if (transactionDate == null) return false;

        return !transactionDate.isBefore(startDate) &&
            transactionDate.isBefore(endDate);
      }).toList();

      transactions.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(2000);

        final dateB =
            DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(2000);

        return dateA.compareTo(dateB);
      });

      double income = 0;
      double expenses = 0;

      final incomeTransactions = <Map<String, dynamic>>[];
      final expenseTransactions = <Map<String, dynamic>>[];

      for (final transaction in transactions) {
        final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;

        final type = transaction['type']?.toString() ?? '';

        if (type == 'income') {
          income += amount;
          incomeTransactions.add(transaction);
        } else if (type == 'expense') {
          expenses += amount;
          expenseTransactions.add(transaction);
        }
      }

      final balance = income - expenses;

      Uint8List? logoBytes;

      try {
        final data = await rootBundle.load(
          'assets/images/vijayagreen_logo.png',
        );

        logoBytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
      } catch (_) {
        logoBytes = null;
      }

      final document = pw.Document();

      final baseText = pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800);

      final smallText = pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700);

      final headerStyle = pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      );

      pw.Widget buildSummaryBox(
        String label,
        String value,
        PdfColor background,
        PdfColor valueColor,
      ) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: background,
            borderRadius: pw.BorderRadius.circular(7),
            border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                label.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        );
      }

      pw.Widget buildTransactionTable(
        List<Map<String, dynamic>> items,
        bool isIncome,
      ) {
        if (items.isEmpty) {
          return pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Text(
              isIncome
                  ? 'No money received during this period.'
                  : 'No money spent during this period.',
              style: baseText,
            ),
          );
        }

        final rows = items.map((transaction) {
          final rawDate = transaction['date']?.toString() ?? '';
          final date = _formatPdfDate(rawDate);
          final time = _formatPdfTime(rawDate);

          final partyName = transaction['partyName']?.toString().trim() ?? '';
          final category = transaction['category']?.toString().trim() ?? '';
          final paymentMethod =
              transaction['paymentMethod']?.toString().trim() ?? '';
          final description =
              transaction['description']?.toString().trim() ?? '';
          final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;

          return [
            time.isEmpty ? date : '$date\n$time',
            partyName.isEmpty ? '-' : partyName,
            category.isEmpty ? '-' : category,
            paymentMethod.isEmpty ? '-' : paymentMethod,
            description.isEmpty ? '-' : description,
            _pdfAmount(amount),
          ];
        }).toList();

        return pw.TableHelper.fromTextArray(
          headers: const [
            'DATE / TIME',
            'PARTY',
            'CATEGORY',
            'PAYMENT',
            'DESCRIPTION / NOTES',
            'AMOUNT',
          ],
          data: rows,
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          headerStyle: headerStyle,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green900),
          cellStyle: baseText,
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
          cellAlignments: {5: pw.Alignment.centerRight},
          columnWidths: {
            0: const pw.FlexColumnWidth(1.2),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.4),
            3: const pw.FlexColumnWidth(1.1),
            4: const pw.FlexColumnWidth(2.4),
            5: const pw.FlexColumnWidth(1.2),
          },
        );
      }

      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 30),
          header: (context) => pw.Container(height: 2),
          footer: (context) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated by VijayaGreen | Vijaya Garden',
                style: smallText,
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: smallText,
              ),
            ],
          ),
          build: (context) => [
            if (logoBytes != null)
              pw.Center(
                child: pw.Container(
                  width: 130,
                  height: 72,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),

            pw.SizedBox(height: 6),

            pw.Center(
              child: pw.Text(
                title.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            pw.SizedBox(height: 3),

            pw.Center(
              child: pw.Text(
                periodLabel,
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ),

            pw.SizedBox(height: 5),
            pw.Divider(color: PdfColors.green900, thickness: 1.0),
            pw.SizedBox(height: 7),

            pw.Text(
              'FINANCIAL SUMMARY',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green900,
              ),
            ),

            pw.SizedBox(height: 7),

            pw.Row(
              children: [
                pw.Expanded(
                  child: buildSummaryBox(
                    'Money Received',
                    _pdfAmount(income),
                    PdfColors.green50,
                    PdfColors.green900,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: buildSummaryBox(
                    'Money Spent',
                    _pdfAmount(expenses),
                    PdfColors.red50,
                    PdfColors.red800,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: buildSummaryBox(
                    'Net Balance',
                    _pdfAmount(balance),
                    balance >= 0 ? PdfColors.green50 : PdfColors.red50,
                    balance >= 0 ? PdfColors.green900 : PdfColors.red800,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: buildSummaryBox(
                    'Transactions',
                    transactions.length.toString(),
                    PdfColors.grey100,
                    PdfColors.grey800,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 9),

            pw.Text(
              'REPORT DETAILS',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green900,
              ),
            ),

            pw.SizedBox(height: 7),

            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Report period: $periodLabel',
                      style: baseText,
                    ),
                  ),
                  pw.Text(
                    'Received: ${incomeTransactions.length}',
                    style: baseText,
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    'Spent: ${expenseTransactions.length}',
                    style: baseText,
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 9),

            pw.Text(
              'ALL TRANSACTIONS',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green900,
              ),
            ),

            pw.SizedBox(height: 5),

            if (transactions.isEmpty)
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(18),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'No transactions were recorded during the selected period.',
                  style: baseText,
                ),
              )
            else
              buildTransactionTable(transactions, true),
          ],
        ),
      );

      final bytes = await document.save();

      if (!mounted) return;

      final safeDate = _formatFileDate(startDate);

      final fileName = title == 'Daily Financial Report'
          ? 'vijayagreen_daily_report_$safeDate.pdf'
          : 'vijayagreen_report_${_formatFileDate(startDate)}_to_${_formatFileDate(endDate.subtract(const Duration(days: 1)))}.pdf';

      // FilePicker is already used by VijayaGreen for backup/restore.
      // saveFile lets the owner choose exactly where to save the PDF.
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save VijayaGreen PDF Report',
        fileName: fileName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (!mounted) return;

      if (savedPath == null) {
        _showMessage('PDF save cancelled.');
      } else {
        _showMessage('PDF report saved successfully.');
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to create PDF report. Please try again.');
    }
  }

  String _formatFileDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // DOWNLOAD REPORT SECTION
  // ============================================================

  Widget _buildReportDownloadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Download Financial Report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: deepForest,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Generate a detailed report for a day or date range.',
          style: TextStyle(fontSize: 14, color: mutedText),
        ),

        const SizedBox(height: 16),

        // One Day Report
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderGreen),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: mainGreen),
                  SizedBox(width: 10),
                  Text(
                    'One Day Report',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: deepForest,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                'Select a date',
                style: TextStyle(fontSize: 13, color: mutedText),
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: _selectDailyReportDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6FAF6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_rounded,
                        size: 20,
                        color: mainGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formatReportDate(selectedReportDate),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: deepForest,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: mutedText,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateDailyPdf,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Download PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Date Range Report
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderGreen),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.date_range_rounded, color: mainGreen),
                  SizedBox(width: 10),
                  Text(
                    'Date Range Report',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: deepForest,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                'From',
                style: TextStyle(fontSize: 13, color: mutedText),
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: _selectRangeStartDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6FAF6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_rounded,
                        size: 20,
                        color: mainGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formatReportDate(rangeStartDate),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: deepForest,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: mutedText,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'To',
                style: TextStyle(fontSize: 13, color: mutedText),
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: _selectRangeEndDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6FAF6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_rounded,
                        size: 20,
                        color: mainGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formatReportDate(rangeEndDate),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: deepForest,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: mutedText,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateRangePdf,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Download PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
          'Reports',

          style: TextStyle(color: deepForest, fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: _loadReportData,

            icon: const Icon(Icons.refresh, color: deepForest),

            tooltip: 'Refresh',
          ),

          const SizedBox(width: 8),
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

                onRefresh: _loadReportData,

                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),

                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),

                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 390),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // ========================================

                          // TITLE

                          // ========================================
                          const Text(
                            'Financial Overview',

                            style: TextStyle(
                              color: deepForest,

                              fontSize: 20,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Vijaya Garden • $currentMonthYear',

                            style: const TextStyle(
                              color: mutedText,

                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ========================================

                          // BALANCE

                          // ========================================
                          _buildBalanceCard(),

                          const SizedBox(height: 18),

                          // ========================================

                          // SUMMARY

                          // ========================================
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Total Income',

                                  amount: totalIncome,

                                  icon: Icons.trending_up,

                                  color: mainGreen,

                                  backgroundColor: const Color(0xFFE8F0E8),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Total Expenses',

                                  amount: totalExpenses,

                                  icon: Icons.trending_down,

                                  color: errorRed,

                                  backgroundColor: const Color(0xFFFFEBEE),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ========================================

                          // INCOME BY CATEGORY

                          // ========================================
                          const Text(
                            'Income by Category',

                            style: TextStyle(
                              color: deepForest,

                              fontSize: 18,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          if (incomeCategories.isEmpty)
                            _buildEmptyCategoryState('No income data yet.')
                          else
                            ...incomeCategories.asMap().entries.map((entry) {
                              final index = entry.key;

                              final category = entry.value;

                              return _buildCategoryCard(
                                title: category['title'].toString(),

                                amount: category['amount'] as double,

                                percentage: category['percentage'] as int,

                                icon: _getCategoryIcon(
                                  category['title'].toString(),

                                  true,
                                ),

                                color: _getCategoryColor(index, true),

                                backgroundColor: _getCategoryBackground(
                                  index,

                                  true,
                                ),
                              );
                            }),

                          const SizedBox(height: 12),

                          // ========================================

                          // EXPENSES BY CATEGORY

                          // ========================================
                          const Text(
                            'Expenses by Category',

                            style: TextStyle(
                              color: deepForest,

                              fontSize: 18,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          if (expenseCategories.isEmpty)
                            _buildEmptyCategoryState('No expense data yet.')
                          else
                            ...expenseCategories.asMap().entries.map((entry) {
                              final index = entry.key;

                              final category = entry.value;

                              return _buildCategoryCard(
                                title: category['title'].toString(),

                                amount: category['amount'] as double,

                                percentage: category['percentage'] as int,

                                icon: _getCategoryIcon(
                                  category['title'].toString(),

                                  false,
                                ),

                                color: _getCategoryColor(index, false),

                                backgroundColor: _getCategoryBackground(
                                  index,

                                  false,
                                ),
                              );
                            }),

                          const SizedBox(height: 22),

                          // ========================================

                          // PROFIT / LOSS

                          // ========================================
                          _buildProfitCard(),

                          const SizedBox(height: 24),

                          // ========================================
                          // DOWNLOAD REPORTS
                          // ========================================
                          _buildReportDownloadSection(),
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

  // BALANCE CARD

  // ============================================================

  Widget _buildBalanceCard() {
    final bool isPositive = currentBalance >= 0;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [deepForest, mainGreen],

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: gold, width: 1),

        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.18),

            blurRadius: 18,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Current Balance',

                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,

                  vertical: 7,
                ),

                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(color: gold),
                ),

                child: const Text(
                  'All Transactions',

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 11,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '₹${currentBalance.toStringAsFixed(2)}',

            style: const TextStyle(
              color: Colors.white,

              fontSize: 30,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,

                color: gold,

                size: 19,
              ),

              const SizedBox(width: 7),

              Text(
                isPositive
                    ? 'Income minus expenses'
                    : 'Expenses are higher than income',

                style: const TextStyle(color: Colors.white70, fontSize: 11),
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

    required Color color,

    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

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

                  style: const TextStyle(color: mutedText, fontSize: 12),
                ),

                const SizedBox(height: 4),

                Text(
                  '₹${amount.toStringAsFixed(0)}',

                  style: const TextStyle(
                    color: deepForest,

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

  // ============================================================

  // CATEGORY CARD

  // ============================================================

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

        border: Border.all(color: borderGreen),

        boxShadow: [
          BoxShadow(
            color: deepForest.withValues(alpha: 0.03),

            blurRadius: 6,

            offset: const Offset(0, 2),
          ),
        ],
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
                    color: deepForest,

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
                    value: (percentage / 100).clamp(0.0, 1.0),

                    minHeight: 7,

                    backgroundColor: const Color(0xFFE9EEE9),

                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                '$percentage%',

                style: const TextStyle(
                  color: mutedText,

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

  // ============================================================

  // EMPTY CATEGORY STATE

  // ============================================================

  Widget _buildEmptyCategoryState(String message) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),

      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: borderGreen),
      ),

      child: Column(
        children: [
          const Icon(Icons.bar_chart_outlined, size: 40, color: olive),

          const SizedBox(height: 8),

          Text(message, style: const TextStyle(fontSize: 12, color: mutedText)),
        ],
      ),
    );
  }

  // ============================================================

  // PROFIT / LOSS CARD

  // ============================================================

  Widget _buildProfitCard() {
    final bool isPositive = currentBalance >= 0;

    final Color mainColor = isPositive ? mainGreen : errorRed;

    final Color lightColor = isPositive
        ? const Color(0xFFE8F0E8)
        : const Color(0xFFFFEBEE);

    final Color borderColor = isPositive
        ? borderGreen
        : const Color(0xFFFFCDD2);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: lightColor,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: borderColor),
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

            child: Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,

              color: mainColor,

              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Net Result',

                  style: TextStyle(
                    color: mainColor,

                    fontSize: 14,

                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '₹${currentBalance.toStringAsFixed(0)}',

                  style: TextStyle(
                    color: mainColor,

                    fontSize: 23,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  isPositive ? 'Positive balance' : 'Negative balance',

                  style: TextStyle(
                    color: isPositive ? olive : errorRed,

                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
