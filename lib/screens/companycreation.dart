import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Method to save company data to SharedPreferences
  Future<void> _saveCompanyData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save the data
    await prefs.setString('companyName', _companyNameController.text);
    await prefs.setString('gstin', _gstinController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('phoneNumber', _phoneNumberController.text);

    // Fetch and print the saved data from SharedPreferences
    final savedCompanyName = prefs.getString('companyName');
    final savedGstin = prefs.getString('gstin');
    final savedEmail = prefs.getString('email');
    final savedPhoneNumber = prefs.getString('phoneNumber');

    // Print the data to the console
    print('Saved Company Name: $savedCompanyName');
    print('Saved GSTIN: $savedGstin');
    print('Saved Email: $savedEmail');
    print('Saved Phone Number: $savedPhoneNumber');
  }

  void _pickFileForLogo() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedlogo = result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
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
          // Main Content
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset(
                    'nobglogo.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                  // Heading
                  const Text(
                    'Create a Company',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Company Name Input
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
                  // GSTIN Input
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
                  // Email Input
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
                  // Phone Number Input
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

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Save company data to SharedPreferences
                        await _saveCompanyData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Company created successfully!')),
                        );
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
          // Footer Section
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
