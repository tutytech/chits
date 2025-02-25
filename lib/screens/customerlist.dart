import 'package:chitfunds/screens/createbranch.dart';
import 'package:chitfunds/screens/createcustomer.dart';
import 'package:chitfunds/screens/editcustomer.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CustomerList extends StatefulWidget {
  final String? rights;
  CustomerList({Key? key, this.rights}) : super(key: key);

  @override
  _BranchListPageState createState() => _BranchListPageState();
}

class _BranchListPageState extends State<CustomerList> {
  late Future<List<Map<String, dynamic>>> _branchListFuture;
  List<Map<String, dynamic>> _allBranches = [];
  List<Map<String, dynamic>> _filteredBranches = [];
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> branchNames = [];
  String? _staffId;

  @override
  void initState() {
    super.initState();
    _branchListFuture = fetchCustomers();
    _searchController.addListener(() {
      _filterBranches(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> deleteCustomer(String branchId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId = prefs.getString('staffId');

    // Check if staffId is null
    if (staffId == null || staffId.isEmpty) {
      print('Error: staffId is null or empty');
      return; // Exit the method early if staffId is not available
    }

    const String apiUrl = 'https://chits.tutytech.in/customer.php';
    print('------------------$staffId');

    try {
      // Send the POST request with form data
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'type': 'delete',
          'id': branchId,
          'delid': staffId,
        },
      );

      // Print the response status and body for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check if the response is successful (HTTP status 200)
      if (response.statusCode == 200) {
        // Parse the response body as a list
        final List<dynamic> responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty && responseData[0]['status'] == 'success') {
          print('Customer deleted successfully: ${responseData[0]['message']}');
          // Optionally, fetch updated customers or perform other actions here
        } else {
          print('Failed to delete customer: ${responseData[0]['message']}');
        }
      } else {
        print('Failed to delete customer. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    const String _baseUrl = 'https://chits.tutytech.in/customer.php';
    final Map<String, String> body = {'type': 'fetch'};

    try {
      print('Request URL: $_baseUrl');
      print('Request Body: $body');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse['success'] == true &&
            decodedResponse['customerDetails'] is List) {
          return List<Map<String, dynamic>>.from(
              decodedResponse['customerDetails'].map((customer) {
            return {
              'id': customer['id'] ?? '',
              'customerId': customer['customerId'] ?? 'Unknown customer',
              'name': customer['name']?.toString() ?? 'N/A',
              'address': customer['address'] ?? 'N/A',
              'phoneNo': customer['phoneNo'] ?? 'N/A',
              'aadharNo': customer['aadharNo'] ?? 'N/A',
              'collectionstaff': customer['collectionstaff'] ?? 'N/A',
              'branch': customer['branch'] ?? 'N/A',
              'center': customer['center'] ?? 'N/A',
              'latitude': customer['latitude'] ?? 'N/A',
              'longitude': customer['longitude'] ?? 'N/A',
              'uploadAadhar': customer['uploadAadhar'] ?? '',
              'uploadvoterId': customer['uploadvoterId'] ?? '',
              'uploadPan': customer['uploadPan'] ?? '',
              'uploadNomineeAadharCard':
                  customer['uploadNomineeAadharCard'] ?? '',
              'uploadNomineeVoterId': customer['uploadNomineeVoterId'] ?? '',
              'uploadNomineePan': customer['uploadNomineePan'] ?? '',
              'uploadRationCard': customer['uploadRationCard'] ?? '',
              'uploadbondsheet': customer['uploadbondsheet'] ?? '',
              'uploadChequeLeaf': customer['uploadChequeLeaf'] ?? '',
              'uploadGasBill': customer['uploadGasBill'] ?? '',
              'uploadEbBill': customer['uploadEbBill'] ?? '',
              'uploadPropertyTaxReceipt':
                  customer['uploadPropertyTaxReceipt'] ?? '',
              'customerPhoto': customer['customerPhoto'] ?? '',
            };
          }));
        } else if (decodedResponse['error'] != null) {
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

  Widget buildCustomerList(List<Map<String, dynamic>> customers) {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Card(
          child: ListTile(
            title: Text(customer['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Branch: ${customer['branch']}'),
                Text('Center: ${customer['center']}'),
                Text('Address: ${customer['address']}'),
                Text('Phone: ${customer['phoneNo']}'),
                Text('Aadhar: ${customer['aadharNo']}'),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _filterBranches(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBranches = _allBranches;
      } else {
        _filteredBranches = _allBranches
            .where((branch) => branch['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _deleteBranch(String branchId) async {
    try {
      await deleteCustomer(branchId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Branch deleted successfully')),
      );
      _refreshBranchList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting branch: $e')),
      );
    }
  }

  void _refreshBranchList() {
    setState(() {
      _branchListFuture = fetchCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Customer List',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(branchNames: branchNames, rights: widget.rights),
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
                // Search bar container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2), // Shadow position
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Customers',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateCustomer(rights: widget.rights),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button background color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8.0), // Rounded corners
                        ),
                      ),
                      child: const Text(
                        'Add Customer',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white), // Text styling
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                // Fetched data container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2), // Shadow position
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _branchListFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No branches found'));
                      }

                      _allBranches = snapshot.data!;
                      _filteredBranches = _searchController.text.isEmpty
                          ? _allBranches
                          : _filteredBranches;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width),
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors
                                  .grey[200]!, // Light background for headers
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Customer ID',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(
                                        0xFF4A90E2), // Blue color to match gradient theme
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Customer Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(
                                        0xFF4A90E2), // Blue color to match gradient theme
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Address',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF4A90E2),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'PhoneNo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF4A90E2),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'AadharNo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF4A90E2),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Branch',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF4A90E2),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Center',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF4A90E2),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Actions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF4A90E2),
                                  ),
                                ),
                              ),
                            ],
                            rows: _filteredBranches.map((branch) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(branch['customerId'] ?? 'N/A')),
                                  DataCell(Text(branch['name'] ?? '0')),
                                  DataCell(Text(branch['address'] ?? 'N/A')),
                                  DataCell(Text(branch['phoneNo'] ?? 'N/A')),
                                  DataCell(Text(branch['aadharNo'] ?? 'N/A')),
                                  DataCell(Text(branch['branch'] ?? 'N/A')),
                                  DataCell(Text(branch['center'] ?? 'N/A')),
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () {
                                            // Print the branch ID for debugging
                                            print('Branch ID: ${branch['id']}');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditCustomer(
                                                        id: branch['id'],
                                                        rights: widget.rights),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              deleteCustomer(branch['id']),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
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
