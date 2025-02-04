import 'dart:convert';

import 'package:chitfunds/screens/customerreceipt.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AmountTransfer extends StatefulWidget {
  const AmountTransfer({Key? key}) : super(key: key);

  @override
  _AmountTransferState createState() => _AmountTransferState();
}

class _AmountTransferState extends State<AmountTransfer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _creditopeningbalController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _debitController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _transferdateController = TextEditingController();
  final TextEditingController _debitopeningbalController =
      TextEditingController();

  String? selectedStaff1;
  final List<String> areas = ['CASH', 'CHEQUE', 'NEFT', 'RTGS', 'UPI'];
  Future<void> _createVoucher() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId = prefs.getString('staffId');
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, exit early
    }

    final String apiUrl = 'https://chits.tutytech.in/voucher.php';

    try {
      // Construct request body
      final body = {
        'type': 'insert',
        'voucherdate': _transferdateController.text,
        'debitaccount': _debitController.text,
        'debitopeningbal': _debitopeningbalController.text,
        'creditaccount': _creditController.text,
        'creditopeningbal': _creditopeningbalController.text,
        'amount': _amountController.text,
        'transactiontype': selectedStaff1,
        'remarks': _remarksController.text,
        'entryid': staffId,
      };

      // Print request URL and body
      print('Request URL: $apiUrl');
      print('Request Body: $body');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      // Print response status and body
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData[0]['id'] != null) {
          _showSnackBar('Center created successfully!');
        } else {
          _showSnackBar('Error: ${responseData[0]['error']}');
        }
      } else {
        _showSnackBar(
            'Failed to create center. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
      print('Error: $e');
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
        title: 'Create Voucher',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(),
      body: Stack(children: [
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
                      controller: _transferdateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Voucher Date',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today,
                              color: Colors.grey),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _transferdateController.text =
                                    DateFormat('dd/MM/yyyy').format(pickedDate);
                              });
                            }
                          },
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Select a date' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _debitController,
                      decoration: InputDecoration(
                        labelText: 'Debit Account',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Enter a debit account'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _debitopeningbalController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Debit Opening Balance',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _creditController,
                      decoration: InputDecoration(
                        labelText: 'Credit Account',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Enter a credit account'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _creditopeningbalController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Credit Opening Balance',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Enter an amount';
                        }
                        if (double.tryParse(value!) == null ||
                            double.parse(value) <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    DropdownButtonFormField<String>(
                      value: selectedStaff1,
                      decoration: InputDecoration(
                        labelText: 'Transaction Type',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: areas.map((branch) {
                        return DropdownMenuItem<String>(
                          value: branch,
                          child: Text(branch),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStaff1 = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Select a transaction type' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _remarksController,
                      decoration: InputDecoration(
                        labelText: 'Remarks',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Enter remarks' : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _createVoucher(); // Perform save logic
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
                            onPressed: () {
                              // Cancel logic
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
      ]),
    );
  }
}
