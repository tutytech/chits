import 'dart:convert';

import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateCenter extends StatefulWidget {
  const CreateCenter({Key? key}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<CreateCenter> {
  final TextEditingController _centerNameController = TextEditingController();

  final TextEditingController _centeridController = TextEditingController();

  String? selectedBranch;
  String? selectedDayOrder;
  String? selectedTiming;
  String? selectedFieldOfficer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Sample data for dropdowns
  final List<String> branches = ['Branch 1', 'Branch 2', 'Branch 3'];
  final List<String> dayOrders = ['Morning', 'Afternoon', 'Evening'];
  final List<String> timings = ['9:00 AM', '10:00 AM', '11:00 AM'];
  final List<String> fieldOfficers = ['Officer A', 'Officer B', 'Officer C'];
  Future<void> _createCenter() async {
    final String apiUrl = 'https://chits.tutytech.in/center.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'insert',
          'centername': _centerNameController.text,

          'centercode': _centeridController.text,
          'branchid': '1',
          'entryid': '123', // Replace with a real entry ID if needed
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData[0]['id'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Center created successfully!')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Set the key here
      appBar: CustomAppBar(
        title: 'Create Center',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer(); // Open drawer using the key
        },
      ),
      drawer: CustomDrawer(),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Branch Name field
                    TextField(
                      controller: _centeridController,
                      decoration: InputDecoration(
                        labelText: 'Enter Center ID',
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

                    // Full Branch Name field
                    TextField(
                      controller: _centerNameController,
                      decoration: InputDecoration(
                        labelText: 'Enter Center Name',
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

                    // Select Branch dropdown
                    DropdownButtonFormField<String>(
                      value: selectedBranch,
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
                      items: branches.map((branch) {
                        return DropdownMenuItem<String>(
                          value: branch,
                          child: Text(branch),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBranch = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Day Order dropdown

                    // Create Center button
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createCenter,
                        child: const Text(
                          'Create Center',
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
