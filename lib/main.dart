import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/transaction.dart';

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
  late List<Transaction> transactions;
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
  }

  void initializeVariables() {
    heights = List.filled(7, 0);
    percentages = List.filled(7, 10);
    transactions = [];
    max = 0;
    expense = TextEditingController(text: "");
    price = TextEditingController(text: "");
    current = DateTime.now();
    selectedDate = DateTime.now();
  }

  void addTransaction() {
    setState(() {
      heights[selectedDate.weekday - 1] += double.parse(price.text);
      calculatePercentages();
      transactions.add(Transaction(
          transactions.length, price.text, expense.text, delete, selectedDate));
    });
  }

  void delete(int id) {
    setState(() {
      Transaction a = transactions.firstWhere((element) => element.id == id);
      heights[a.date.weekday - 1] -= double.parse(a.price);
      if (heights[a.date.weekday - 1] == 0) {
        percentages[a.date.weekday - 1] = 10;
      }
      transactions.remove(a);
      calculatePercentages();
    });
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
  double totalExpense = transactions.fold(0, (sum, transaction) => sum + double.parse(transaction.price));

  return Column(
    children: [
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
                color: Colors.green, // Optionally, change the color to indicate currency
              ),
            ),
          ],
        ),
      ),
      Card(
        child: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < 7; i++)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: percentages[i],
                        width: 40,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadiusDirectional.all(Radius.elliptical(20, 20)),
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
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Text(weekdays[i])
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
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
                return transactions[index];
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
