import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditCompany extends StatefulWidget {
  const EditCompany({Key? key}) : super(key: key);

  @override
  _EditCompanyState createState() => _EditCompanyState();
}

class _EditCompanyState extends State<EditCompany> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCompanyData(); // Load existing company details on startup
  }

  // Method to load company data from SharedPreferences
  Future<void> _loadCompanyData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _companyNameController.text = prefs.getString('companyName') ?? '';
      _gstinController.text = prefs.getString('gstin') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneNumberController.text = prefs.getString('phoneNumber') ?? '';
    });
    print('$_companyNameController.text');
    print('$_gstinController.text');
    print('$_emailController.text');
    print('$_phoneNumberController.text');
  }

  // Method to save (update) company data to SharedPreferences
  Future<void> _saveCompanyData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save updated company details
    await prefs.setString('companyName', _companyNameController.text);
    await prefs.setString('gstin', _gstinController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('phoneNumber', _phoneNumberController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Company details updated successfully!')),
    );
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
                  const Text(
                    'Edit Company',
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
                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Save updated company details to SharedPreferences
                        await _saveCompanyData();
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
                        'Update Company',
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
