import 'package:flutter/material.dart';

class CreateCenter extends StatefulWidget {
  const CreateCenter({Key? key}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<CreateCenter> {
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

  // Sample data for dropdowns
  final List<String> branches = ['Branch 1', 'Branch 2', 'Branch 3'];
  final List<String> dayOrders = ['Morning', 'Afternoon', 'Evening'];
  final List<String> timings = ['9:00 AM', '10:00 AM', '11:00 AM'];
  final List<String> fieldOfficers = ['Officer A', 'Officer B', 'Officer C'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(218, 209, 209, 204),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Handle menu action here
          },
        ),
        title: const Text("Create Center"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle logout action here
            },
          ),
        ],
      ),
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
                      controller: _fullBranchNameController,
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
                    DropdownButtonFormField<String>(
                      value: selectedDayOrder,
                      decoration: InputDecoration(
                        labelText: 'Day Order',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: dayOrders.map((dayOrder) {
                        return DropdownMenuItem<String>(
                          value: dayOrder,
                          child: Text(dayOrder),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDayOrder = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Select Timing dropdown
                    DropdownButtonFormField<String>(
                      value: selectedTiming,
                      decoration: InputDecoration(
                        labelText: 'Select Timing',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: timings.map((timing) {
                        return DropdownMenuItem<String>(
                          value: timing,
                          child: Text(timing),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedTiming = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Select Field Officer dropdown
                    DropdownButtonFormField<String>(
                      value: selectedFieldOfficer,
                      decoration: InputDecoration(
                        labelText: 'Select Field Officer',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: fieldOfficers.map((officer) {
                        return DropdownMenuItem<String>(
                          value: officer,
                          child: Text(officer),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFieldOfficer = value;
                        });
                      },
                    ),
                    const SizedBox(height: 30),

                    // Create Center button
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle create center action here
                        },
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
