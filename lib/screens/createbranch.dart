import 'package:chitfunds/screens/branchlist.dart';
import 'package:chitfunds/screens/createcenter.dart';
import 'package:chitfunds/screens/createcustomer.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:chitfunds/wigets/inputwidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateBranch extends StatefulWidget {
  const CreateBranch({Key? key}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<CreateBranch> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> branchNames = [];
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _openingBalanceController =
      TextEditingController();
  final TextEditingController _openingDateController = TextEditingController();
  final entrydateController = TextEditingController();
  final dobController = TextEditingController();
  final dojController = TextEditingController();
  final domController = TextEditingController();
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _staffNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _branchCodeController = TextEditingController();
  final TextEditingController _receiptNoController = TextEditingController();
  final TextEditingController _companyIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? selectedBranch;
  String? selectedRights;
  String? selectedBranchName;
  String? _staffId;

  Future<void> _selectMarriage(BuildContext context, String label) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: label == "DOB"
          ? dobController.text.isNotEmpty
              ? DateFormat('yyyy-MM-dd').parse(dobController.text)
              : DateTime.now()
          : label == "DOJ"
              ? dojController.text.isNotEmpty
                  ? DateFormat('yyyy-MM-dd').parse(dojController.text)
                  : DateTime.now()
              : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        String formattedDate = DateFormat('yyyy-MM-dd').format(picked);

        // Update the correct controller based on the label
        if (label == "DOB") {
          dobController.text = formattedDate;
        } else if (label == "DOJ") {
          dojController.text = formattedDate;
        } else if (label == "DOM") {
          domController.text = formattedDate;
        } else if (label == "EntryDate") {
          entrydateController.text = formattedDate;
        }
      });
    }
  }

  Future<void> _createStaff() async {
    // Check if the form is valid
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Exit the method if validation fails
    }
    final String apiUrl = 'https://chits.tutytech.in/staff.php';

    try {
      // Print the request URL and body for debugging
      print('Request URL: $apiUrl');
      print('Request body: ${{
        'type': 'insert',
        'staffId': _staffIdController.text,
        'staffName': _staffNameController.text,
        'address': _addressController.text,
        'mobileNo': _mobileNoController.text,
        'userName': _userNameController.text,
        'password': _passwordController.text,
        'branch': selectedBranchName,
        'branchCode': _branchCodeController.text,
        'receiptNo': _receiptNoController.text,
        'rights': selectedRights,
        'companyid': _companyIdController.text,
        'email': _emailController.text,
      }}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'insert',
          'staffId': _staffIdController.text,
          'staffName': _staffNameController.text,
          'address': _addressController.text,
          'mobileNo': _mobileNoController.text,
          'userName': _userNameController.text,
          'password': _passwordController.text,
          'branch': selectedBranchName,
          'branchCode': _branchCodeController.text,
          'receiptNo': _receiptNoController.text,
          'rights': selectedRights,
          'companyid': _companyIdController.text,
          'email': _emailController.text,
        },
      );

      // Print the response body for debugging
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if responseData contains staffId
        if (responseData is List && responseData.isNotEmpty) {
          _staffId =
              responseData[0]['id']; // Assuming 'id' is the field for staffId
          if (_staffId != null) {
            print('Extracted staffId: $_staffId'); // Debugging
            _showSnackBar('Staff created successfully! ID: $_staffId');
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) =>
            //         CreateCustomer(staffId: staffId), // Pass staffId
            //   ),
            // );
          } else {
            _showSnackBar('Error: Staff ID is null.');
          }
        } else {
          _showSnackBar('Error: Invalid response format.');
        }
      } else {
        _showSnackBar(
            'Failed to create staff. Status code: ${response.statusCode}');
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

  Future<void> _createBranch() async {
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

    final String apiUrl = 'https://chits.tutytech.in/branch.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'insert',
          'branchname': _branchNameController.text,
          'openingbalance': _openingBalanceController.text,
          'openingdate': dobController.text,
          'entryid': staffId,
          // Use the staffId from SharedPreferences
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData[0]['id'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Branch created successfully!')),
          );

          // Fetch the list of all branches
          await _fetchBranches();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateCenter(),
            ),
          );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
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
          'type': 'list', // Assuming 'list' type fetches all branches
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<String> branches = [];
        // Assuming the response contains a list of branches with a 'branchname' field
        for (var branch in responseData) {
          if (branch['branchname'] != null) {
            branches.add(branch['branchname']);
          }
        }

        setState(() {
          branchNames = branches;
        });

        // Print the branch names to the terminal
        print("Branch Names: $branches");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Create Branch',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(branchNames: branchNames),
      body: Stack(
        children: [
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
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _branchNameController,
                        decoration: InputDecoration(
                          labelText: 'Enter Branch Name',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Branch name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _openingBalanceController,
                        decoration: InputDecoration(
                          labelText: 'Opening Balance',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Opening balance is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Opening Date',
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
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                dobController.text =
                                    DateFormat('yyyy-MM-dd').format(picked);
                              }
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Opening date is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
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
                                  // Form is valid
                                  _createBranch();
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
                                      builder: (context) => BranchListPage(),
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
        ],
      ),
    );
  }

  Widget _buildMarriageDateField(BuildContext context, String label) {
    TextEditingController controller;

    // Select the correct controller based on the label
    if (label == "DOB") {
      controller = dobController;
    } else if (label == "DOJ") {
      controller = dojController;
    } else if (label == "DOM") {
      controller = domController;
    } else if (label == "EntryDate") {
      controller = entrydateController;
    } else {
      throw ArgumentError("Invalid label: $label");
    }

    return InputWidget(
      label: label,
      controller: controller,
      hintText: "Opening Date",
      readOnly: true, // Make the field read-only
      suffixWidget: IconButton(
        icon: Icon(Icons.calendar_today, color: Colors.grey),
        onPressed: () => _selectMarriage(
          context,
          label,
        ),
      ),
    );
  }
}
