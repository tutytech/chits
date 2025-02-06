import 'package:chitfunds/screens/createbranch.dart';
import 'package:chitfunds/screens/customerreceipt.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class closeAccountList extends StatefulWidget {
  const closeAccountList({Key? key}) : super(key: key);

  @override
  _BranchListPageState createState() => _BranchListPageState();
}

class _BranchListPageState extends State<closeAccountList> {
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
    _branchListFuture = fetchcloseaccount();
    _searchController.addListener(() {
      _filterBranches(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> deleteLoan(String branchId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId = prefs.getString('staffId');
    const String apiUrl = 'https://chits.tutytech.in/receipt.php';

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
        // Parse the response body as JSON
        final responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty && responseData[0]['status'] == 'success') {
          print('Branch deleted successfully: ${responseData[0]['message']}');
          // Optionally, fetch updated branches or perform other actions here
        } else {
          print('Failed to delete branch: ${responseData[0]['message']}');
        }
      } else {
        print('Failed to delete branch. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchcloseaccount() async {
    const String _baseUrl = 'https://chits.tutytech.in/closeaccount.php';

    try {
      // Debug: Print the request URL and parameters
      print('Request URL: $_baseUrl');
      print('Request Body: type=select');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'select'},
      );

      // Debug: Print the response
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as List<dynamic>;

        // Handle missing keys safely
        return responseData.map((branch) {
          return {
            'id': branch['id'] ?? '',
            'userid': branch['userid'] ?? 'Unknown Branch',
            'todaydate': branch['todaydate']?.toString() ?? '0',
            'closetime': branch['closetime'] ?? 'N/A',
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch branches');
      }
    } catch (e) {
      // Debug: Print the error
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  void _filterBranches(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBranches = _allBranches;
      } else {
        _filteredBranches = _allBranches
            .where((branch) => branch['userid']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> deleteBranch(String branchId) async {
    const String _baseUrl = 'https://chits.tutytech.in/branch.php';
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'delete', 'branchid': branchId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete branch');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> _deleteBranch(String branchId) async {
    try {
      await deleteBranch(branchId);
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
      _branchListFuture = fetchcloseaccount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Close Account',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(branchNames: branchNames),
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
                      labelText: 'Search Close Account',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
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
                                  'ID',
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
                                  'UserID',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF4A90E2),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'TodayDate',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF4A90E2),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'CloseTime',
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
                                  DataCell(Text(branch['id'] ?? 'N/A')),
                                  DataCell(Text(branch['userid'] ?? '0')),
                                  DataCell(Text(branch['todaydate'] ?? 'N/A')),
                                  DataCell(Text(branch['closetime'] ?? 'N/A')),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: branch['isLocked'] == true
                                          ? null // Disable the button when already locked
                                          : () {
                                              print('press1');
                                              String currentCloseTime =
                                                  branch['closetime'] ?? '';
                                              final DateFormat formatter =
                                                  DateFormat('HH:mm');
                                              DateTime parsedCloseTime =
                                                  formatter
                                                      .parse(currentCloseTime);
                                              DateTime newCloseTime =
                                                  parsedCloseTime.add(
                                                      Duration(minutes: 30));
                                              String updatedCloseTime =
                                                  formatter
                                                      .format(newCloseTime);
                                              // Update the branch data with the new close time
                                              branch['closetime'] =
                                                  updatedCloseTime;
                                              // Mark the branch as locked to prevent further updates
                                              branch['isLocked'] = true;
                                              setState(() {});
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: branch['isLocked'] ==
                                                true
                                            ? Colors
                                                .grey // Grey color for "Locked" state
                                            : Colors
                                                .blue, // Blue color for "Release" state
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0, vertical: 12.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Rounded corners
                                        ),
                                      ),
                                      child: Text(
                                        branch['isLocked'] == true
                                            ? 'Locked' // Display "Locked" if the branch is locked
                                            : 'Release', // Display "Release" if the branch is not locked
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white, // Text color
                                        ),
                                      ),
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
