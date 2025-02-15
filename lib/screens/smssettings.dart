import 'dart:convert';

import 'package:chitfunds/screens/createcenter.dart';
import 'package:chitfunds/screens/editsms.dart';
import 'package:flutter/material.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SmsSettings extends StatefulWidget {
  final String? rights;
  const SmsSettings({Key? key, this.rights}) : super(key: key);

  @override
  _SmsSettingsState createState() => _SmsSettingsState();
}

class _SmsSettingsState extends State<SmsSettings> {
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
  String? selectedFieldOfficer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Added form key
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchBranches();
  }

  Future<void> _createsms() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? companyid = prefs.getString('companyId');
    if (!(_formKey.currentState?.validate() ?? true)) {
      return; // Exit the method if validation fails
    }

    final String apiUrl = 'https://chits.tutytech.in/sms.php';

    // Prepare request body
    final body = {
      'type': 'insert',
      'presmslink': presmsController.text,
      'midsmslink': midsmsController.text,
      'postsmslink': postsmsController.text,
      'branch': selectedBranchName,
      'companyid': companyid,
    };

    try {
      print('Request URL: $apiUrl');
      print('Request Body: $body');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData[0]['id'] != null) {
          final int smsId = responseData[0]['id'];

          // Save all values to SharedPreferences
          final prefs = await SharedPreferences.getInstance();

          // Save each field
          await prefs.setString('smsId', smsId.toString());
          await prefs.setString('presmslink', presmsController.text);
          await prefs.setString('midsmslink', midsmsController.text);
          await prefs.setString('postsmslink', postsmsController.text);
          await prefs.setString('branchName', selectedBranchName.toString());

          // Print saved values for debugging
          final savedSmsId = prefs.getString('smsId');
          final savedPresmsLink = prefs.getString('presmslink');
          final savedMidsmsLink = prefs.getString('midsmslink');
          final savedPostsmsLink = prefs.getString('postsmslink');
          final savedBranch = prefs.getString('branchName');

          print('Saved SMS ID: $savedSmsId');
          print('Saved Pre-SMS Link: $savedPresmsLink');
          print('Saved Mid-SMS Link: $savedMidsmsLink');
          print('Saved Post-SMS Link: $savedPostsmsLink');
          print('Saved Branch Name: $savedBranch');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SMS created successfully!')),
          );

          await _fetchBranches();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditSmsSettings(id: smsId.toString()),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData[0]['error']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create branch.')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
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
                        value: selectedBranchId,
                        onChanged: (newValue) {
                          setState(() {
                            selectedBranchId = newValue;
                            selectedBranchName = branchData.firstWhere(
                                (branch) => branch['id'] == newValue)['name'];
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
                                    _createsms();
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
