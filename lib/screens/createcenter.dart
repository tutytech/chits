import 'dart:convert';
import 'package:chitfunds/screens/centerlist..dart';
import 'package:chitfunds/screens/createscheme.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateCenter extends StatefulWidget {
  final String? rights;
  final List<String>? branches;
  const CreateCenter({Key? key, this.branches, this.rights}) : super(key: key);

  @override
  _CreateCenterState createState() => _CreateCenterState();
}

class _CreateCenterState extends State<CreateCenter> {
  final TextEditingController _centerNameController = TextEditingController();
  final TextEditingController _centeridController = TextEditingController();
  List<Map<String, String>> branchData = [];
  String? selectedBranch; // Holds the selected branch value
  List<String> branchNames =
      []; // List to hold branch names fetched from the API
  List<String> centerNames = [];
  String? selectedBranchName;
  String? selectedBranchId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchBranches(); // Fetch branches when the widget dependencies change
    _fetchCenters();
  }

  // Fetch branches from the API
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

  Future<void> _fetchCenters() async {
    final String apiUrl = 'https://chits.tutytech.in/center.php';

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

        if (responseData is List) {
          List<String> centers = [];
          for (var center in responseData) {
            if (center['centername'] != null) {
              centers.add(center['centername']);
            }
          }

          setState(() {
            centerNames = centers;
          });
        } else {
          _showSnackBar('Unexpected response format');
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

  Future<void> _createCenter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId = prefs.getString('staffId');
    final String? companyid = prefs.getString('companyid');
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, exit early
    }

    final String apiUrl = 'https://chits.tutytech.in/center.php';

    try {
      // Construct request body
      final body = {
        'type': 'insert',
        'centername': _centerNameController.text,
        'centercode': _centeridController.text,
        'branchname': selectedBranchId ?? '1',
        'entryid': staffId,
        'companyid': companyid,
      };

      // Print request URL and body
      print('Request URL: $apiUrl');
      print('Request Body: $body');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      // Print response status and body
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData[0]['id'] != null) {
          _showSnackBar('Center created successfully!');
        } else {
          _showSnackBar('Error: ${responseData[0]['error']}');
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CenterListPage(),
          ),
        );
      } else {
        _showSnackBar(
            'Failed to create center. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Create Center',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(rights: widget.rights),
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
                key: _formKey, // Attach form key to the form widget
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _centerNameController,
                        decoration: InputDecoration(
                          labelText: 'Enter Center Name',
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
                            return 'Please enter a center name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
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
                          labelText: 'Select Branch',
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
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _centeridController,
                        decoration: InputDecoration(
                          labelText: 'Enter Center ID',
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
                            return 'Please enter a center ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: _createCenter,
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
                                      builder: (context) => CenterListPage(),
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
        ],
      ),
    );
  }
}
