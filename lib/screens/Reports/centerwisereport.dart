import 'dart:convert';

import 'package:chitfunds/screens/customerreceipt.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Centerwisereport extends StatefulWidget {
  Centerwisereport({Key? key}) : super(key: key);

  @override
  _AmountTransferState createState() => _AmountTransferState();
}

class _AmountTransferState extends State<Centerwisereport> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _transDateController = TextEditingController();
  List<Map<String, String>> branchData = [];
  List<Map<String, String>> centerData = [];
  final List<String> days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  String? selectedDay;

  // Dropdown selections
  String? _selectedBranch;
  String? _selectedArea;
  String? selectedBranchName;
  String? selectedBranchId;
  String? selectedCenterName;
  String? selectedCenterId;

  // Sample data for dropdowns
  final List<String> _branches = ['Branch A', 'Branch B', 'Branch C'];
  final List<String> _areas = ['Area 1', 'Area 2', 'Username 1'];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchBranches();
    _fetchCenters(); // Fetch branches when the widget dependencies change
  }

  @override
  void dispose() {
    _transDateController.dispose();
    super.dispose();
  }

  Future<void> _createCenterWiseReport() async {
    // Fetch the staffId from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId =
        prefs.getString('staffId'); // Retrieve staffId as a string

    if (staffId == null) {
      // Handle the case where staffId is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Staff ID is missing. Please log in again.')),
      );
      return;
    }

    print('Staff ID: $staffId');

    if (!(_formKey.currentState?.validate() ?? true)) {
      return; // Exit the method if validation fails
    }

    final String apiUrl = 'https://chits.tutytech.in/centerwisereport.php';

    // Prepare request body
    final requestBody = {
      'type': 'insert',
      'branch': selectedBranchName,
      'center': selectedCenterName,
      'date': _transDateController.text,
      'dayorder': selectedDay,
      'entryid': staffId, // Use the staffId from SharedPreferences
    };

    print('Request URL: $apiUrl');
    print('Request Body: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      // Print response details
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData[0]['id'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Branch created successfully!')),
          );

          // Fetch the list of all branches
          await _fetchBranches();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData[0]['error']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create branch.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _fetchCenters() async {
    final String apiUrl = 'https://chits.tutytech.in/center.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'select', // Type for listing centers
        },
      );

      if (response.statusCode == 200) {
        // Log response for debugging
        print("Response Body: ${response.body}");

        final responseData = json.decode(response.body);

        // Parse centers from response
        List<Map<String, String>> centers = [];
        for (var center in responseData) {
          if (center['id'] != null && center['centername'] != null) {
            centers.add({
              'id': center['id'].toString(),
              'name': center['centername'],
            });
          }
        }

        if (centers.isEmpty) {
          _showSnackBar('No centers were found in the response data.');
        } else {
          setState(() {
            centerData = centers; // Update the state with center data
          });

          print('Center Data: $centers');
        }
      } else {
        _showSnackBar(
            'Failed to fetch centers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _fetchBranches() async {
    final String apiUrl = 'https://chits.tutytech.in/branch.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'select',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<Map<String, String>> branches = [];
        for (var branch in responseData) {
          if (branch['id'] != null && branch['branchname'] != null) {
            branches.add({
              'id': branch['id'].toString(),
              'name': branch['branchname'],
            });
          }
        }

        setState(() {
          branchData = branches;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch branches.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _transDateController.clear();
      _selectedBranch = null;
      _selectedArea = null;
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Handle form submission logic
      print('Branch: $_selectedBranch');
      print('Area/Username: $_selectedArea');
      print('Transaction Date: ${_transDateController.text}');
    }
  }

  void _exportToExcel() {
    // Handle export to Excel logic
    print('Exporting to Excel');
  }

  void _exportToXml() {
    // Handle export to XML logic
    print('Exporting to XML');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'CenterWise Report',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(),
      body: Stack(children: [
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
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  // Branch Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedBranchId,
                    onChanged: (newValue) {
                      setState(() {
                        selectedBranchId = newValue;
                        selectedBranchName = branchData.firstWhere((branch) =>
                            branch['id'] ==
                            newValue)['name']; // Fetch branch name
                      });
                    },
                    items: branchData
                        .map((branch) => DropdownMenuItem<String>(
                              value: branch['id'], // Use branch ID as value
                              child:
                                  Text(branch['name']!), // Display branch name
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Branch',
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
                        return 'Please select a branch';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCenterId,
                    onChanged: (newValue) {
                      setState(() {
                        selectedCenterId = newValue;
                        selectedCenterName = centerData.firstWhere(
                            (center) => center['id'] == newValue)['name'];
                      });
                    },
                    items: centerData
                        .map((center) => DropdownMenuItem<String>(
                              value: center['id'],
                              child: Text(center['name']!),
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Center',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Transaction Date with DatePicker
                  TextFormField(
                    controller: _transDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.grey),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _transDateController.text =
                                  DateFormat('dd/MM/yyyy').format(pickedDate);
                            });
                          }
                        },
                      ),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Select a date' : null,
                  ),
                  const SizedBox(height: 20),
                  // Area/Username Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Day Order',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: selectedDay,
                    items: days.map((day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDay = value;
                      });
                    },
                  ),

                  SizedBox(height: 32),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100, // Adjust the width as needed
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100, // Adjust the width as needed
                        child: ElevatedButton(
                          onPressed: () {
                            _createCenterWiseReport();
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 170, // Adjust the width as needed
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text(
                            'Center Wise Excel',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150, // Adjust the width as needed
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text(
                            'Day Wise Excel',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            color: const Color.fromARGB(218, 209, 209, 204),
            padding: const EdgeInsets.all(10.0),
            child: const Text(
              'POWERED BY TUTYTECH',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
