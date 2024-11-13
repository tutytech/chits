import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';

class SmsSettings extends StatefulWidget {
  const SmsSettings({Key? key}) : super(key: key);

  @override
  _SmsSettingsState createState() => _SmsSettingsState();
}

class _SmsSettingsState extends State<SmsSettings> {
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _fullBranchNameController =
      TextEditingController();
  final TextEditingController _registerCompanyNameController =
      TextEditingController();
  final TextEditingController _openingBalanceController =
      TextEditingController();
  final TextEditingController _openingDateController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Set the key here
      appBar: CustomAppBar(
        title: 'SMS Settings',
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
                      controller: _branchNameController,
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
                    ),
                    const SizedBox(height: 20),

                    // Full Branch Name field
                    TextField(
                      controller: _fullBranchNameController,
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
                    ),
                    const SizedBox(height: 20),

                    // Select Branch dropdown
                    TextField(
                      controller: _fullBranchNameController,
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
                    ),
                    const SizedBox(height: 20),

                    // Day Order dropdown

                    // Create Center button
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle create center action here
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
