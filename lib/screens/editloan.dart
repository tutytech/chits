import 'package:chitfunds/screens/createcenter.dart';
import 'package:chitfunds/screens/loanlist.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:chitfunds/wigets/inputwidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditLoan extends StatefulWidget {
  final String? rights;
  final String? id; // Pass the branch ID to load specific data

  const EditLoan({Key? key, this.id, this.rights}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<EditLoan> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> branchNames = [];

  bool? isActive;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  List<Map<String, dynamic>> _customers = [];
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController customeridController = TextEditingController();
  final TextEditingController customernameController = TextEditingController();
  final TextEditingController accountnoController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController firstcollectiondateController =
      TextEditingController();
  String? selectedBranch;
  bool isLoading = true;
  List<String> branchName = ['15000scheme', '20000scheme', '25000scheme'];
  // Future<void> _selectMarriage(BuildContext context, String label) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: label == "DOB"
  //         ? dobController.text.isNotEmpty
  //             ? DateFormat('yyyy-MM-dd').parse(dobController.text)
  //             : DateTime.now()
  //         : label == "DOJ"
  //             ? dojController.text.isNotEmpty
  //                 ? DateFormat('yyyy-MM-dd').parse(dojController.text)
  //                 : DateTime.now()
  //             : DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       String formattedDate = DateFormat('yyyy-MM-dd').format(picked);

  //       // Update the correct controller based on the label
  //       if (label == "DOB") {
  //         dobController.text = formattedDate;
  //       } else if (label == "DOJ") {
  //         dojController.text = formattedDate;
  //       } else if (label == "DOM") {
  //         domController.text = formattedDate;
  //       } else if (label == "EntryDate") {
  //         entrydateController.text = formattedDate;
  //       }
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    isActive = false;
    _loadCustomers();
    if (widget.id != null) {
      fetchLoans(widget.id!);
    } else {
      _showError('Invalid branch ID provided.');
    }
  }

  Future<void> fetchLoans(String id) async {
    print('loan1');
    const String _baseUrl = 'https://chits.tutytech.in/loan.php';
    try {
      print('loan2');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'list'},
      );

      if (response.statusCode == 200) {
        print('loan3');
        print('API Response Body: ${response.body}');
        final Map<String, dynamic> decodedResponse = json.decode(response.body);

        // Extract loan data from 'data' key
        final List<dynamic> branchData = decodedResponse['data'];

        print('Branch Data List: $branchData');
        final branch = branchData.firstWhere(
          (branch) => branch['id'].toString() == id,
          orElse: () => null,
        );

        if (branch != null) {
          print('loan4');
          print('Branch Found: $branch');
          setState(() {
            _updateBranchFields(branch);
            isLoading = false;
          });
        } else {
          print('loan5');
          _showError('No branch found with ID $id.');
        }
      } else {
        print('loan6');
        throw Exception('Failed to fetch branches');
      }
    } catch (e) {
      print('loan7');
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  void _updateBranchFields(Map<String, dynamic> branch) {
    print('Updating fields with branch data: $branch');

    customeridController.text =
        branch['customerId'] ?? ''; // Ensure correct key
    customernameController.text =
        branch['customerName']?.toString() ?? ''; // Ensure correct key
    accountnoController.text =
        branch['customerName'] ?? ''; // Ensure correct key
    dobController.text = branch['date'] ?? ''; // Ensure correct key
    firstcollectiondateController.text =
        branch['firstCollectionDate'] ?? ''; // Ensure correct key
    amountController.text = branch['amount'] ?? '';
    selectedBranch = branch['scheme'] ?? '';
    remarksController.text = branch['remarks'] ?? '';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await fetchCustomers();
      setState(() {
        _customers = customers;
      });
    } catch (e) {
      print('Error loading customers: $e');
    }
  }

  Future<void> _updateLoanData() async {
    final String activeStatus = isActive == true ? 'Y' : 'N';
    print('---------------${widget.id}');
    try {
      final url = Uri.parse('https://chits.tutytech.in/loan.php');

      final requestBody = {
        'type': 'update',
        'id': widget.id.toString(),
        'customerid': customeridController.text.trim(),
        'customername': customernameController.text.trim(),
        'accountno': accountnoController.text.trim(),
        'firstcollectiondate': dobController.text.trim(),
        'amount': firstcollectiondateController.text.trim(),
        'scheme': amountController.text.trim(),
        'remarks': remarksController.text.trim(),
        'closedaccounts': activeStatus // Updated here
      };

      // Debugging prints
      debugPrint('Request URL: $url');
      debugPrint('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      debugPrint('Response Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result[0]['status'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Loan updated successfully!')),
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

  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    const String _baseUrl = 'https://chits.tutytech.in/customer.php';
    final Map<String, String> body = {'type': 'fetch'};

    try {
      // Log request details
      print('Request URL: $_baseUrl');
      print('Request Body: $body');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      // Log response details
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse['success'] == true &&
            decodedResponse['customerDetails'] is List) {
          // Parse the list of customers
          return List<Map<String, dynamic>>.from(
              decodedResponse['customerDetails'].map((customer) {
            return {
              'id': customer['id'] ?? '',
              'customerId': customer['customerId'] ?? 'Unknown customer',
              'name': customer['name']?.toString() ?? 'N/A',
              'address': customer['address'] ?? 'N/A',
              'phoneNo': customer['phoneNo'] ?? 'N/A',
              'aadharNo': customer['aadharNo'] ?? 'N/A',
              'branch': customer['branch'] ?? 'N/A',
              'center': customer['center'] ?? 'N/A',
            };
          }));
        } else if (decodedResponse['error'] != null) {
          // Handle API error response
          throw Exception('API Error: ${decodedResponse['error']}');
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to fetch customers (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> _submitLoanForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId = prefs.getString('staffId');
    // Validate the form first
    if (_formKey.currentState?.validate() != true) {
      // If the form is invalid, stop further execution
      return;
    }

    final String apiUrl = 'https://chits.tutytech.in/loan.php'; // API URL

    // Collect form data
    final Map<String, String> loanData = {
      'type': 'insert',
      'customerId': customeridController.text,
      'customerName': customernameController.text,
      'accountNo': accountnoController.text,
      'date': dobController.text,
      'firstCollectionDate': firstcollectiondateController.text,
      'amount': amountController.text,
      'scheme': selectedBranch ?? '',
      'remarks': remarksController.text,
      'entryid': staffId.toString(),
    };

    try {
      // Log request URL and parameters
      print('Request URL: $apiUrl');
      print('Request Data: $loanData');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: loanData,
      );

      // Log raw response
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Success response
        print('Loan submitted successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan submitted successfully!')),
        );
      } else {
        // HTTP error
        print('HTTP Error: Status Code ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit the loan.')),
        );
      }
    } catch (e) {
      // Exception handling
      print('An exception occurred: $e');
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

  void _searchCustomer(String input) {
    final customer = _customers.firstWhere(
      (customer) =>
          customer['name'].toLowerCase() ==
              input.toLowerCase() || // Check by name
          customer['phoneNo'] == input || // Check by mobile number
          customer['customerId'] == input, // Check by customer ID
      orElse: () => {}, // Return an empty map if no match is found
    );

    if (customer.isNotEmpty) {
      // Set the name and phone number to the respective text fields
      customernameController.text = customer['name'];
      customeridController.text = customer['customerId'];

      // Disable editing for these fields
      setState(() {});
    } else {
      // Clear the fields if no match is found
      customernameController.clear();
      customeridController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Chits/Loan/Savings',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(branchNames: branchNames, rights: widget.rights),
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
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Closed Accounts:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Checkbox(
                            value: isActive,
                            onChanged: (value) {
                              setState(() {
                                isActive = value ?? false;
                              });
                            },
                          ),
                          const Text('Active'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _detailsController,
                        decoration: InputDecoration(
                          labelText: 'Customer Details',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Customer Details is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _searchCustomer(value);
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: customeridController,
                        decoration: InputDecoration(
                          labelText: 'Customer ID',
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
                            return 'Customer ID is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: customernameController,
                        decoration: InputDecoration(
                          labelText: 'Customer Name',
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
                            return 'Customer Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: accountnoController,
                        decoration: InputDecoration(
                          labelText: 'AccountNo',
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
                            return 'Accountno is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: dobController,
                        readOnly:
                            true, // Prevent manual text entry if only using the calendar
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
                              // Show the date picker when the icon is pressed
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
                          if (value == null || value.isEmpty) {
                            return 'Date is required';
                          }
                          return null;
                        },
                      ),
                      // Keeps consistent spacing

                      const SizedBox(height: 20),
                      TextFormField(
                        controller: firstcollectiondateController,
                        readOnly:
                            true, // Prevent manual text entry if only using the calendar
                        decoration: InputDecoration(
                          labelText: 'First Collection Date',
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
                              // Show the date picker when the icon is pressed
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                firstcollectiondateController.text =
                                    DateFormat('yyyy-MM-dd').format(picked);
                              }
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'FirstCollectionDate is required';
                          }
                          return null;
                        },
                      ),

                      // Reduced height specifically here
                      // Opening Date field
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: amountController,
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
                            return 'Amount is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: branchName.contains(selectedBranch)
                            ? selectedBranch
                            : null,
                        onChanged: (newValue) {
                          setState(() {
                            selectedBranch = newValue;
                          });
                        },
                        items: branchName
                            .map((branchName) => DropdownMenuItem<String>(
                                  value: branchName,
                                  child: Text(branchName),
                                ))
                            .toList(),
                        decoration: InputDecoration(
                          labelText: 'Scheme',
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
                            return 'Scheme is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      TextFormField(
                        controller: remarksController,
                        decoration: InputDecoration(
                          labelText: 'Remarks',
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
                            return 'Remarks is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20), // Spacing before the button
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 150, // Adjust the width as needed
                              child: ElevatedButton(
                                onPressed: () {
                                  _updateLoanData();
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
                              width: 150, // Adjust the width as needed
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoanListPage(),
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
}
