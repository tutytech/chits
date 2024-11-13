import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompanyCreationScreen extends StatefulWidget {
  const CompanyCreationScreen({Key? key}) : super(key: key);

  @override
  _CompanyCreationScreenState createState() => _CompanyCreationScreenState();
}

class _CompanyCreationScreenState extends State<CompanyCreationScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String selectedlogo = 'No file chosen';

  // Method to save company data to SharedPreferences and call the API
  Future<void> _saveCompanyData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Save the data locally using SharedPreferences
    await prefs.setString('companyname', _companyNameController.text);
    await prefs.setString('address', _gstinController.text);
    await prefs.setString('mailid', _emailController.text);
    await prefs.setString('phoneno', _phoneNumberController.text);

    print('Saved Company Name: ${prefs.getString('companyname')}');
    print('Saved Address: ${prefs.getString('address')}');
    print('Saved Email: ${prefs.getString('mailid')}');
    print('Saved Phone Number: ${prefs.getString('phoneno')}');

    try {
      // Construct the request URL
      final uri = Uri.parse('https://chits.tutytech.in/company.php');

      // Prepare the form data (key-value pairs)
      final response = await http.post(
        uri,
        body: {
          'type': 'insert',
          'companyname': _companyNameController.text,
          'address': _gstinController.text,
          'phoneno': _phoneNumberController.text,
          'mailid': _emailController.text,
          'entryid': '12345', // You might want to dynamically get this value
          'entrydate': DateTime.now()
              .toIso8601String()
              .split('T')
              .first, // Format the date as YYYY-MM-DD
        },
        headers: {
          'Content-Type':
              'application/x-www-form-urlencoded', // Ensure form-data is used
        },
      );

      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        // Log raw response
        print('Raw Response: ${response.body}');

        // Decode the response
        final List<dynamic> responseData = jsonDecode(response.body);

        // Check if there's an error in the response
        if (responseData.isNotEmpty && responseData[0]['error'] != null) {
          print('API Error: ${responseData[0]['error']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData[0]['error']}')),
          );
        } else {
          print('Company created successfully: $responseData');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Company created successfully!')),
          );
        }
      } else {
        // Handle unexpected status codes
        print('Failed to create company. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create company.')),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
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
                  TextField(
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
                  ),
                  const SizedBox(height: 20),
                  TextField(
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
                  ),
                  const SizedBox(height: 20),
                  TextField(
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
                  ),
                  const SizedBox(height: 20),
                  TextField(
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
