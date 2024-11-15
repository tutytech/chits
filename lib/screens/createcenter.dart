import 'dart:convert';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateCenter extends StatefulWidget {
  final List<String>? branches;
  const CreateCenter({
    this.branches,
  });

  @override
  _CreateCenterState createState() => _CreateCenterState();
}

class _CreateCenterState extends State<CreateCenter> {
  final TextEditingController _centerNameController = TextEditingController();
  final TextEditingController _centeridController = TextEditingController();
  String? selectedBranch; // Holds the selected branch value
  List<String> branchNames =
      []; // List to hold branch names fetched from the API

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchBranches(); // Fetch branches when the widget dependencies change
  }

  // Fetch branches from the API
  Future<void> _fetchBranches() async {
    final String apiUrl = 'https://chits.tutytech.in/branch.php';

    try {
      print("Request URL: $apiUrl");
      print("Request Body: { 'type': 'select' }");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'select', // Assuming 'select' fetches all branches
        },
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print(
          "Response Body: ${response.body.isNotEmpty ? response.body : 'No content'}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<String> branches = [];
        for (var branch in responseData) {
          if (branch['branchname'] != null) {
            branches.add(branch['branchname']);
          }
        }

        setState(() {
          branchNames = branches;
        });

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

  // Show Snackbar for feedback messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Create Center API call
  Future<void> _createCenter() async {
    final String apiUrl = 'https://chits.tutytech.in/center.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'insert',
          'centername': _centerNameController.text,
          'centercode': _centeridController.text,
          'branchid':
              selectedBranch ?? '1', // Use selectedBranch or default to '1'
          'entryid': '123', // Replace with a real entry ID if needed
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData[0]['id'] != null) {
          _showSnackBar('Center created successfully!');
        } else {
          _showSnackBar('Error: ${responseData[0]['error']}');
        }
      } else {
        _showSnackBar(
            'Failed to create center. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
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
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    TextField(
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
                    ),
                    const SizedBox(height: 20),
                    // Dropdown for selecting a branch
                    DropdownButtonFormField<String>(
                      value: selectedBranch,
                      onChanged: (newValue) {
                        setState(() {
                          selectedBranch = newValue;
                        });
                      },
                      items: branchNames
                          .map((branchName) => DropdownMenuItem<String>(
                                value: branchName,
                                child: Text(branchName),
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
                    ),
                    const SizedBox(height: 20),
                    TextField(
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
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createCenter,
                        child: const Text(
                          'Create Center',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
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
