import 'package:chitfunds/screens/createbranch.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class staffListPage extends StatefulWidget {
  const staffListPage({Key? key}) : super(key: key);

  @override
  _BranchListPageState createState() => _BranchListPageState();
}

class _BranchListPageState extends State<staffListPage> {
  late Future<List<Map<String, dynamic>>> _branchListFuture;
  List<Map<String, dynamic>> _allBranches = [];
  List<Map<String, dynamic>> _filteredBranches = [];
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> branchNames = [];

  @override
  void initState() {
    super.initState();
    _branchListFuture = fetchBranches();
    _searchController.addListener(() {
      _filterBranches(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchBranches() async {
    const String _baseUrl = 'https://chits.tutytech.in/staff.php';
    const Map<String, String> _headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    const Map<String, String> _body = {'type': 'select'};

    try {
      print('Sending request to $_baseUrl');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: _body,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as List<dynamic>;
        return responseData
            .map((branch) => {
                  'id': branch['id'] ?? '',
                  'staffId': branch['staffId'] ?? 'Unknown',
                  'staffName': branch['staffName'] ?? 'Unknown',
                  'address': branch['address'] ?? 'Unknown',
                  'mobileNo': branch['mobileNo'] ?? 'N/A',
                  'userName': branch['userName'] ?? 'N/A',
                  'branch': branch['branch'] ?? 'N/A',
                  'branchCode': branch['branchCode'] ?? 'N/A',
                  'password': branch['password'] ?? 'N/A',
                  'receiptNo': branch['receiptNo'] ?? 'N/A',
                  'rights': branch['rights'] ?? 'N/A',
                })
            .toList();
      } else {
        throw Exception(
            'Failed to fetch branches. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error: $e');
    }
  }

  void _filterBranches(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBranches = _allBranches;
      } else {
        _filteredBranches = _allBranches
            .where((branch) => branch['staffName']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> deleteBranch(String branchId) async {
    const String _baseUrl = 'https://chits.tutytech.in/staff.php';
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
      _branchListFuture = fetchBranches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Staff List',
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
                    labelText: 'Search Staffs',
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
                          builder: (context) => CreateBranch(),
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
                      'Add Staff',
                      style: TextStyle(
                          fontSize: 16.0, color: Colors.white), // Text styling
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
                                'Staff ID',
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
                                'Staff Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF4A90E2),
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
                                'MobileNo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF4A90E2),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'UserName',
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
                                'Password',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF4A90E2),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'BranchCode',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF4A90E2),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'ReceiptNo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF4A90E2),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Rights',
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
                                DataCell(Text(branch['staffId'] ?? 'N/A')),
                                DataCell(Text(branch['staffName'] ?? '0')),
                                DataCell(Text(branch['address'] ?? 'N/A')),
                                DataCell(Text(branch['mobileNo'] ?? 'N/A')),
                                DataCell(Text(branch['userName'] ?? 'N/A')),
                                DataCell(Text(branch['password'] ?? 'N/A')),
                                DataCell(Text(branch['branch'] ?? 'N/A')),
                                DataCell(Text(branch['branchCode'] ?? 'N/A')),
                                DataCell(Text(branch['receiptNo'] ?? 'N/A')),
                                DataCell(Text(branch['rights'] ?? 'N/A')),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Edit feature not implemented'),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deleteBranch(branch['id']),
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
