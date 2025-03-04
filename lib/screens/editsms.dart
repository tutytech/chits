import 'dart:convert';
import 'dart:math';
import 'package:chitfunds/screens/createcenter.dart';
import 'package:chitfunds/screens/saveddatashared.dart';
import 'package:flutter/material.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditSmsSettings extends StatefulWidget {
  final String? rights;
  final String? id;
  const EditSmsSettings({Key? key, this.id, this.rights}) : super(key: key);

  @override
  _SmsSettingsState createState() => _SmsSettingsState();
}

class _SmsSettingsState extends State<EditSmsSettings> {
  final TextEditingController _branchNameController = TextEditingController();
  List<Map<String, String>> branchData = [];
  final TextEditingController BranchNameController = TextEditingController();
  final TextEditingController presmsController = TextEditingController();
  final TextEditingController postsmsController = TextEditingController();
  final TextEditingController midsmsController = TextEditingController();

  String? selectedBranch;
  String? selectedDayOrder;
  String? selectedBranchName;
  String? selectedBranchId;
  String? selectedTiming;
  bool isLoading = true;
  String? selectedFieldOfficer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Added form key
  @override
  void initState() {
    super.initState();
    _fetchBranches();

    if (widget.id != null) {
      fetchSms(widget.id!);
    } else {
      _showError('Invalid branch ID provided.');
    }
  }

  void _updateBranchFields(Map<String, dynamic> branch) {
    presmsController.text = branch['presmslink']?.toString() ?? '';
    midsmsController.text = branch['midsmslink']?.toString() ?? '';
    postsmsController.text = branch['postsmslink']?.toString() ?? '';

    setState(() {
      selectedBranchId = branch['id']?.toString() ?? ''; // Store branchId
      selectedBranchName = branch['branch']?.toString() ?? ''; // Display name
    });

    print('Updated Branch ID: $selectedBranchId');
    print('Updated Branch Name: $selectedBranchName');
  }

  Future<void> fetchSms(String id) async {
    const String _baseUrl = 'https://chits.tutytech.in/sms.php';
    final requestBody = {'type': 'select'};

    try {
      print('Fetching SMS data...');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> smsData = json.decode(response.body);

        final smsEntry = smsData.firstWhere(
          (sms) => sms['id'].toString() == id,
          orElse: () => null,
        );

        if (smsEntry != null) {
          _updateBranchFields(smsEntry);
        } else {
          _showError('No SMS entry found with ID $id.');
        }
      } else {
        _showError(
            'Failed to fetch SMS data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      _showError('An error occurred: $e');
    }
  }

  void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  // Get the saved branch (ID and Name)

  Future<void> _fetchBranches() async {
    print('Starting branch fetch...');
    final String apiUrl = 'https://chits.tutytech.in/branch.php';

    try {
      print('Making API request...');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'select', // Fetch existing branches
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Processing response...');
        final responseData = json.decode(response.body);

        // Assuming responseData is a list of branches
        List<Map<String, String>> branches = [];

        for (var branch in responseData) {
          if (branch['id'] != null && branch['branchname'] != null) {
            branches.add({
              'id': branch['id'].toString(),
              'name': branch['branchname'],
            });
          }
        }

        print('Branches Parsed: $branches');

        if (branches.isNotEmpty) {
          print('Branches fetched successfully.');

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String? lastSavedBranchId = prefs.getString('branchId');
          final String? lastSavedBranchName = prefs.getString('branchName');
          print('--------------------$lastSavedBranchId');
          print('--------------------$lastSavedBranchName');

          setState(() {
            branchData = branches;

            if (lastSavedBranchId != null &&
                branches.any((branch) => branch['id'] == lastSavedBranchId)) {
              selectedBranchId = lastSavedBranchId;
              selectedBranchName = branches.firstWhere(
                (branch) => branch['id'] == lastSavedBranchId,
                orElse: () => {'id': '', 'name': ''},
              )['name']!;
            } else {
              print('No saved branch found, defaulting to first branch...');
              selectedBranchId = branches[0]['id'];
              selectedBranchName = branches[0]['name']!;
            }
          });

          print(
              'Selected Branch: ID = $selectedBranchId, Name = $selectedBranchName');
        } else {
          print('No branches available in the response.');
          setState(() {
            branchData = [];
            selectedBranchId = null;
            selectedBranchName = '';
          });
        }
      } else {
        print('Failed to fetch branches. HTTP error.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch branches.')),
        );
      }
    } catch (e) {
      print('Error during branch fetch: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _updateSmsData() async {
    print('---------------${widget.id}');
    try {
      final url = Uri.parse('https://chits.tutytech.in/sms.php');

      final requestBody = {
        'type': 'update',
        'id': widget.id.toString(),
        'presmslink': presmsController.text.trim(),
        'midsmslink': midsmsController.text.trim(),
        'postsmslink': postsmsController.text.trim(),
        'branch': selectedBranchName,
      };

      // Debugging prints
      debugPrint('Request URL: $url');
      debugPrint('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type':
              'application/x-www-form-urlencoded', // Ensure the server expects JSON
        },
        body: requestBody, // Send as JSON
      );

      debugPrint('Response Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result[0]['status'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SMS updated successfully!')),
          );
          Navigator.pop(context, true); // Return to the previous screen
        } else {
          _showError(result[0]['message'] ?? 'Failed to update scheme.');
        }
      } else {
        _showError('Failed to update scheme: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error: $error');
      _showError('An error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'SMS Settings',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(rights: widget.rights),
      body: Stack(
        children: [
          // Background Gradient
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Branch Name field
                      TextFormField(
                        controller: presmsController,
                        decoration: InputDecoration(
                          labelText: 'Pre SMS Link',
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
                            return 'Please enter Pre SMS Link';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Full Branch Name field
                      TextFormField(
                        controller: midsmsController,
                        decoration: InputDecoration(
                          labelText: 'Mid SMS Link',
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
                            return 'Please enter Mid SMS Link';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: postsmsController,
                        decoration: InputDecoration(
                          labelText: 'Post SMS Link',
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
                            return 'Please enter Post SMS Link';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Select Branch dropdown
                      DropdownButtonFormField<String>(
                        value: branchData.any((branch) =>
                                branch['id'].toString() == selectedBranchId)
                            ? selectedBranchId
                            : null, // Ensure null if no match found

                        onChanged: (newValue) {
                          setState(() {
                            selectedBranchId = newValue!;
                            selectedBranchName = branchData.firstWhere(
                              (branch) => branch['id'].toString() == newValue,
                              orElse: () => {'name': ''},
                            )['name'];
                            print('Selected Branch ID: $selectedBranchId');
                            print('Selected Branch Name: $selectedBranchName');
                          });
                        },

                        items: branchData.map((branch) {
                          final branchId = branch['id'].toString();
                          final branchName = branch['name'].toString();

                          return DropdownMenuItem<String>(
                            value: branchId, // Use branch ID as the value
                            child: Text(branchName), // Display branch name
                          );
                        }).toList(),

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

                      // Note Section
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          'Sample SMS Link:\nhttp://sms.tutytech.com/api/smsapi?key=32800508fc3a191ea2f7fcb92d1500b3&route=2&sender=TUTECH&number=\$mobile&templateid=1607100000000199136&sms=\$message',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Create Save button
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
                                    _updateSmsData();
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
