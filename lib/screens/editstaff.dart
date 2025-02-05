import 'dart:convert';
import 'package:chitfunds/screens/createcustomer.dart';
import 'package:chitfunds/screens/stafflist.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditStaff extends StatefulWidget {
  final String? id;
  const EditStaff({Key? key, this.id}) : super(key: key);

  @override
  _CreateStaffState createState() => _CreateStaffState();
}

class _CreateStaffState extends State<EditStaff> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _staffNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _branchCodeController = TextEditingController();
  final TextEditingController _receiptNoController = TextEditingController();
  final TextEditingController _companyIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedBranch;
  String? selectedRights;
  List<Map<String, String>> branchData = [];
  String? selectedBranchName;
  String? selectedBranchId;
  bool isLoading = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.id != null) {
      fetchStaff(widget.id!);
    } else {
      _showError('Invalid branch ID provided.');
    }
    _fetchBranches(); // Fetch branches when the widget dependencies change
  }

  final List<String> branches = [
    'Head Office',
    'Kalayarkovil',
    'Manalmelkudi',
    'Paramakudi',
    'Ramanathapuram'
  ];
  final List<String> rights = [
    'Admin',
    'HR',
    'MD',
    'Manager',
    'Auditor',
    'Accounts',
    'System Entry',
    'Field Officer'
  ];
  Future<void> _updateBranchFields(Map<String, dynamic> branch) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance(); // Use await to get the instance
    final String? companyid = prefs.getString('companyId');

    _staffIdController.text = branch['staffId'] ?? '';
    _staffNameController.text = branch['staffName']?.toString() ?? '';
    _addressController.text = branch['address'] ?? '';
    _mobileNoController.text = branch['mobileNo'] ?? '';
    _userNameController.text = branch['userName'] ?? '';
    _passwordController.text = branch['password'] ?? '';

    setState(() {
      selectedBranchName = branch['branch']?.toString() ?? '';
      selectedBranch =
          selectedBranchName; // Sync selectedBranch with the dropdown
    });

    _branchCodeController.text = branch['branchCode'] ?? '';
    _receiptNoController.text = branch['receiptNo'] ?? '';
    selectedRights = branch['rights'] ?? '';
    _emailController.text = branch['email'] ?? '';
    _companyIdController.text = branch['companyid'] ?? '';
  }

  Future<void> _updateStaff() async {
    print('staff1');
    print('---------------${widget.id}');
    try {
      print('staff2');
      final url = Uri.parse('https://chits.tutytech.in/staff.php');

      final requestBody = {
        'type': 'update',
        'id': widget.id.toString(),
        'staffId': _staffIdController.text.trim(),
        'staffName': _staffNameController.text.trim(),
        'address': _addressController.text.trim(),
        'mobileNo': _mobileNoController.text.trim(),
        'userName': _userNameController.text.trim(),
        'password': _passwordController.text.trim(),
        'branch': selectedBranch,
        'branchCode': _branchCodeController.text.trim(),
        'receiptNo': _receiptNoController.text.trim(),
        'rights': selectedRights,
        'email': _emailController.text.trim(),
        'companyid': _companyIdController.text.trim(),
      };
      print('staff3');
      // Debugging prints
      debugPrint('Request URL: $url');
      debugPrint('Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      debugPrint('Response Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('staff4');
        final result = json.decode(response.body);
        if (result[0]['status'] == 0) {
          print('staff5');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff updated successfully!')),
          );
          Navigator.pop(context, true); // Return to the previous screen
        } else {
          print('staff5');
          _showError(result[0]['message'] ?? 'Failed to update scheme.');
        }
      } else {
        print('staff6');
        _showError('Failed to update scheme: ${response.body}');
      }
    } catch (error) {
      print('staff7');
      debugPrint('Error: $error');
      _showError('An error occurred: $error');
    }
  }

  // Future<void> _updateStaff() async {
  //   print('---------------${widget.id}');
  //   try {
  //     final url = Uri.parse('https://chits.tutytech.in/staff.php');

  //     final requestBody = {
  //       'type': 'update',
  //       'id': widget.id.toString(),
  //       'staffId': _staffIdController.text.trim(),
  //       'staffName': _staffNameController.text.trim(),
  //       'address': _addressController.text.trim(),
  //       'mobileNo': _mobileNoController.text.trim(),
  //       'userName': _userNameController.text.trim(),
  //       'password': _passwordController.text.trim(),
  //       'branch': selectedBranch,
  //       'branchCode': _branchCodeController.text.trim(),
  //       'receiptNo':
  //           _receiptNoController.text.trim(), // Ensure correct key name
  //       'rights': selectedRights,
  //       'email': _emailController.text.trim(),
  //       'companyid': _companyIdController.text.trim(),
  //     };

  //     // Debugging prints
  //     debugPrint('Request URL: $url');
  //     debugPrint('Request Body: ${json.encode(requestBody)}');

  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       },
  //       body: requestBody, // Correctly formatted form data
  //     );

  //     debugPrint('Response Code: ${response.statusCode}');
  //     debugPrint('Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final result = json.decode(response.body);

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Staff updated successfully!')),
  //       );
  //       Navigator.pop(context, true); // Return to the previous screen
  //     } else {
  //       _showError('Failed to update staff: ${response.body}');
  //     }
  //   } catch (error) {
  //     debugPrint('Error: $error');
  //     _showError('An error occurred: $error');
  //   }
  // }

  Future<void> fetchStaff(String id) async {
    const String _baseUrl = 'https://chits.tutytech.in/staff.php';
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'select'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> branchData = json.decode(response.body);

        // Find the branch with the matching ID
        final branch = branchData.firstWhere(
          (branch) => branch['id'].toString() == id,
          orElse: () => null,
        );

        if (branch != null) {
          setState(() {
            _updateBranchFields(branch);
            isLoading = false;
          });
        } else {
          _showError('No branch found with ID $id.');
        }
      } else {
        throw Exception('Failed to fetch branches');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void _showError(String message) {
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

  Future<void> _createStaff() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId = prefs.getString('staffId');
    final String? companyid = prefs.getString('companyId');

    // Check if the form is valid
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Exit the method if validation fails
    }

    final String apiUrl = 'https://chits.tutytech.in/staff.php';

    try {
      // Print the request URL and body for debugging
      print('Request URL: $apiUrl');
      print('Request body: ${{
        'type': 'insert',
        'staffId': _staffIdController.text,
        'staffName': _staffNameController.text,
        'address': _addressController.text,
        'mobileNo': _mobileNoController.text,
        'userName': _userNameController.text,
        'password': _passwordController.text,
        'branch': selectedBranchName,
        'branchCode': _branchCodeController.text,
        'receiptNo': _receiptNoController.text,
        'rights': selectedRights,
      }}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'insert',
          'staffId': _staffIdController.text,
          'staffName': _staffNameController.text,
          'address': _addressController.text,
          'mobileNo': _mobileNoController.text,
          'userName': _userNameController.text,
          'password': _passwordController.text,
          'branch': selectedBranchName ?? '', // Use default value if null
          'branchCode': _branchCodeController.text,
          'receiptNo': _receiptNoController.text,
          'rights': selectedRights ?? '', // Use default value if null
          'companyid': companyid ?? '', // Make sure companyid is not null
          'email': _emailController.text,
          'entryid': staffId ?? '', // Ensure staffId is not null
        },
      );

      // Print the response body for debugging
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['id'] != null) {
          _showSnackBar('Staff created successfully!');
        } else {
          _showSnackBar('Error: ${responseData['message']}');
        }
      } else {
        _showSnackBar(
            'Failed to create staff. Status code: ${response.statusCode}');
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => staffListPage(),
        ),
      );
    } catch (e) {
      // Print the error for debugging
      print('Error: $e');
      _showSnackBar('An error occurred: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Edit Staff',
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
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _staffIdController,
                        decoration: InputDecoration(
                          labelText: 'Enter Staff ID',
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
                            return 'Please enter your staff id';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _staffNameController,
                        decoration: InputDecoration(
                          labelText: 'Enter Staff Name',
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
                            return 'Please enter your staff name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _companyIdController,
                        decoration: InputDecoration(
                          labelText: 'CompanyID',
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
                            return 'Please enter your companyid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
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
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Enter Address',
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
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _mobileNoController,
                        decoration: InputDecoration(
                          labelText: 'Enter Mobile No',
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
                            return 'Please enter your mobileno';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _userNameController,
                        decoration: InputDecoration(
                          labelText: 'Enter User Name',
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
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Enter Password',
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
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      DropdownButtonFormField<String>(
                        value: selectedBranch,
                        onChanged: (newValue) {
                          setState(() {
                            selectedBranchId = newValue;
                            selectedBranchName = branchData.firstWhere(
                                (branch) => branch['id'] == newValue)['name'];
                            print('Selected Branch ID: $selectedBranchId');
                            print('Selected Branch Name: $selectedBranchName');
                          });
                        },
                        items: branchData
                            .map((branch) => DropdownMenuItem<String>(
                                  value: branch['name'],
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
                        controller: _branchCodeController,
                        decoration: InputDecoration(
                          labelText: 'Enter Branch Code',
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
                            return 'Please enter your branch code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _receiptNoController,
                        decoration: InputDecoration(
                          labelText: 'Enter Receipt No',
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
                            return 'Please enter your receiptno';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      DropdownButtonFormField<String>(
                        value: selectedRights,
                        decoration: InputDecoration(
                          labelText: 'Enter Rights',
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
                            return 'Please enter your rights';
                          }
                          return null;
                        },
                        items: rights.map((rights) {
                          return DropdownMenuItem<String>(
                            value: rights,
                            child: Text(rights),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRights = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 150, // Adjust the width as needed
                              child: ElevatedButton(
                                onPressed: () {
                                  _updateStaff();
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
                              width: 150, // Adjust the width as needed
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => LoanListPage(),
                                  //   ),
                                  // );
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
