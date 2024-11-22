import 'dart:convert';

import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  void _initializeTableData() {
    _tableData = [
      for (int i = 0; i < 5; i++)
        {
          'principalAmount': 0.0,
          'interestAmount': 0.0,
          'savingsAmount': 0.0,
          'totalCollection': 0.0,
        }
    ];
  }

  Future<void> _createScheme() async {
    final String apiUrl = 'https://chits.tutytech.in/scheme.php';

    try {
      // Print the request URL and body for debugging
      print('Request URL: $apiUrl');
      print('Request body: ${{
        'type': 'insert',
        'schemeid': _schemeIdController.text,
        'schemename': _schemeNameController.text,
        'amount': _loanAmountController.text,
        'collectiontype': _weeksDaysController.text,
      }}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'insert',
          'schemeid': _schemeIdController.text,
          'schemename': _schemeNameController.text,
          'amount': _loanAmountController.text,
          'collectiontype': _weeksDaysController.text,
        },
      );

      // Print the response body for debugging
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData[0]['id'] != null) {
          _showSnackBar('Staff created successfully!');
        } else {
          _showSnackBar('Error: ${responseData[0]['error']}');
        }
      } else {
        _showSnackBar(
            'Failed to create center. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Print the error for debugging
      print('Error: $e');
      _showSnackBar('An error occurred: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Update total collection for a given row
  void _updateTotalCollection(int index) {
    final row = _tableData[index];

    // Calculate the total collection
    double total =
        row['principalAmount'] + row['interestAmount'] + row['savingsAmount'];

    // Update the total collection value for this row
    setState(() {
      row['totalCollection'] = total;
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
                          width: 0.5, // Reduced width for the separator
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
                          width: 0.5, // Reduced width for the separator
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
                                        horizontal: 8.0, vertical: 4.0),
                                    height: 38,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    child: TextFormField(
                                      initialValue:
                                          row['principalAmount'].toString(),
                                      decoration: const InputDecoration(
                                        hintText: 'Principal Amount',
                                        border: InputBorder.none,
                                      ),
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        setState(() {
                                          row['principalAmount'] =
                                              double.tryParse(value) ?? 0.0;
                                          _updateTotalCollection(
                                              _tableData.indexOf(row));
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal:
                                            4.0), // Space between columns
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 5.0),
                                    height: 38,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    child: TextFormField(
                                      initialValue:
                                          row['interestAmount'].toString(),
                                      decoration: const InputDecoration(
                                        hintText: 'Interest Amount',
                                        border: InputBorder.none,
                                      ),
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        setState(() {
                                          row['interestAmount'] =
                                              double.tryParse(value) ?? 0.0;
                                          _updateTotalCollection(
                                              _tableData.indexOf(row));
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal:
                                            2.0), // Reduced horizontal space for width control
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            4.0), // Adjusted padding for reduced height
                                    height:
                                        38, // Set a fixed height for the container to control height
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    child: TextFormField(
                                      initialValue:
                                          row['savingsAmount'].toString(),
                                      decoration: const InputDecoration(
                                        hintText: 'Savings Amount',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 0.0,
                                            horizontal:
                                                4.0), // Reduce internal padding to match height and width
                                      ),
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        setState(() {
                                          row['savingsAmount'] =
                                              double.tryParse(value) ?? 0.0;
                                          _updateTotalCollection(
                                              _tableData.indexOf(row));
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal:
                                            4.0), // Space between columns
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        // Apply gradient background
                                        colors: [
                                          Color(0xFF4A90E2),
                                          Color(0xFF50E3C2)
                                        ],
                                      ),
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    child: Text(
                                      row['totalCollection'].toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
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
                      _createScheme();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Scheme Created Successfully')),
                      );
                    },
                    child: const Text(
                      'Create Scheme',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
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
