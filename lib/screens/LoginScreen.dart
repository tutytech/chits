import 'dart:convert';

import 'package:chitfunds/screens/companycreation.dart';
import 'package:chitfunds/screens/dashboard.dart';
import 'package:chitfunds/screens/sendotp.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'registration.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    const String _baseUrl = 'https://chits.tutytech.in/customer.php';
    final Map<String, String> body = {'type': 'fetch'};

    try {
      print('Request URL: $_baseUrl');
      print('Request Body: $body');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse['success'] == true &&
            decodedResponse['customerDetails'] is List) {
          return List<Map<String, dynamic>>.from(
              decodedResponse['customerDetails'].map((customer) {
            return {
              'id': customer['id'] ?? '',
              'customerId': customer['customerId'] ?? 'Unknown customer',
              'name': customer['name']?.toString() ?? 'N/A',
              'address': customer['address'] ?? 'N/A',
              'phoneNo': customer['phoneNo'] ?? 'N/A',
              'aadharNo': customer['aadharNo'] ?? 'N/A',
              'branch': customer['branch'] ?? 'N/A',
              'center': customer['center'] ?? 'N/A',
              'latitude': customer['latitude'] ?? 'N/A',
              'longitude': customer['longitude'] ?? 'N/A',
              'uploadAadhar': customer['uploadAadhar'] ?? '',
              'uploadvoterId': customer['uploadvoterId'] ?? '',
              'uploadPan': customer['uploadPan'] ?? '',
              'uploadNomineeAadharCard':
                  customer['uploadNomineeAadharCard'] ?? '',
              'uploadNomineeVoterId': customer['uploadNomineeVoterId'] ?? '',
              'uploadNomineePan': customer['uploadNomineePan'] ?? '',
              'uploadRationCard': customer['uploadRationCard'] ?? '',
              'uploadbondsheet': customer['uploadbondsheet'] ?? '',
              'uploadChequeLeaf': customer['uploadChequeLeaf'] ?? '',
              'uploadGasBill': customer['uploadGasBill'] ?? '',
              'uploadEbBill': customer['uploadEbBill'] ?? '',
              'uploadPropertyTaxReceipt':
                  customer['uploadPropertyTaxReceipt'] ?? '',
              'customerPhoto': customer['customerPhoto'] ?? '',
            };
          }));
        } else if (decodedResponse['error'] != null) {
          throw Exception('API Error: ${decodedResponse['error']}');
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to fetch customers (HTTP ${response.statusCode})');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error: $e');
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final url = 'https://chits.tutytech.in/staff.php';

      try {
        final body = {
          'type': 'login',
          'username': _emailController.text,
          'password': _passwordController.text,
        };

        print('Request URL: $url');
        print('Request Body: $body');

        final response = await http.post(
          Uri.parse(url),
          body: body,
        );

        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        final responseData = json.decode(response.body);

        if (response.statusCode == 200) {
          if (responseData['success'] == true) {
            final staffId = responseData['staffId'];
            final rights = responseData['rights'];
            final profileUrl = responseData['profileUrl'] ?? '';
            final id = responseData['id'] ?? ''; // Make it an integer

            print('Received Staff ID: $staffId');
            print('Received Rights: $rights');
            print('Received Profile URL: $profileUrl');
            print('Received ID: $id');
            if (staffId != null && rights != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', true);
              await prefs.setString('lastScreen', 'Dashboard');

              print('Staff ID saved in SharedPreferences: $staffId');
              print('User Rights saved in SharedPreferences: $rights');
              await prefs.setBool('isLoggedIn', true);
              await prefs.setString('lastScreen', 'Dashboard');
              await prefs.setString('staffId', staffId.toString());
              await prefs.setString('rights', rights);
              await prefs.setString('userName', _emailController.text);
              await prefs.setString('password', _passwordController.text);
              await prefs.setString('profileUrl', profileUrl);
              await prefs.setInt('id', id);
              print('Staff ID saved in SharedPreferences: $staffId');
              print('User Rights saved in SharedPreferences: $rights');
              print(
                  'UserName saved in SharedPreferences: ${_emailController.text}');
              print(
                  'Password saved in SharedPreferences: ${_passwordController.text}');
              print('Profile URL saved in SharedPreferences: $profileUrl');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Dashboard(rights: rights),
                ),
              );
            } else {
              print('Error: Missing staffId or rights in response.');
              _showErrorDialog(
                  'Invalid response from server. Please try again.');
            }
          } else {
            print('Error: ${responseData['message'] ?? 'Unknown error'}');
            _showNoAccountDialog();
          }
        } else {
          print('Error: Received non-200 status code from server.');
          _showNoAccountDialog();
        }
      } catch (e) {
        print('Error: $e');
        _showErrorDialog('An error occurred. Please check your connection.');
      }
    }
  }

  Future<void> _customerLogin(String staffId) async {
    final customerUrl = 'https://chits.tutytech.in/staff.php';
    try {
      final customerResponse = await http.post(
        Uri.parse(customerUrl),
        body: {
          'type': 'customerLogin',
          'userName': _emailController.text,
          'password': _passwordController.text,
        },
      );

      final customerData = json.decode(customerResponse.body);
      print('Customer Login Response: $customerData');

      if (customerResponse.statusCode == 200 &&
          customerData['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('customerId', customerData['customerId']);
        await prefs.setString('customerName', customerData['customerName']);
        await prefs.setString(
            'customerProfileUrl', customerData['profileUrl'] ?? '');

        print('Customer login successful: ${customerData['customerId']}');
      } else {
        print('Customer login failed: ${customerData['error']}');
      }
    } catch (e) {
      print('Error during customer login: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showNoAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners for dialog
        ),
        titlePadding: EdgeInsets.zero, // Remove default title padding
        title: Container(
          alignment: Alignment.center, // Center-align text within container
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12), // Match dialog shape for smooth corners
            ),
          ),
          child: const Padding(
            padding:
                EdgeInsets.symmetric(vertical: 16), // Proper vertical spacing
            child: Text(
              'No Account Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text color for contrast
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 12), // Adjust content spacing
        content: const Text(
          ' Create Your Account ',
          style: TextStyle(fontSize: 16, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly, // Space buttons evenly
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12), // Add padding to buttons
              backgroundColor: Color(0xFF4A90E2), // Button background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegistrationScreen()),
              );
            },
            child: const Text(
              'Sign Up',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12), // Add padding to buttons
              backgroundColor: Colors.grey[300], // Button background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Image.asset(
                          'nobglogo.png',
                          height: 200,
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome to Chit Fund',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
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
                        // validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        // validator: _validatePassword,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 221, 226, 240),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SendOtpPage()),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don’t have an account? ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistrationScreen()),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Static Footer
            Container(
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
          ],
        ),
      ),
    );
  }
}
