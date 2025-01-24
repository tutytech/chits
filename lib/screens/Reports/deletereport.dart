import 'dart:convert';

import 'package:chitfunds/screens/customerreceipt.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeleteReport extends StatefulWidget {
  const DeleteReport({Key? key}) : super(key: key);

  @override
  _AmountTransferState createState() => _AmountTransferState();
}

class _AmountTransferState extends State<DeleteReport> {
  Future<List<Map<String, dynamic>>>? _branchListFuture;
  List<Map<String, dynamic>> _allBranches = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _filteredBranches = [];

  // Controllers
  final TextEditingController _transDateController = TextEditingController();
  List<Map<String, String>> branchData = [];
  List<Map<String, String>> centerData = [];
  bool _isSubmitted = false;
  bool _isReportVisible = true;

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

  Future<List<Map<String, dynamic>>> fetchDeleteReports() async {
    setState(() {
      _isSubmitted = true; // Set the flag to true on button press
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId = prefs.getString('staffId');
    const String _baseUrl = 'https://chits.tutytech.in/receipt.php';

    try {
      // Print the request URL and body
      print('Request URL: $_baseUrl');
      print('Request Body: type=innerjoin');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'innerjoin'},
      );

      // Print the response status and body
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as List<dynamic>;

        // Handle missing keys safely
        return responseData.map((branch) {
          return {
            'id': branch['id'] ?? '',
            'customerId': branch['customerId'] ?? '',
            'customername': branch['customername'] ?? 'Unknown Branch',
            'receiptno': branch['receiptno']?.toString() ?? '0',
            'receiptdate': branch['receiptdate'] ?? 'N/A',
            'phoneNo': branch['phoneNo'] ?? 'N/A',
            'receivedamount': branch['receivedamount'] ?? 'N/A',
            'entryid': staffId,
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch branches');
      }
    } catch (e) {
      // Print the error for debugging
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> _createCollectionReport() async {
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

    final String apiUrl = 'https://chits.tutytech.in/collectionreport.php';

    // Prepare request body
    final requestBody = {
      'type': 'insert',
      'branch': selectedBranchName,
      'center': selectedCenterName,
      'transactiondate': _transDateController.text,
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
        title: 'Delete Report',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Section
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),

                        // Branch Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedBranchId,
                          onChanged: (newValue) {
                            setState(() {
                              selectedBranchId = newValue;
                              selectedBranchName = branchData.firstWhere(
                                (branch) => branch['id'] == newValue,
                              )['name']; // Fetch branch name
                            });
                          },
                          items: branchData.map((branch) {
                            return DropdownMenuItem<String>(
                              value: branch['id'], // Use branch ID as value
                              child:
                                  Text(branch['name']!), // Display branch name
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Branch',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Please select a branch'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Center Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedCenterId,
                          onChanged: (newValue) {
                            setState(() {
                              selectedCenterId = newValue;
                              selectedCenterName = centerData.firstWhere(
                                (center) => center['id'] == newValue,
                              )['name'];
                            });
                          },
                          items: centerData.map((center) {
                            return DropdownMenuItem<String>(
                              value: center['id'],
                              child: Text(center['name']!),
                            );
                          }).toList(),
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
                        const SizedBox(height: 16),

                        // Transaction Date
                        TextFormField(
                          controller: _transDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Tran Date',
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
                                        DateFormat('dd/MM/yyyy')
                                            .format(pickedDate);
                                  });
                                }
                              },
                            ),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Select a date' : null,
                        ),
                        const SizedBox(height: 32),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Add your refresh logic here
                                },
                                child: const Text(
                                  'Refresh',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isSubmitted = true;
                                    _branchListFuture = fetchDeleteReports();
                                  });
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Table Section
                  Container(
                    margin: const EdgeInsets.only(
                        top: 16.0), // Add margin for spacing
                    padding: const EdgeInsets.all(
                        16.0), // Add padding for inner spacing
                    decoration: BoxDecoration(
                      color: Colors.white, // Set the container background color
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2), // Shadow position
                        ),
                      ],
                    ),
                    child: Visibility(
                      visible:
                          _isSubmitted, // Only show this when button is pressed
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _branchListFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('No loans found'),
                            );
                          }

                          _allBranches = snapshot.data!;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: MediaQuery.of(context).size.width,
                              ),
                              child: DataTable(
                                headingRowColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.grey[200]!,
                                ),
                                columns: const [
                                  DataColumn(
                                      label: Text(
                                    'Customer No',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(
                                          0xFF4A90E2), // Blue color to match gradient theme
                                    ),
                                  )),
                                  DataColumn(
                                      label: Text(
                                    'Customer Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(
                                          0xFF4A90E2), // Blue color to match gradient theme
                                    ),
                                  )),
                                  DataColumn(
                                      label: Text(
                                    'Receipt No',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(
                                          0xFF4A90E2), // Blue color to match gradient theme
                                    ),
                                  )),
                                  DataColumn(
                                      label: Text(
                                    'Receipt Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(
                                          0xFF4A90E2), // Blue color to match gradient theme
                                    ),
                                  )),
                                  DataColumn(
                                      label: Text(
                                    'Mobile No',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(
                                          0xFF4A90E2), // Blue color to match gradient theme
                                    ),
                                  )),
                                  DataColumn(
                                      label: Text(
                                    'Receipt Amount',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(
                                          0xFF4A90E2), // Blue color to match gradient theme
                                    ),
                                  )),
                                  DataColumn(
                                      label: Text(
                                    'EntryID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(
                                          0xFF4A90E2), // Blue color to match gradient theme
                                    ),
                                  )),
                                ],
                                rows: _allBranches.map((branch) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                          Text(branch['customerId'] ?? 'N/A')),
                                      DataCell(
                                          Text(branch['customername'] ?? '0')),
                                      DataCell(
                                          Text(branch['receiptno'] ?? 'N/A')),
                                      DataCell(
                                          Text(branch['receiptdate'] ?? 'N/A')),
                                      DataCell(
                                          Text(branch['phoneNo'] ?? 'N/A')),
                                      DataCell(Text(
                                          branch['receivedamount'] ?? 'N/A')),
                                      DataCell(
                                          Text(branch['entryid'] ?? 'N/A')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
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
