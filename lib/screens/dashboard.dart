import 'package:chitfunds/screens/createcenter.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:chitfunds/wigets/inputwidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  final String? rights;
  final int? customerCount, assignedCustomerCount;
  const Dashboard(
      {Key? key, this.rights, this.customerCount, this.assignedCustomerCount})
      : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> branchNames = [];
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _openingBalanceController =
      TextEditingController();
  final TextEditingController _openingDateController = TextEditingController();
  final entrydateController = TextEditingController();
  final dobController = TextEditingController();
  final dojController = TextEditingController();
  final domController = TextEditingController();
  double cashCollection = 0.0;
  double chequeCollection = 0.0;
  double cancelAmount = 0.0;
  double totalCollection = 0.0;
  double totalloan = 0.0;
  double cashloan = 0.0;
  double chequeloan = 0.0;
  double cancelloan = 0.0;
  double customerCount = 0.0;
  @override
  void initState() {
    super.initState();
    _fetchPaymentDetails();
    _fetchLoanDetails();
  }

  Widget _buildCard(String title, String amount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "$amount",
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Widget> cards) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: cards,
    );
  }

  Widget _buildGrid1(List<Widget> cards) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: cards,
    );
  }

  Widget _buildGrid2(List<Widget> cards) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: cards,
    );
  }

  Future<double> fetchCustomerCount() async {
    const String _baseUrl = 'https://chits.tutytech.in/staff.php';
    const Map<String, String> _headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    final Map<String, String> _body = {
      'type': 'login',
      'username': 'your_username', // Replace with actual username
      'password': 'your_password' // Replace with actual password
    };

    try {
      print('Sending login request to $_baseUrl');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: _body,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final customerCount = (responseData['customerCount'] ?? 0).toDouble();
          print('Customer Count: $customerCount');
          return customerCount;
        } else {
          throw Exception(responseData['error'] ?? 'Login failed');
        }
      } else {
        throw Exception(
            'Failed to fetch customer count. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> _fetchPaymentDetails() async {
    const String _baseUrl =
        'https://chits.tutytech.in/receipt.php'; // Replace with your API

    try {
      print('Request URL: $_baseUrl');
      print('Request Body: type=select');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'select'},
      );

      // Debug: Print the response
      print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Try parsing JSON
        final List<dynamic> data = json.decode(response.body);

        double cashTotal = 0.0;
        double chequeTotal = 0.0;
        double cancelTotal = 0.0;

        for (var item in data) {
          double amount =
              double.tryParse(item['receivedamount'].toString()) ?? 0.0;
          String type = item['paymenttype'].toString().toLowerCase();

          if (type == 'cash') {
            cashTotal += amount;
          } else if (type == 'cheque') {
            chequeTotal += amount;
          } else if (type == 'cancel') {
            cancelTotal += amount;
          }
        }

        setState(() {
          cashCollection = cashTotal;
          chequeCollection = chequeTotal;
          cancelAmount = cancelTotal;
          totalCollection = cashTotal + chequeTotal;
        });
      } else {
        print("Failed to load data: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> _fetchLoanDetails() async {
    const String _baseUrl = 'https://chits.tutytech.in/loan.php';

    try {
      print('Request URL: $_baseUrl');
      print('Request Body: type=list');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'list'}, // Fetch loan details
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> jsonResponse =
                json.decode(response.body);

            // Get the total amount from the response
            double totalLoanAmount =
                double.tryParse(jsonResponse['totalAmount'].toString()) ?? 0.0;

            setState(() {
              totalloan = totalLoanAmount; // Update UI with total amount
            });
          } catch (e) {
            print('Error parsing JSON: $e');
          }
        } else {
          print('Error: Response body is empty.');
        }
      } else {
        print("Failed to load data: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Dashboard',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(
        branchNames: branchNames ?? [], // Default to an empty list if null
        rights: widget.rights ?? '', // Default to an empty string if null
      ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Payment Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildGrid(
                    [
                      _buildCard('Total Collection',
                          totalCollection.toStringAsFixed(2)),
                      _buildCard(
                          'Cash Collection', cashCollection.toStringAsFixed(2)),
                      _buildCard('Bank Collection',
                          chequeCollection.toStringAsFixed(2)),
                      _buildCard(
                          'Cancel Amount', cancelAmount.toStringAsFixed(2)),
                    ],
                  ),
                  SizedBox(height: 20), // Space between sections
                  Text(
                    'Loan Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildGrid1(
                    [
                      _buildCard('Total Loan', totalloan.toStringAsFixed(2)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Customer Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildGrid2(
                    [
                      _buildCard('Total Customer',
                          widget.customerCount?.toString() ?? '0'),
                    ],
                  )
                  // Space between sections
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
