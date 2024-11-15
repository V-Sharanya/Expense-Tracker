import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.lightBlue[50],
      ),
      home: StartingPage(), // Start with the starting page
    );
  }
}

class StartingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome to Expense Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Track your expenses effectively!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ExpenseHomePage()),
                );
              },
              child: Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({Key? key}) : super(key: key);

  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  int _selectedIndex = 0; // Default to Expenses Page (0 for expenses)

  // List to hold expenses data (Expense Name, Amount, Date, Category)
  List<Map<String, dynamic>> expenses = [
    {
      'name': 'Groceries',
      'amount': 200.0,
      'date': DateTime.now(),
      'category': 'Food',
    },
    {
      'name': 'Transport',
      'amount': 100.0,
      'date': DateTime.now().subtract(Duration(days: 1)),
      'category': 'Transport',
    },
    {
      'name': 'Dinner at Restaurant',
      'amount': 300.0,
      'date': DateTime.now().subtract(Duration(days: 2)),
      'category': 'Food',
    },
    {
      'name': 'Gym Membership',
      'amount': 150.0,
      'date': DateTime.now().subtract(Duration(days: 3)),
      'category': 'Fitness',
    },
  ];

  // Form input controllers
  final _expenseController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Date selection

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addExpense() {
    String expenseName = _expenseController.text;
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    String category = _categoryController.text;

    if (expenseName.isEmpty || amount <= 0 || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid expense details')),
      );
      return;
    }

    setState(() {
      expenses.add({
        'name': expenseName,
        'amount': amount,
        'date': _selectedDate, // Use the selected date
        'category': category,
      });

      _expenseController.clear();
      _amountController.clear();
      _categoryController.clear();
      _selectedDate = DateTime.now(); // Reset to current date after adding
    });

    Navigator.of(context).pop(); // Close the dialog
  }

  void _deleteExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
  }

  Widget _buildDashboard() {
    // Calculate total expense per category
    Map<String, double> categoryExpenses = {};
    for (var expense in expenses) {
      String category = expense['category'];
      double amount = expense['amount'];
      if (categoryExpenses.containsKey(category)) {
        categoryExpenses[category] = categoryExpenses[category]! + amount;
      } else {
        categoryExpenses[category] = amount;
      }
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < categoryExpenses.keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              categoryExpenses.keys.elementAt(value.toInt()),
                              style: TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: categoryExpenses.entries
                    .toList()
                    .asMap()
                    .map((index, entry) => MapEntry(
                  index,
                  BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ))
                    .values
                    .toList(),
              ),
            ),
          ),
        ),
        // Display total expenses
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Expenses: ₹${expenses.fold(0.0, (sum, item) => sum + item['amount'])}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Allows scrolling horizontally
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Expense Name')),
          DataColumn(label: Text('Amount (₹)')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Actions')),
        ],
        rows: List.generate(
          expenses.length,
              (index) => DataRow(
            cells: [
              DataCell(Text(expenses[index]['name'])),
              DataCell(Text(expenses[index]['amount'].toStringAsFixed(2))),
              DataCell(Text(DateFormat('dd/MM/yyyy').format(expenses[index]['date']))),
              DataCell(Text(expenses[index]['category'])),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteExpense(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesPage() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildExpensesTable(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _showAddExpenseDialog,
            child: Text('Add Expense'),
          ),
        ),
      ],
    );
  }

  void _showAddExpenseDialog() {
    // Reset the selected date for the dialog
    DateTime tempSelectedDate = _selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _expenseController,
                  decoration: InputDecoration(labelText: 'Expense Name'),
                ),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount (₹)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                SizedBox(height: 10),
                Text(
                  'Select Date: ${DateFormat('dd/MM/yyyy').format(tempSelectedDate)}',
                  style: TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: tempSelectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      tempSelectedDate = pickedDate;
                    }
                  },
                  child: Text('Pick Date'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _selectedDate = tempSelectedDate; // Update selected date
                _addExpense();
              },
              child: Text('Add Expense'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Tracker', // AppBar title
          style: TextStyle(
            color: Colors.white, // Text color set to white
            fontWeight: FontWeight.bold, // Bold text
            fontSize: 24, // Increased font size
          ),
        ),
        backgroundColor: Colors.blue, // AppBar background color
      ),
      body: Center(
        child: _selectedIndex == 0
            ? _buildExpensesPage() // Show expenses page first
            : _buildDashboard(), // Show dashboard page
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
