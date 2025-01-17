import 'dart:convert';
import 'package:chitfunds/screens/centerlist..dart';

import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditCenter extends StatefulWidget {
  final String? centerId; // ID of the center to edit
  const EditCenter({
    Key? key,
    this.centerId,
  }) : super(key: key);

  @override
  _EditCenterState createState() => _EditCenterState();
}

class _EditCenterState extends State<EditCenter> {
  final TextEditingController _centerNameController = TextEditingController();
  final TextEditingController _centerIdController = TextEditingController();
  List<Map<String, String>> branchData = [];
  String? selectedBranchId; // Holds the selected branch ID
  String? selectedBranchName;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
    if (widget.centerId != null) {
      _fetchCenterData(widget.centerId!);
    } else {
      _showError('Invalid branch ID provided.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      isLoading = false;
    });
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

  Future<void> _fetchCenterData(String branchId) async {
    try {
      final response = await http.post(
        Uri.parse('https://chits.tutytech.in/center.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'select'},
      );
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> branchData = json.decode(response.body);

        // Find the branch with the matching ID
        final branch = branchData.firstWhere(
          (branch) => branch['id'].toString() == branchId,
          orElse: () => null,
        );

        if (branch != null) {
          setState(() {
            _updateBranchFields(branch);
            isLoading = false;
          });
        } else {
          _showError('No branch found with ID $branchId.');
        }
      } else {
        _showError('Failed to load branch data: ${response.body}');
      }
    } catch (error) {
      _showError('An error occurred: $error');
    }
  }

  void _updateBranchFields(Map<String, dynamic> branch) {
    _centerNameController.text = branch['centername'] ?? '';
    selectedBranchId = branch['branchid']?.toString() ?? '';
    _centerIdController.text = branch['centercode'] ?? '';
  }

  Future<void> updateCenter() async {
    // Validate user inputs before sending
    if (_centerNameController.text.trim().isEmpty) {
      showErrorSnackBar('Center name is required');
      return;
    }
    if (_centerIdController.text.trim().isEmpty) {
      showErrorSnackBar('Center code is required');
      return;
    }
    if (selectedBranchId == null || selectedBranchId!.isEmpty) {
      showErrorSnackBar('Branch ID is required');
      return;
    }

    // Print the values of centername, centercode, and branchid
    print('Center Name: ${_centerNameController.text.trim()}');
    print('Center Code: ${_centerIdController.text.trim()}');
    print('Branch ID: $selectedBranchId');

    // Prepare data to be sent
    final centerData = {
      'type': 'update',
      'id': widget.centerId?.toString() ?? '',
      'centername': _centerNameController.text.trim(),
      'centercode': _centerIdController.text.trim(),
      'branchid': selectedBranchId,
    };

    try {
      final url = Uri.parse('https://chits.tutytech.in/center.php');
      print('Request URL: $url');
      print('Request Body: $centerData');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: centerData,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final result = json.decode(response.body);
          if (result[0]['status'] == '0') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Center updated successfully!')),
            );
            Navigator.pop(context, true); // Return to the previous screen
          } else {
            showErrorSnackBar(
                result[0]['message'] ?? 'Failed to update center.');
          }
        } else {
          showErrorSnackBar('No response received from the server.');
        }
      } else {
        showErrorSnackBar('Failed to update center: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
      showErrorSnackBar('An error occurred: $error');
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.red))),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.green))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Center',
        onMenuPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      drawer: CustomDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _centerNameController,
                            decoration: InputDecoration(
                              labelText: 'Enter Center Name',
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
                                    (branch) =>
                                        branch['id'] == newValue)['name'];
                              });
                            },
                            items: branchData
                                .map((branch) => DropdownMenuItem<String>(
                                      value: branch['id'],
                                      child: Text(branch['name']!),
                                    ))
                                .toList(),
                            decoration: InputDecoration(
                              labelText: 'Select Branch',
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
                            controller: _centerIdController,
                            decoration: InputDecoration(
                              labelText: 'Enter Center ID',
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
                                    onPressed: () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        updateCenter();
                                      }
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
                                  width: 150,
                                  child: ElevatedButton(
                                    onPressed: () {},
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
              ],
            ),
    );
  }
}
