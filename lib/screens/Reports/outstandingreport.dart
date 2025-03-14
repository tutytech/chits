import 'dart:convert';
import 'dart:io';

import 'package:chitfunds/screens/customerreceipt.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Outstandingreport extends StatefulWidget {
  final String? rights;
  Outstandingreport({Key? key, this.rights}) : super(key: key);

  @override
  _AmountTransferState createState() => _AmountTransferState();
}

class _AmountTransferState extends State<Outstandingreport> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _transDateController = TextEditingController();
  List<Map<String, String>> branchData = [];
  List<Map<String, String>> centerData = [];
  List<Map<String, dynamic>> _allBranches = [];
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
  bool _isSubmitted = false;
  Future<List<Map<String, dynamic>>>? _branchListFuture;

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

  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Loan Data'];

    // Add table headers
    List<String> headers = [
      'Loan No',
      'Loan Date',
      'Branch',
      'Center',
      'Customer Name',
      'MobileNo',
      'Loan Amount',
      'Collectiontype',
      'No of weeks',
      'Total Installment Amount',
      'Total Received Amount',
      'Pending Amount'
    ];
    sheetObject
        .appendRow(headers.map((header) => TextCellValue(header)).toList());

    // Add table data
    for (var branch in _allBranches) {
      sheetObject.appendRow([
        TextCellValue(branch['loanno'] ?? 'N/A'),
        TextCellValue(branch['loandate'] ?? 'N/A'),
        TextCellValue(branch['branch'] ?? 'N/A'),
        TextCellValue(branch['center'] ?? 'N/A'),
        TextCellValue(branch['customername'] ?? 'N/A'),
        TextCellValue(branch['phoneNo'] ?? 'N/A'),
        TextCellValue(branch['amount'] ?? 'N/A'),
        TextCellValue(branch['collectiontype'] ?? 'N/A'),
        TextCellValue(branch['noofweeks'] ?? 'N/A'),
        TextCellValue(branch['totalcollection'] ?? 'N/A'),
        TextCellValue(branch['totalreceived'].toString() ?? 'N/A'),
        TextCellValue(branch['pendingamount'] ?? 'N/A'),
      ]);
    }

    // Get directory and save file
    Directory? directory = await getExternalStorageDirectory();
    if (directory != null) {
      String filePath = '${directory.path}/Loan_Data.xlsx';
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel file saved to: $filePath')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchOutstandingReports() async {
    setState(() {
      _isSubmitted = true; // Set the flag to true on button press
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId = prefs.getString('staffId');
    const String _baseUrl = 'https://chits.tutytech.in/customer.php';

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
            'branch': branch['branch'] ?? '',
            'center': branch['center'] ?? '',
            'customername': branch['customername'] ?? 'Unknown Branch',
            'loanno': branch['loanno']?.toString() ?? '0',
            'loandate': branch['loandate'] ?? 'N/A',
            'phoneNo': branch['phoneNo'] ?? 'N/A',
            'amount': branch['amount'] ?? 'N/A',
            'collectiontype': branch['collectiontype'] ?? 'N/A',
            'noofweeks': branch['noofweeks'] ?? 'N/A',
            'totalcollection': branch['totalcollection'] ?? 'N/A',
            'totalreceived': branch['totalreceived'] ?? 'N/A',
            'pendingamount': branch['pendingamount']?.toString() ?? '0',
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

  void _exportToXml() {
    // Handle export to XML logic
    print('Exporting to XML');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Outstanding Report',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(rights: widget.rights),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
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
                            selectedBranchName = branchData.firstWhere(
                                    (branch) => branch['id'] == newValue)[
                                'name']; // Fetch branch name
                          });
                        },
                        items: branchData
                            .map((branch) => DropdownMenuItem<String>(
                                  value: branch['id'], // Use branch ID as value
                                  child: Text(
                                      branch['name']!), // Display branch name
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
                      SizedBox(height: 32),

                      // Transaction Date with DatePicker

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
                                setState(() {
                                  _isSubmitted = true;
                                  _branchListFuture = fetchOutstandingReports();
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
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 170, // Adjust the width as needed
                            child: ElevatedButton(
                              onPressed: _exportToExcel,
                              child: const Text(
                                'Export To Excel',
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
                Visibility(
                  visible: _isSubmitted,
                  child: Container(
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

                    // Only show this when button is pressed
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
                                  'Loan No',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(
                                        0xFF4A90E2), // Blue color to match gradient theme
                                  ),
                                )),
                                DataColumn(
                                    label: Text(
                                  'Loan Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(
                                        0xFF4A90E2), // Blue color to match gradient theme
                                  ),
                                )),
                                DataColumn(
                                    label: Text(
                                  'Branch',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(
                                        0xFF4A90E2), // Blue color to match gradient theme
                                  ),
                                )),
                                DataColumn(
                                    label: Text(
                                  'Center',
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
                                  'MobileNo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(
                                        0xFF4A90E2), // Blue color to match gradient theme
                                  ),
                                )),
                                DataColumn(
                                    label: Text(
                                  'Loan Amount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(
                                        0xFF4A90E2), // Blue color to match gradient theme
                                  ),
                                )),
                                DataColumn(
                                    label: Text(
                                  'Collectiontype',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(
                                        0xFF4A90E2), // Blue color to match gradient theme
                                  ),
                                )),
                                DataColumn(
                                    label: Text(
                                  'No of weeks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(
                                        0xFF4A90E2), // Blue color to match gradient theme
                                  ),
                                )),
                                DataColumn(
                                    label: Text(
                                  'Total Installment Amount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(
                                        0xFF4A90E2), // Blue color to match gradient theme
                                  ),
                                )),
                                DataColumn(
                                    label: Text(
                                  'Total Received Amount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(
                                        0xFF4A90E2), // Blue color to match gradient theme
                                  ),
                                )),
                                DataColumn(
                                    label: Text(
                                  'Pending Amount',
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
                                    DataCell(Text(branch['loanno'] ?? 'N/A')),
                                    DataCell(Text(branch['loandate'] ?? '0')),
                                    DataCell(Text(branch['branch'] ?? 'N/A')),
                                    DataCell(Text(branch['center'] ?? 'N/A')),
                                    DataCell(
                                        Text(branch['customername'] ?? 'N/A')),
                                    DataCell(Text(branch['phoneNo'] ?? 'N/A')),
                                    DataCell(Text(branch['amount'] ?? 'N/A')),
                                    DataCell(Text(
                                        branch['collectiontype'] ?? 'N/A')),
                                    DataCell(
                                        Text(branch['noofweeks'] ?? 'N/A')),
                                    DataCell(Text(
                                        branch['totalcollection'] ?? 'N/A')),
                                    DataCell(Text(
                                        branch['totalreceived'].toString() ??
                                            'N/A')),
                                    DataCell(
                                        Text(branch['pendingamount'] ?? 'N/A')),
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
      ]),
    );
  }
}
