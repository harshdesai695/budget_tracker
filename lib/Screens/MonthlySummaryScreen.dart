import 'dart:async';
import 'package:budget_tracker/Models/BudgetEntry.dart';
import 'package:budget_tracker/Services/FireBase.dart';
import 'package:budget_tracker/Screens/SetBudgetDialog.dart'; // Import the dialog
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  DateTime _selectedDate = DateTime.now(); // Start with the current month
  double _monthlyBudget = 0.0;
  double _totalSpentThisMonth = 0.0;
  Stream<List<BudgetEntry>>? _monthlyEntryStream;
  StreamSubscription<List<BudgetEntry>>? _spendingSubscription;
  bool _isLoadingBudget = true; // Start in loading state for budget

  @override
  void initState() {
    super.initState();
    _loadDataForSelectedMonth();
  }

  @override
  void dispose() {
    _spendingSubscription?.cancel();
    super.dispose();
  }

  void _loadDataForSelectedMonth() {
    if (!mounted) return;

    setState(() {
      _isLoadingBudget = true;
      _monthlyBudget = 0.0;
      _totalSpentThisMonth = 0.0;
    });

    _spendingSubscription?.cancel();
    final year = _selectedDate.year;
    final month = _selectedDate.month;
    final yearMonthString = DateFormat('yyyy-MM').format(_selectedDate);

    // Fetch the budget
    FireBaseMethods()
        .getMonthlyBudget(yearMonthString)
        .then((budget) {
          if (mounted) {
            setState(() {
              _monthlyBudget = budget ?? 0.0;
              _isLoadingBudget = false;
            });
          }
        })
        .catchError((error) {
          print("Error loading budget: $error");
          if (mounted) {
            setState(() {
              _isLoadingBudget = false;
            });
          }
        });

    _monthlyEntryStream = FireBaseMethods().getBudgetEntriesForMonth(
      year,
      month,
    );

    _spendingSubscription = _monthlyEntryStream!.listen(
      (entries) {
        double total = 0.0;
        for (var entry in entries) {
          total += entry.cost;
        }
        if (mounted) {
          setState(() {
            _totalSpentThisMonth = total;
          });
        }
      },
      onError: (error) {
        print("Error in monthly entry stream: $error");
      },
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
    _loadDataForSelectedMonth();
  }

  void _goToNextMonth() {
    DateTime nextMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      1,
    );
    DateTime currentMonthStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      1,
    );
    if (nextMonth.isAfter(currentMonthStart)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cannot view future months")));
      return;
    }
    setState(() {
      _selectedDate = nextMonth;
    });
    _loadDataForSelectedMonth();
  }

  void _showSetBudgetDialog() {
    final yearMonthString = DateFormat('yyyy-MM').format(_selectedDate);
    showDialog(
      context: context,
      builder: (context) => SetBudgetDialog(
        currentYearMonth: yearMonthString,
        initialBudget: _monthlyBudget,
      ),
    ).then((_) {
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) _loadDataForSelectedMonth();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy').format(_selectedDate);
    final remaining = _monthlyBudget - _totalSpentThisMonth;
    final bool overBudget = remaining < 0;

    DateTime nextMonthDate = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      1,
    );
    bool canGoNext =
        nextMonthDate.isBefore(DateTime.now()) ||
        nextMonthDate.year == DateTime.now().year &&
            nextMonthDate.month == DateTime.now().month;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Summary'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_note),
            tooltip: 'Set Budget for $monthName',
            onPressed: _showSetBudgetDialog, // Call the dialog
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Navigation Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _goToPreviousMonth,
                  tooltip: 'Previous Month',
                ),
                Text(
                  monthName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  // Disable button if we can't go to the next month
                  onPressed: canGoNext ? _goToNextMonth : null,
                  tooltip: 'Next Month',
                  color: canGoNext
                      ? Theme.of(context).iconTheme.color
                      : Colors.grey, // Visual cue for disabled
                ),
              ],
            ),
          ),

          // Budget Summary Card
          Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Summary', // Simplified title
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  _isLoadingBudget
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildBudgetItem(
                                  'Total Budget',
                                  _monthlyBudget,
                                  context,
                                ),
                                _buildBudgetItem(
                                  'Spent',
                                  _totalSpentThisMonth,
                                  context,
                                  isSpent: true,
                                ),
                                _buildBudgetItem(
                                  'Remaining',
                                  remaining,
                                  context,
                                  colorOverride: overBudget
                                      ? Colors.redAccent
                                      : Colors.green,
                                ),
                              ],
                            ),
                            if (_monthlyBudget > 0) ...[
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: _monthlyBudget == 0
                                    ? 0
                                    : (_totalSpentThisMonth / _monthlyBudget)
                                          .clamp(0.0, 1.0),
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  overBudget ? Colors.redAccent : Colors.blue,
                                ),
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ] else if (!_isLoadingBudget) ...[
                              // Show message if budget not set
                              const SizedBox(height: 10),
                              Center(
                                child: Text(
                                  "Budget not set for this month.",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ],
                        ),
                ],
              ),
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Text(
              'Entries for $monthName',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // List of Entries for the selected month
          Expanded(
            child: StreamBuilder<List<BudgetEntry>>(
              stream: _monthlyEntryStream,
              builder: (context, snapshot) {
                // Show loading indicator only when budget is also loading initially
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _isLoadingBudget) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Handle stream errors
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading entries: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('No entries found for $monthName.'),
                    ),
                  );
                }

                final entries = snapshot.data!;
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      dense: true, // Make list items a bit smaller
                      title: Text(entry.itemName),
                      subtitle: Text(
                        DateFormat.yMMMd().format(entry.timestamp.toDate()),
                      ),
                      trailing: Text(
                        '₹${entry.cost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Consider adding onTap for edit/delete here if desired
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget
  Widget _buildBudgetItem(
    String label,
    double amount,
    BuildContext context, {
    bool isSpent = false,
    Color? colorOverride,
  }) {
    final amountStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: colorOverride ?? (isSpent ? Colors.redAccent : null),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text('₹${NumberFormat("#,##0").format(amount)}', style: amountStyle),
      ],
    );
  }
}
