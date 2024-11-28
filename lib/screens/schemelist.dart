import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchemeListPage extends StatefulWidget {
  const SchemeListPage({Key? key}) : super(key: key);

  @override
  _BranchListPageState createState() => _BranchListPageState();
}

class _BranchListPageState extends State<SchemeListPage> {
  late Future<List<Map<String, dynamic>>> _branchListFuture;
  List<Map<String, dynamic>> _allSchemes = [];
  List<Map<String, dynamic>> _filteredSchemes = [];
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> branchNames = [];

  @override
  void initState() {
    super.initState();
    _branchListFuture = fetchSchemes();
    _searchController.addListener(() {
      _filterBranches(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _filterBranches(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSchemes = _allSchemes;
      } else {
        _filteredSchemes = _allSchemes
            .where((branch) => branch['schemename']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> deleteBranch(String branchId) async {
    const String _baseUrl = 'https://chits.tutytech.in/center.php';
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
      _branchListFuture = fetchSchemes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Scheme List',
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
                      labelText: 'Search Schemes',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(
                    height: 16.0), // Space between search bar and data table

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

                      _allSchemes = snapshot.data!;
                      _filteredSchemes = _searchController.text.isEmpty
                          ? _allSchemes
                          : _filteredSchemes;

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
                                  'Scheme ID',
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
                                  'Scheme Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF4A90E2),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Loan Amount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF4A90E2),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Collection Type',
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
                            rows: _filteredSchemes.map((branch) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(branch['schemeid'] ?? 'N/A')),
                                  DataCell(Text(branch['schemename'] ?? '0')),
                                  DataCell(Text(branch['amount'] ?? 'N/A')),
                                  DataCell(
                                      Text(branch['collectiontype'] ?? 'N/A')),
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
