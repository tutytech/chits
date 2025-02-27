import 'dart:math';

import 'package:chitfunds/screens/amountransfer.dart';
import 'package:chitfunds/screens/branchlist.dart';
import 'package:chitfunds/screens/createbranch.dart';
import 'package:chitfunds/screens/editcompany.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompanyCreationScreen extends StatefulWidget {
  final String? rights;
  const CompanyCreationScreen({Key? key, this.rights}) : super(key: key);

  @override
  _CompanyCreationScreenState createState() => _CompanyCreationScreenState();
}

class _CompanyCreationScreenState extends State<CompanyCreationScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedlogo = 'No file chosen';

  // Method to save company data to SharedPreferences and call the API
  Future<void> _saveCompanyData(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if the form is invalid
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Prepare data for company creation request
      final String companyName = _companyNameController.text;
      final String address = _gstinController.text;
      final String email = _emailController.text;
      final String phoneNumber = _phoneNumberController.text;
      final String? staffId = prefs.getString('staffId');

      final uri = Uri.parse('https://chits.tutytech.in/company.php');
      final requestBody = {
        'type': 'insert',
        'companyname': companyName,
        'address': address,
        'phoneno': phoneNumber,
        'mailid': email,
        'entryid': staffId,
        'entrydate': DateTime.now().toIso8601String().split('T').first,
      };

      print('Request URL: $uri');
      print('Request Body: $requestBody');

      final response = await http.post(
        uri,
        body: requestBody,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty && responseData[0]['id'] != null) {
          final int companyId = responseData[0]['id'];

          await prefs.setString('companyname', companyName);
          await prefs.setString('address', address);
          await prefs.setString('mailid', email);
          await prefs.setString('phoneno', phoneNumber);
          await prefs.setString('companyId', companyId.toString());

          print(
              'Saved Company Data: $companyName, $address, $email, $phoneNumber, $companyId');

          // Generate random password
          final String randomPassword = _generateRandomPassword(8);

          // Call _createStaff with company name as username and random password
          await _createStaff(companyName, randomPassword);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Company and Staff created successfully!')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditCompany(id: companyId.toString(), rights: widget.rights),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unexpected response format.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create company.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  String _generateRandomPassword(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<void> _createStaff(String companyName, String randomPassword) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? companyid = prefs.getString('companyId');

    final String staffApiUrl = 'https://chits.tutytech.in/staff.php';

    try {
      var staffRequest = http.MultipartRequest('POST', Uri.parse(staffApiUrl));
      staffRequest.fields.addAll({
        'type': 'insert',
        'userName': companyName,
        'password': randomPassword,
        'companyid': companyid ?? '',
      });

      final staffResponse = await staffRequest.send();
      final staffResponseBody = await staffResponse.stream.bytesToString();
      print('Staff response body: $staffResponseBody');

      if (staffResponse.statusCode == 200) {
        final Map<String, dynamic> staffData = json.decode(staffResponseBody);
      } else {
        _showSnackBar(
            'Failed to create staff. Status code: ${staffResponse.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('An error occurred: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _pickFileForLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedlogo = result.files.first.name;
        });
      } else {
        setState(() {
          selectedlogo = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.only(bottom: 100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'nobglogo.png',
                      height: 200,
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      'Create a Company',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _companyNameController,
                      decoration: InputDecoration(
                        labelText: 'Company Name',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Company name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _gstinController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Mail ID',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone No.',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Enter a valid 10-digit phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _saveCompanyData(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 221, 226, 240),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Create Company',
                          style: TextStyle(fontSize: 16),
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
