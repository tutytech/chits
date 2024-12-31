import 'dart:convert';

import 'package:chitfunds/screens/schemelist.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditScheme extends StatefulWidget {
  final String? id; // Pass the branch ID to load specific data

  const EditScheme({Key? key, this.id}) : super(key: key);

  @override
  _CreateSchemeState createState() => _CreateSchemeState();
}

class _CreateSchemeState extends State<EditScheme> {
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
  bool isLoading = true;
  @override
  void initState() {
    super.initState();

    if (widget.id != null) {
      fetchSchemes(widget.id!);
    } else {
      _showError('Invalid branch ID provided.');
    }
  }

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

  void _updateBranchFields(Map<String, dynamic> branch) {
    _schemeIdController.text = branch['schemeid'] ?? '';
    _schemeNameController.text = branch['schemename']?.toString() ?? '';
    _loanAmountController.text = branch['amount'] ?? '';
    _weeksDaysController.text = branch['collectiontype'] ?? '';
  }

  Future<void> fetchSchemes(String id) async {
    const String _baseUrl = 'https://chits.tutytech.in/scheme.php';
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'select'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> branchData = json.decode(response.body);

        // Find the branch with the matching ID
        final branch = branchData.firstWhere(
          (branch) => branch['id'].toString() == id,
          orElse: () => null,
        );

        if (branch != null) {
          setState(() {
            _updateBranchFields(branch);
            isLoading = false;
          });
        } else {
          _showError('No branch found with ID $id.');
        }
      } else {
        throw Exception('Failed to fetch branches');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> _updateSchemeData() async {
    print('---------------${widget.id}');
    try {
      final url = Uri.parse('https://chits.tutytech.in/scheme.php');

      final requestBody = {
        'type': 'update',
        'id': widget.id.toString(),
        'schemeid': _schemeIdController.text.trim(),
        'schemename': _schemeNameController.text.trim(),
        'amount': _loanAmountController.text.trim(),
        'collectiontype': _weeksDaysController.text.trim(),
      };

      // Debugging prints
      debugPrint('Request URL: $url');
      debugPrint('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type':
              'application/x-www-form-urlencoded', // Ensure the server expects JSON
        },
        body: requestBody, // Send as JSON
      );

      debugPrint('Response Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result[0]['status'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scheme updated successfully!')),
          );
          Navigator.pop(context, true); // Return to the previous screen
        } else {
          _showError(result[0]['message'] ?? 'Failed to update scheme.');
        }
      } else {
        _showError('Failed to update scheme: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error: $error');
      _showError('An error occurred: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                            if (value != null) {}
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
                                _updateSchemeData();
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
