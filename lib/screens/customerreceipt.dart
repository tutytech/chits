import 'dart:async';
import 'dart:convert';

import 'package:chitfunds/screens/editcomapnydetails.dart';
import 'package:chitfunds/screens/editcompany.dart';
import 'package:chitfunds/screens/loanlist.dart';

import 'package:chitfunds/screens/receiptlist.dart';
import 'package:chitfunds/screens/scan_screen.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../wigets/customappbar.dart';
import 'package:http/http.dart' as http;

class Receipt extends StatefulWidget {
  final String? rights;
  const Receipt({Key? key, this.rights}) : super(key: key);

  @override
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  final TextEditingController _receivedAmountController =
      TextEditingController();
  final TextEditingController _collectionDateController =
      TextEditingController();
  String? _selectedReason;

  final List<String> _reasons = [
    'Customer not available',
    'Postponed',
    'Other'
  ];
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _creditopeningbalController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _customernameController = TextEditingController();
  final TextEditingController _mobilenoController = TextEditingController();
  final TextEditingController _loanamountController = TextEditingController();
  final TextEditingController _receivedamountController =
      TextEditingController();
  final TextEditingController _depositamountController =
      TextEditingController();
  final TextEditingController _chequenoController = TextEditingController();
  final TextEditingController _chequedateController = TextEditingController();
  final TextEditingController _banknameController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _selectcenterController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  String? selectedStaff;
  List<Map<String, dynamic>> _filteredCustomers = [];
  String? selectedStaff1;
  String? selectedCenter;
  String? selectedCenterId;
  String? selectedCenterName;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, String>> centerData = [];

  final List<String> centers = [
    'Center A',
    'Center B',
    'Center C',
    'Center D',
    'Center E',
  ];
  final List<String> areas = ['CASH', 'CHEQUE'];
  final List<String> rights = [
    'Admin',
    'HR',
    'MD',
    'Manager',
    'Auditor',
    'Accounts',
    'System Entry',
    'Field Officier'
  ];
  List<Map<String, dynamic>> _customers = [];
  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
    _loadCustomers();
    _fetchCenters();
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
    _customerNameController.text = customer['name'];
    _mobileNoController.text = customer['phoneNo'];

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

  Future<void> _createBranch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId = prefs.getString('staffId');
    final String? companyid = prefs.getString('companyId');
    final String receivedAmount = _receivedAmountController.text.trim().isEmpty
        ? '0'
        : _receivedAmountController.text.trim();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Exit the method if validation fails
    }

    final String apiUrl = 'https://chits.tutytech.in/receipt.php';

    try {
      final Map<String, String> bodyData = {
        'type': 'insert',
        'customerId': _detailsController.text,
        'customername': _customerNameController.text,
        'mobileno': _mobileNoController.text,
        'loanamount': _loanamountController.text,
        'receivedamount': receivedAmount.isEmpty ? '0' : receivedAmount,
        'depositamount': _depositamountController.text,
        'paymenttype': selectedStaff1.toString(),
        'chequeno': _chequenoController.text,
        'chequedate': _chequedateController.text,
        'bankname': _banknameController.text,
        'remarks': _remarksController.text,
        'entryid': staffId ?? '',
        'companyid': companyid ?? '',
        'nextcollectiondate': _collectionDateController.text,
      };

      // Conditionally add 'reason' field only if receivedAmount is '0'
      if (receivedAmount == '0' || receivedAmount == '0.0') {
        bodyData['reason'] = _selectedReason.toString();
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: bodyData,
      );

      print('Request URL: $apiUrl');
      print('Request Body: $bodyData');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData[0]['id'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt created successfully!')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => receiptListPage(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData[0]['error']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create receipt.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Create Receipt',
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
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    _buildCustomerDropdown(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Customer name cannot be empty';
                        }
                        return null;
                      },
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _mobileNoController,
                      decoration: InputDecoration(
                        labelText: 'Mobile No',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mobile number cannot be empty';
                        } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Enter a valid 10-digit mobile number';
                        }
                        return null;
                      },
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    // Branch Name field
                    TextFormField(
                      controller:
                          _loanamountController, // This controller will hold the balance
                      // Makes the text field read-only
                      decoration: InputDecoration(
                        labelText: 'Loan/Chits/Savings',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[
                            200], // Optional: gives a light grey background for better visibility
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Loan/chits/savings cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _receivedAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Received Amount',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 10),

                    if (_receivedAmountController.text == '0') ...[
                      // Reason Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedReason,
                        decoration: InputDecoration(
                          labelText: 'Reason',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _reasons.map((reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(reason),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReason = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a reason';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Collection Date TextField
                    TextFormField(
                      controller: _collectionDateController,
                      readOnly:
                          true, // Makes the field non-editable so date can only be picked from calendar
                      decoration: InputDecoration(
                        labelText: 'Next Collection Date',
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
                                _collectionDateController.text =
                                    DateFormat('dd/MM/yyyy').format(pickedDate);
                              });
                            }
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Next Collection Date cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Opening Date field
                    // Opening Date field

                    TextFormField(
                      controller: _depositamountController,
                      decoration: InputDecoration(
                        labelText: 'Deposit Amount',
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
                          return 'Deposit Amount cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    DropdownButtonFormField<String>(
                      value: selectedStaff1,
                      decoration: InputDecoration(
                        labelText: 'Type of Payment',
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
                          return 'Payment is required';
                        }
                        return null;
                      },
                      items: areas.map((branch) {
                        return DropdownMenuItem<String>(
                          value: branch,
                          child: Text(branch),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStaff1 = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _chequenoController,
                      decoration: InputDecoration(
                        labelText: 'Cheque No',
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
                          return 'Cheque No cannot be empty';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _chequedateController,
                      readOnly:
                          true, // Makes the field non-editable so date can only be picked from calendar
                      decoration: InputDecoration(
                        labelText: 'Cheque Date',
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
                                _chequedateController.text =
                                    DateFormat('dd/MM/yyyy').format(pickedDate);
                              });
                            }
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Cheque Date cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _banknameController,
                      decoration: InputDecoration(
                        labelText: 'Bank Name',
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
                          return 'Bank Name cannot be empty';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _remarksController,
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
                          return 'Remarks cannot be empty';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Create Branch button
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
                                _createBranch();
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => ScanScreen()),
                                // );
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
                                    builder: (context) => receiptListPage(),
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
                    const SizedBox(height: 30),
                    const Text(
                      "Receipt Report",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Start Date Text Field
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
                        labelText: 'Select Center',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // End Date Text Field
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'dd/MM/yyyy',
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
                                _dateController.text =
                                    DateFormat('dd/MM/yyyy').format(pickedDate);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Collection Print Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCompany(),
                            ),
                          );
                        },
                        child: const Text(
                          'Collection Print',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 70),
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
      ]),
    );
  }
}
