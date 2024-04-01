import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/transaction.dart';
import 'package:expense_tracker/database_manager.dart';
import 'package:expense_tracker/transaction_model.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late List<TransactionModel> transactions;
  final List<String> weekdays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun"
  ];
  late List<double> heights;
  late List<double> percentages;
  late double max;
  late TextEditingController expense;
  late TextEditingController price;
  late DateTime current;
  late DateTime selectedDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initializeVariables();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    List<TransactionModel> transactions =
        await DatabaseManager.instance.getTransactions();
    setState(() {
      this.transactions = transactions;
    });
  }

  void initializeVariables() {
    heights = List.filled(31, 0); // Initialize heights with 31 days
    percentages = List.filled(
        31, 10); // Initialize percentages with 31 days, defaulting to 10%
    transactions = [];
    max = 0;
    expense = TextEditingController(text: "");
    price = TextEditingController(text: "");
    current = DateTime.now();
    selectedDate = DateTime.now();
  }

  void addTransaction() async {
    await DatabaseManager.instance.insertTransaction(TransactionModel(
      id: transactions.length,
      price: double.parse(price.text),
      title: expense.text,
      date: selectedDate,
    ));

    setState(() {
      int day = selectedDate.day; // Get the day of the transaction
      heights[day - 1] += double.parse(price.text); // Update heights list
      calculatePercentages(); // Recalculate percentages
      // Replace Transaction with TransactionModel
      transactions.add(TransactionModel(
        id: transactions.length,
        price: double.parse(price.text),
        title: expense.text,
        date: selectedDate,
      ));
    });
    // Clear text controllers after adding transaction
    expense.clear();
    price.clear();
  }

  void delete(int id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this transaction?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if confirmed
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if canceled
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // Proceed with deletion
      await DatabaseManager.instance.deleteTransaction(id);

      setState(() {
        // Update to remove TransactionModel
        TransactionModel a =
            transactions.firstWhere((element) => element.id == id);
        int day = a.date.day; // Get the day of the transaction
        heights[day - 1] -= a.price; // Update heights list
        if (heights[day - 1] == 0) {
          percentages[day - 1] = 10;
        }
        transactions.remove(a);
        calculatePercentages();
      });
    }
  }

  void calculatePercentages() {
    max = heights.reduce((value, element) => value > element ? value : element);
    for (int i = 0; i < 7; i++) {
      if (heights[i] > 0) {
        percentages[i] = (heights[i] * 100) / max;
        if (percentages[i] < 10) {
          percentages[i] = 10;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChart(),
              _buildTransactionsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) => _buildAddTransactionBottomSheet(context),
          );
        },
        backgroundColor: const Color.fromARGB(255, 37, 124, 224),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChart() {
    double totalExpense =
        transactions.fold(0, (sum, transaction) => sum + (transaction.price));

    // Find the earliest and latest transaction dates
    DateTime earliestDate = findEarliestDate();
    DateTime latestDate = findLatestDate();

    // Format dates
    String startDateString =
        "${earliestDate.day}/${earliestDate.month}/${earliestDate.year}";
    String endDateString =
        "${latestDate.day}/${latestDate.month}/${latestDate.year}";

    // Find the day with the highest expense
    String highestExpenseDay = findHighestExpenseDay();

    // Calculate the number of days in the current month
    int daysInMonth = DateTime(
      current.year,
      current.month + 1,
      0,
    ).day;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$startDateString - $endDateString', // Display the date range
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Optionally, change the color to highlight
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Total Expense: ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${totalExpense.toStringAsFixed(2)}', // Display total expense with ₹ symbol
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors
                      .green, // Optionally, change the color to indicate currency
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Highest Expense: $highestExpenseDay', // Display the highest expense day
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red, // Optionally, change the color to highlight
            ),
          ),
        ),
        Card(
          child: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < daysInMonth; i++)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: percentages[
                                i], // Use i as index instead of loop index
                            width: 50,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadiusDirectional.all(
                                  Radius.elliptical(20, 20)),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color.fromARGB(255, 58, 100, 172),
                                  Color.fromARGB(255, 96, 169, 209)
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                heights[i].toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Text('${i + 1}')
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  DateTime findEarliestDate() {
    DateTime earliestDate = DateTime.now();

    for (TransactionModel transaction in transactions) {
      if (transaction.date.isBefore(earliestDate)) {
        earliestDate = transaction.date;
      }
    }

    return earliestDate;
  }

  DateTime findLatestDate() {
    DateTime latestDate = DateTime.now();

    for (TransactionModel transaction in transactions) {
      if (transaction.date.isAfter(latestDate)) {
        latestDate = transaction.date;
      }
    }

    return latestDate;
  }

  String findHighestExpenseDay() {
    double highestExpense = 0;
    String highestExpenseDay = "";

    for (int i = 0; i < 7; i++) {
      if (heights[i] > highestExpense) {
        highestExpense = heights[i];
        highestExpenseDay = weekdays[i];
      }
    }

    return highestExpenseDay;
  }

  Widget _buildTransactionsList() {
    return Card(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              "Transactions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          SizedBox(
            height: 400,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return Transaction(
                  transactions[index].id,
                  transactions[index].price.toString(),
                  transactions[index].title,
                  delete,
                  transactions[index].date,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddTransactionBottomSheet(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(""),
                const Text(
                  "Add Transaction",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: MaterialButton(
                    color: Colors.red,
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "X",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Center(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: expense,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'Enter your Expense',
                      labelText: 'Expense',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z]+$')),
                    ],
                  ),
                  TextFormField(
                    controller: price,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.monetization_on_outlined),
                      hintText: 'Enter the price',
                      labelText: 'Price',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*.?\d*)'))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Icon(Icons.calendar_month_outlined),
                        Text(
                            " ${weekdays[selectedDate.weekday - 1]} ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            minimumSize: const Size(40, 30),
                            maximumSize: const Size(100, 30),
                          ),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(
                                  current.year, current.month, DateTime.monday),
                              lastDate: current,
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: const Center(
                            child: Text("Select Date"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 150.0, top: 40.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          addTransaction();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
