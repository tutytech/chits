import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';

class CreateScheme extends StatefulWidget {
  const CreateScheme({Key? key}) : super(key: key);

  @override
  _CreateSchemeState createState() => _CreateSchemeState();
}

class _CreateSchemeState extends State<CreateScheme> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _schemeIdController = TextEditingController();
  final TextEditingController _schemeNameController = TextEditingController();
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _weeksDaysController = TextEditingController();
  TextEditingController _principalController = TextEditingController();
  TextEditingController _interestController = TextEditingController();
  TextEditingController _savingsController = TextEditingController();
  String _selectedCollectionMode = 'Weekly';
  String _textFieldLabel = 'No of Weeks';

  final List<String> _collectionModes = ['Weekly', 'Monthly', 'Daily'];
  List<Map<String, dynamic>> _tableData = []; // Data for table rows
  void _updateTotalCollection(int index) {
    double principalAmount = double.tryParse(_principalController.text) ?? 0;
    double interestAmount = double.tryParse(_interestController.text) ?? 0;
    double savingsAmount = double.tryParse(_savingsController.text) ?? 0;

    // Calculate the new total collection
    double totalCollection = principalAmount + interestAmount + savingsAmount;

    setState(() {
      _tableData[index]['totalCollection'] = totalCollection;
    });
  }

  void _updateTextFieldLabel(String mode) {
    setState(() {
      _selectedCollectionMode = mode;
      if (mode == 'Weekly') {
        _textFieldLabel = 'No of Weeks';
      } else if (mode == 'Daily') {
        _textFieldLabel = 'No of Days';
      } else if (mode == 'Monthly') {
        _textFieldLabel = 'No of Months';
      }
    });
  }

  void _generateRows(String value) {
    final rowCount = int.tryParse(value) ?? 0;
    setState(() {
      _tableData = List.generate(rowCount, (index) {
        return {
          'sNo': index + 1,
          'principalAmount': 0.0,
          'interestAmount': 0.0,
          'savingsAmount': 0.0,
          'totalCollection': 0.0,
        };
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Create Scheme',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer(); // Open drawer using the key
        },
      ),
      drawer: CustomDrawer(),
      body: Stack(children: [
        // Background Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Scheme ID field
                TextField(
                  controller: _schemeIdController,
                  decoration: InputDecoration(
                    labelText: 'Enter Scheme ID',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Scheme Name field
                TextField(
                  controller: _schemeNameController,
                  decoration: InputDecoration(
                    labelText: 'Enter Scheme Name',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Row with Loan Amount, Collection Mode, and No. of Weeks/Days
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _loanAmountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCollectionMode,
                        items: _collectionModes
                            .map((mode) => DropdownMenuItem(
                                  value: mode,
                                  child: Text(mode),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _updateTextFieldLabel(value);
                          }
                        },
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _weeksDaysController,
                        decoration: InputDecoration(
                          labelText: _textFieldLabel,
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: _generateRows,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Table Header
                if (_tableData.isNotEmpty)
                  // Table Header

// Table Rows
                  // Table Rows
                  Container(
                    color: Colors.grey[300], // Updated header background color
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'S.No',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: 1, // Width of the divider
                          color: Colors.black, // Divider color
                        ),
                        Expanded(
                          child: Text(
                            'Principal Amount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          color: Colors.black,
                        ),
                        Expanded(
                          child: Text(
                            'Interest Amount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          color: Colors.black,
                        ),
                        Expanded(
                          child: Text(
                            'Savings Amount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          color: Colors.black,
                        ),
                        Expanded(
                          child: Text(
                            'Total Collection',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Table Rows
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    children: _tableData.map((row) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0), // Space above and below rows
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal:
                                            4.0), // Space between columns
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF4A90E2),
                                          Color(0xFF50E3C2)
                                        ], // Gradient colors
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(color: Colors.black26),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      '${row['sNo']}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors
                                            .white, // Ensures text is readable on a gradient
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal:
                                            4.0), // Space between columns
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4), // Adjust inner padding
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black26),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: TextField(
                                        controller: TextEditingController(
                                            text:
                                                '${row['principalAmount']}'), // Pre-filled with existing value
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          isDense:
                                              true, // Minimizes the height of the TextField
                                          contentPadding: EdgeInsets
                                              .zero, // Removes extra padding
                                          border:
                                              InputBorder.none, // No underline
                                        ),
                                        style: const TextStyle(
                                            fontSize:
                                                14), // Adjust font size if needed
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal:
                                            6.0), // Space between columns
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4), // Adjust inner padding
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black26),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: TextField(
                                        controller: TextEditingController(
                                            text:
                                                '${row['interestAmount']}'), // Pre-filled with existing value
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal:
                                            6.0), // Space between columns
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4), // Adjust inner padding
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black26),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: TextField(
                                        controller: TextEditingController(
                                            text:
                                                '${row['savingsAmount']}'), // Pre-filled with existing value
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal:
                                            6.0), // Space between columns
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF4A90E2),
                                          Color(0xFF50E3C2)
                                        ], // Gradient colors
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(color: Colors.black26),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      '${row['totalCollection']}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors
                                            .white, // Ensures text is readable on the gradient background
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8), // Space between rows
                        ],
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 30),

                // Create Scheme button
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle create scheme action here
                    },
                    child: const Text(
                      'Create Scheme',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
