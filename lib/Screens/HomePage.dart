// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:async';
import 'package:budget_tracker/Models/BudgetEntry.dart';
import 'package:budget_tracker/Models/Category.dart';
import 'package:budget_tracker/Models/ChartModels.dart';
import 'package:budget_tracker/Screens/AddEntryDialog.dart';
import 'package:budget_tracker/Screens/SetBudgetDialog.dart';
import 'package:budget_tracker/Widgets/BudgetEntryTile.dart';
import 'package:budget_tracker/Widgets/Charts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_tracker/Screens/Drawer.dart';
import 'package:budget_tracker/Services/FireBase.dart';
import 'package:budget_tracker/Services/SignIn.dart';
import 'package:budget_tracker/Widgets/Custom_Buttons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user = FirebaseAuth.instance.currentUser;
  StreamSubscription<User?>? _authSubscription;

  // --- REMOVED _totalSpentThisMonth ---
  double _monthlyBudget = 0.0;
  // REMOVED: StreamSubscription<List<BudgetEntry>>? _monthlySpendingSubscription;
  final String _currentYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  final DateTime _now = DateTime.now();

  Stream<List<Category>>? _categoryStream;
  Stream<List<BudgetEntry>>? _entryStream; // For ALL entries
  Stream<List<BudgetEntry>>? _monthlyEntryStream; // For MONTHLY entries

  @override
  void initState() {
    super.initState();
    _updateStreamsAndBudget(_user); // Initial setup

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      // Check if mounted before calling setState to avoid errors if disposed
      if (mounted) {
        setState(() { _user = user; });
        _updateStreamsAndBudget(user); // Update on auth change
      }
      if (user != null) { print("Auth state changed: User is logged in."); }
      else { print("Auth state changed: User is logged out."); }
    });
  }

  /// Helper method to initialize/update streams AND load budget
  void _updateStreamsAndBudget(User? user) {
    // REMOVED: _monthlySpendingSubscription?.cancel();

    if (user == null) {
      _categoryStream = Stream.value(<Category>[]).asBroadcastStream();
      _entryStream = Stream.value(<BudgetEntry>[]).asBroadcastStream();
      _monthlyEntryStream = Stream.value(<BudgetEntry>[]).asBroadcastStream();
      if (mounted) {
        setState(() {
          _monthlyBudget = 0.0;
          // REMOVED: _totalSpentThisMonth = 0.0;
        });
      }
    } else {
      _categoryStream = FireBaseMethods().getCategories();
      _entryStream = FireBaseMethods().getBudgetEntries();
      _monthlyEntryStream = FireBaseMethods().getBudgetEntriesForMonth(_now.year, _now.month);
      _loadBudget();

      // REMOVED: _monthlySpendingSubscription = _monthlyEntryStream!.listen((entries) {
      // REMOVED:  _calculateSpending(entries);
      // REMOVED: });
    }
  }

  /// Fetches the budget for the current month
  Future<void> _loadBudget() async {
    final budget = await FireBaseMethods().getMonthlyBudget(_currentYearMonth);
    if (mounted) {
      setState(() {
        _monthlyBudget = budget ?? 0.0;
      });
    }
  }

  // REMOVED: _calculateSpending method

  @override
  void dispose() {
    _authSubscription?.cancel();
    // REMOVED: _monthlySpendingSubscription?.cancel();
    super.dispose();
  }

  /// Process data for the pie chart (uses monthly entries)
  List<PieChartData> _prepareChartData(
      List<BudgetEntry> monthlyEntries, List<Category> categories) {
    Map<String, double> categoryTotals = {};
    Map<String, Color> categoryColors = {};
    for (var category in categories) {
      categoryTotals[category.id] = 0.0;
      categoryColors[category.id] = category.color;
    }
    for (var entry in monthlyEntries) {
      if (categoryTotals.containsKey(entry.categoryId)) {
        categoryTotals[entry.categoryId] =
            categoryTotals[entry.categoryId]! + entry.cost;
      }
    }
    return categories
        .map((category) {
          return PieChartData(
            category.name,
            categoryTotals[category.id] ?? 0.0,
            categoryColors[category.id] ?? Colors.grey,
          );
        })
        .where((data) => data.sales > 0)
        .toList();
  }

  /// Shows the Add/Edit Entry Dialog
  void _showAddEntry(List<Category> categories, {BudgetEntry? entryToEdit}) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEntryDialog(
          categories: categories,
          entryToEdit: entryToEdit,
        );
      },
    );
  }

  /// Shows Set Budget Dialog
  void _showSetBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => SetBudgetDialog(
        currentYearMonth: _currentYearMonth,
        initialBudget: _monthlyBudget,
      ),
    ).then((_) {
      _loadBudget(); // Reload budget after dialog closes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        title: Text('Budget Tracker'),
        centerTitle: true,
        actions: [
          if (_user != null)
            IconButton(
              icon: Icon(Icons.edit_note),
              tooltip: 'Set Monthly Budget',
              onPressed: _showSetBudgetDialog,
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton:
          _user == null ? null : StreamBuilder<List<Category>>(
              stream: _categoryStream,
              builder: (context, categorySnapshot) {
                if (!categorySnapshot.hasData || categorySnapshot.data!.isEmpty) {
                  return SizedBox();
                }
                return FloatingActionButton(
                  onPressed: () => _showAddEntry(categorySnapshot.data!),
                  child: Icon(Icons.add),
                );
              },
            ),
    );
  }

  Widget _buildBody() {
    if (_user == null) {
      // Login Screen
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome!', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 20),
            CustomIconButton(
              icon: FontAwesomeIcons.google,
              onPressed: () {
                SignInMethods().signInGoogle(context);
              },
              backgroundColor: Colors.blue,
            ),
          ],
        ),
      );
    }

    // Main Dashboard
    return StreamBuilder<List<Category>>(
      stream: _categoryStream,
      builder: (context, categorySnapshot) {
        return StreamBuilder<List<BudgetEntry>>(
          stream: _entryStream, // Stream for ALL entries
          builder: (context, entrySnapshot) {
            return StreamBuilder<List<BudgetEntry>>(
              stream: _monthlyEntryStream, // Stream for MONTHLY entries
              builder: (context, monthlyEntrySnapshot) {

                if (categorySnapshot.connectionState == ConnectionState.waiting ||
                    entrySnapshot.connectionState == ConnectionState.waiting ||
                    monthlyEntrySnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!categorySnapshot.hasData || categorySnapshot.data!.isEmpty) {
                  return Center( /* ... "add category" message ... */);
                }

                final categories = categorySnapshot.data!;
                final allEntries = entrySnapshot.hasData ? entrySnapshot.data! : <BudgetEntry>[];
                final monthlyEntries = monthlyEntrySnapshot.hasData ? monthlyEntrySnapshot.data! : <BudgetEntry>[];

                // --- CALCULATION MOVED HERE ---
                double totalSpentThisMonth = 0.0;
                for (var entry in monthlyEntries) {
                  totalSpentThisMonth += entry.cost;
                }
                // --- END OF MOVE ---

                final categoryMap = {for (var cat in categories) cat.id: cat};
                final chartData = _prepareChartData(monthlyEntries, categories);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Pass calculated value ---
                    _BudgetSummaryCard(
                      totalBudget: _monthlyBudget,
                      totalSpent: totalSpentThisMonth, // Pass calculated value
                    ),
                    // --- End ---

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Spending Summary (This Month)', style: Theme.of(context).textTheme.headlineSmall),
                    ),
                    SizedBox(
                      height: 220,
                      child: chartData.isEmpty
                          ? Center(child: Text('No spending data this month.'))
                          : PieChart(piedate: chartData),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('All Entries', style: Theme.of(context).textTheme.headlineSmall),
                    ),
                    Expanded(
                      child: allEntries.isEmpty
                          ? Center(child: Text('No entries yet. Tap + to add one!'))
                          : ListView.builder(
                              itemCount: allEntries.length,
                              itemBuilder: (context, index) {
                                final entry = allEntries[index];
                                final category = categoryMap[entry.categoryId] ?? Category(id: 'unknown', name: 'Unknown', color: Colors.grey);
                                return BudgetEntryTile(
                                  entry: entry,
                                  category: category,
                                  onTap: () => _showAddEntry(categories, entryToEdit: entry),
                                  onDismissed: () {
                                    FireBaseMethods().deleteBudgetEntry(entry.id);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text('Deleted ${entry.itemName}'),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () => FireBaseMethods().addBudgetEntry(
                                          itemName: entry.itemName, cost: entry.cost, categoryId: entry.categoryId,
                                        ),
                                      ),
                                    ));
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

// --- Budget Summary Widget (Unchanged) ---
class _BudgetSummaryCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;

  const _BudgetSummaryCard({required this.totalBudget, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    final double remaining = totalBudget - totalSpent;
    final bool overBudget = remaining < 0;
    final String monthName = DateFormat('MMMM yyyy').format(DateTime.now());

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budget for $monthName', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBudgetItem('Total Budget', totalBudget, context),
                _buildBudgetItem('Spent', totalSpent, context, isSpent: true),
                _buildBudgetItem('Remaining', remaining, context, colorOverride: overBudget ? Colors.redAccent : Colors.green),
              ],
            ),
            if (totalBudget > 0) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: totalBudget == 0 ? 0 : (totalSpent / totalBudget).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(overBudget ? Colors.redAccent : Colors.blue),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetItem(String label, double amount, BuildContext context, {bool isSpent = false, Color? colorOverride}) {
    final amountStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorOverride ?? (isSpent ? Colors.redAccent : null),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text('₹${amount.toStringAsFixed(0)}', style: amountStyle),
      ],
    );
  }
}