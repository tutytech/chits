import 'package:chitfunds/screens/createcenter.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:chitfunds/wigets/inputwidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CustomerDashboard extends StatefulWidget {
  final String? rights;
  const CustomerDashboard({Key? key, this.rights}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<CustomerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> branchNames = [];
  bool isActiveChecked = true; // Default to Active loans
  bool isCancelledChecked = false;
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
  List<dynamic> loanDetails = [];
  @override
  void initState() {
    super.initState();
    _fetchPaymentDetails();
    _fetchLoanDetails();
    _fetchLoanclosedaccounts();
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
              "₹$amount",
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

  Widget _buildLoanList() {
    if (loanDetails.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No loan details available.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: loanDetails.length,
      itemBuilder: (context, index) {
        final loan = loanDetails[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text('Loan No: ${loan['accountNo'] ?? 'N/A'}'),
            subtitle: Text('Loan Amount: ${loan['amount'] ?? '0.0'}'),
            trailing: Text('Loan Date: ${loan['date'] ?? 'N/A'}',
                style: TextStyle(fontSize: 15)),
          ),
        );
      },
    );
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
      print('Requesting data from: $_baseUrl');
      print('Request Body: type=list');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'list'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);

          print('Parsed JSON Response: $jsonResponse');

          double totalLoanAmount =
              double.tryParse(jsonResponse['totalAmount'].toString()) ?? 0.0;

          print('Total Loan Amount: $totalLoanAmount');

          setState(() {
            totalloan = totalLoanAmount;
          });
        } else {
          print('Error: Empty response body.');
        }
      } else {
        print("Failed to load data: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching loan data: $e");
    }
  }

  Future<void> _fetchLoanclosedaccounts() async {
    const String _baseUrl = 'https://chits.tutytech.in/loan.php';

    try {
      print('Requesting data from: $_baseUrl');
      print('Request Body: type=listclosedaccounts');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'listclosedaccounts'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          final List<dynamic> allLoans = jsonResponse['data'] ?? [];

          // Filter data based on checkbox selections
          List<dynamic> filteredLoans = allLoans.where((loan) {
            final String closedAccounts =
                loan['closedaccounts']?.toString() ?? '';
            if (isActiveChecked && !isCancelledChecked) {
              return closedAccounts == 'N'; // Active loans
            } else if (!isActiveChecked && isCancelledChecked) {
              return closedAccounts == 'Y'; // Cancelled loans
            }
            return false; // No loans if both or neither checkbox is selected
          }).toList();

          print('Filtered Loans Count: ${filteredLoans.length}');
          print('Filtered Loans: $filteredLoans');

          setState(() {
            loanDetails = filteredLoans; // Update the UI with filtered data
          });
        } else {
          print('Error: Empty response body.');
          setState(() {
            loanDetails = [];
          });
        }
      } else {
        print("Failed to load data: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching loan data: $e");
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
        branchNames: branchNames ?? [],
        rights: widget.rights ?? '',
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
                  const Text(
                    'Loan Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: isActiveChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isActiveChecked = value ?? false;
                            isCancelledChecked = false; // Uncheck "Cancelled"
                            _fetchLoanclosedaccounts(); // Fetch and filter data
                          });
                        },
                      ),
                      const Text('Active'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLoanList(),
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
