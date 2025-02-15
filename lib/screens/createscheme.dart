import 'dart:convert';

import 'package:chitfunds/screens/schemelist.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateScheme extends StatefulWidget {
  final String? rights;
  const CreateScheme({Key? key, this.rights}) : super(key: key);

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _textFieldLabel = 'No of Weeks';

  final List<String> _collectionModes = ['Weekly', 'Monthly', 'Daily'];
  List<Map<String, dynamic>> _tableData = []; // Data for table rows

  void _initializeTableData() {
    _tableData = [
      for (int i = 0; i < 5; i++)
        {
          'principalamt': 0.0,
          'interestamt': 0.0,
          'savingsamt': 0.0,
          'totalCollection': 0.0,
        }
    ];
  }

  Future<void> _createScheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId = prefs.getString('staffId');
    final String? companyid = prefs.getString('companyId');
    final String apiUrl = 'https://chits.tutytech.in/scheme.php';

    try {
      // Transform `_tableData` to match expected field names in the API
      final List<Map<String, dynamic>> transformedTableData =
          _tableData.map((entry) {
        return {
          "principalamt": entry["principalAmount"],
          "interestamt": entry["interestAmount"],
          "savingsamt": entry["savingsAmount"],
          "totalCollection": entry["totalCollection"],
        };
      }).toList();

      // Encode the transformed data as JSON
      final String schemeDetailsJson = jsonEncode(transformedTableData);

      print('Sending schemedetails: $schemeDetailsJson'); // Debug

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
          'collectiontype': _selectedCollectionMode,
          'noofweeks': _weeksDaysController.text,
          'schemedetails': schemeDetailsJson,
          'entryid': staffId,
          'companyid': companyid,
        },
      );
      print('Collection Type: $_selectedCollectionMode');

      print('Response body: ${response.body}'); // Debug the response

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          _showSnackBar('Scheme created successfully!');
        } else {
          _showSnackBar('Error: ${responseData['error']}');
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchemeListPage(),
          ),
        );
      } else {
        _showSnackBar(
            'Failed to create scheme. Status code: ${response.statusCode}');
      }
    } catch (e) {
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
      drawer: CustomDrawer(rights: widget.rights),
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
            child: Form(
              key: _formKey, // Added a Form with a GlobalKey
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Scheme ID field
                  TextFormField(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a scheme ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Scheme Name field
                  TextFormField(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a scheme name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Row with Loan Amount, Collection Mode, and No. of Weeks/Days
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a collection mode';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the number of $_textFieldLabel';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onChanged: _generateRows,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Table Header
                  if (_tableData.isNotEmpty)
                    Container(
                      color: Colors.grey[300],
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
                          ...[
                            'Principal Amount',
                            'Interest Amount',
                            'Savings Amount',
                            'Total Collection'
                          ]
                              .map((header) => Expanded(
                                    child: Text(
                                      header,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ))
                              .toList(),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF4A90E2),
                                            Color(0xFF50E3C2)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        border:
                                            Border.all(color: Colors.black26),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        '${row['sNo']}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...[
                                    'principalAmount',
                                    'interestAmount',
                                    'savingsAmount'
                                  ]
                                      .map((key) => Expanded(
                                            child: TextFormField(
                                              initialValue: row[key].toString(),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              textAlign: TextAlign.center,
                                              onChanged: (value) {
                                                setState(() {
                                                  row[key] =
                                                      double.tryParse(value) ??
                                                          0.0;
                                                  _updateTotalCollection(
                                                      _tableData.indexOf(row));
                                                });
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Required';
                                                }
                                                if (double.tryParse(value) ==
                                                    null) {
                                                  return 'Invalid number';
                                                }
                                                return null;
                                              },
                                            ),
                                          ))
                                      .toList(),
                                  Expanded(
                                    child: Text(
                                      row['totalCollection'].toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _createScheme();
                                // Save the scheme
                                print('Scheme is valid and saved');
                              }
                            },
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SchemeListPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
