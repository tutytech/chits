import 'package:flutter/material.dart';

class CreateBranch extends StatefulWidget {
  const CreateBranch({Key? key}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<CreateBranch> {
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _fullBranchNameController = TextEditingController();
  final TextEditingController _registerCompanyNameController = TextEditingController();
  final TextEditingController _openingBalanceController = TextEditingController();
  final TextEditingController _openingDateController = TextEditingController();

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
        title: const Text("Create Branch"),
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
      body: Stack(children: [
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
                      labelText: 'Enter Branch Name',
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
                      labelText: 'Enter Full Branch Name',
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

                  // Register Company Name field
                  TextField(
                    controller: _registerCompanyNameController,
                    decoration: InputDecoration(
                      labelText: 'Enter Register Company Name',
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

                  // Opening Balance field
                  TextField(
                    controller: _openingBalanceController,
                    decoration: InputDecoration(
                      labelText: 'Opening Balance',
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

                  // Opening Date field
                  TextField(
                    controller: _openingDateController,
                    decoration: InputDecoration(
                      labelText: 'Opening Date',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Create Branch button
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle create branch action here
                      },
                      child: const Text(
                        'Create Branch',
                        style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
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
      ]),
    );
  }
}
