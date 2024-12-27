import 'package:chitfunds/screens/branchlist.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EditBranch extends StatefulWidget {
  final String? id; // Pass the branch ID to load specific data

  const EditBranch({Key? key, this.id}) : super(key: key);

  @override
  _EditBranchState createState() => _EditBranchState();
}

class _EditBranchState extends State<EditBranch> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _openingBalanceController =
      TextEditingController();
  final TextEditingController dobController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _fetchBranchData(widget.id!);
    } else {
      _showError('Invalid branch ID provided.');
    }
  }

  Future<void> _fetchBranchData(String branchId) async {
    try {
      final response = await http.post(
        Uri.parse('https://chits.tutytech.in/branch.php'),
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
    _branchNameController.text = branch['branchname'] ?? '';
    _openingBalanceController.text = branch['openingbalance']?.toString() ?? '';
    dobController.text = branch['openingdate'] ?? '';
  }

  Future<void> _updateBranchData() async {
    try {
      final url = Uri.parse('https://chits.tutytech.in/branch.php');
      final requestBody = {
        'type': 'update',
        'id': widget.id.toString(), // Pass the correct ID
        'branchname': _branchNameController.text.trim(),
        'openingbalance': _openingBalanceController.text.trim(),
        'openingdate': dobController.text.trim(),
      };
      debugPrint('Request URL: $url');
      debugPrint('Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      debugPrint('Response Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result[0]['status'] == '0') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Branch updated successfully!')),
          );
          Navigator.pop(context, true); // Return to the previous screen
        } else {
          _showError(result[0]['message'] ?? 'Failed to update branch.');
        }
      } else {
        _showError('Failed to update branch: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error: $error');
      _showError('An error occurred: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Edit Branch',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(branchNames: []),
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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50),
                          TextFormField(
                            controller: _branchNameController,
                            decoration: InputDecoration(
                              labelText: 'Branch Name',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Branch name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _openingBalanceController,
                            decoration: InputDecoration(
                              labelText: 'Opening Balance',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Opening balance is required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: dobController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Opening Date',
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
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    dobController.text =
                                        DateFormat('yyyy-MM-dd').format(picked);
                                  }
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Opening date is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    _updateBranchData();
                                  }
                                },
                                child: const Text('Save'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
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
