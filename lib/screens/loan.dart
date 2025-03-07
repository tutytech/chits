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

class Loan extends StatefulWidget {
  final String? rights;
  const Loan({Key? key, this.rights}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<Loan> {
  List<Map<String, dynamic>> _filteredCustomers = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> branchNames = [];
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
  List<String> branchName = ['15000scheme', '20000scheme', '25000scheme'];
  List<Map<String, dynamic>> _schemes = [];
  String? selectedScheme;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadSchemes();
  }

  Future<void> _loadSchemes() async {
    try {
      final schemes = await fetchSchemes();
      setState(() {
        _schemes = schemes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to load schemes: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSchemes() async {
    const String _baseUrl = 'https://chits.tutytech.in/scheme.php';
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'select'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as List<dynamic>;

        // Handle missing keys safely
        return responseData.map((branch) {
          return {
            'id': branch['id'] ?? '',
            'schemeid': branch['schemeid'] ?? 'Unknown code',
            'schemename': branch['schemename'] ?? 'Unknown center',
            'amount': branch['amount']?.toString() ?? '0',
            'collectiontype': branch['collectiontype'] ?? 'N/A',
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch branches');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
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
              'loanno': customer['loanno']?.toString() ?? '',
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
    final String? companyid = prefs.getString('companyId');
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
      'companyid': companyid.toString(),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoanListPage(),
          ),
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
    if (input.isEmpty) {
      setState(() {
        _filteredCustomers = [];
      });
      return;
    }

    setState(() {
      _filteredCustomers = _customers.where((customer) {
        String name = customer['name'].toLowerCase();
        String phoneNo = customer['phoneNo'].toString();
        String customerId = customer['customerId'].toString();
        String loanno = customer['loanno'].toString();

        return name.contains(input.toLowerCase()) ||
            phoneNo.contains(input) || // Now ensures string matching
            customerId.contains(input) ||
            loanno.contains(input);
      }).toList();
    });
  }

  void _selectCustomer(Map<String, dynamic> customer) {
    customernameController.text = customer['name'];
    customeridController.text = customer['customerId'];

    // Hide dropdown after selection
    setState(() {
      _filteredCustomers = [];
    });
  }

  Widget _buildCustomerDropdown() {
    return _filteredCustomers.isNotEmpty
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              children: _filteredCustomers.map((customer) {
                return ListTile(
                  title: Text(
                      "${customer['name']} - ${customer['loanno']}- ${customer['phoneNo']}"),
                  onTap: () => _selectCustomer(customer),
                );
              }).toList(),
            ),
          )
        : SizedBox.shrink();
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
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      _buildCustomerDropdown(),
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
                        value: _schemes.any((scheme) =>
                                scheme['schemename'] == selectedScheme)
                            ? selectedScheme
                            : null,
                        onChanged: (newValue) {
                          setState(() {
                            selectedScheme = newValue;
                          });
                        },
                        items: _schemes.map((scheme) {
                          return DropdownMenuItem<String>(
                            value: scheme['schemename'].toString(),
                            child: Text(scheme['schemename'].toString()),
                          );
                        }).toList(),
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
                                  _submitLoanForm();
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
