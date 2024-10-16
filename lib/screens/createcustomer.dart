import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class CreateCustomer extends StatefulWidget {
  const CreateCustomer({Key? key}) : super(key: key);

  @override
  _CreateCustomerState createState() => _CreateCustomerState();
}

class _CreateCustomerState extends State<CreateCustomer> {
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

  String? selectedFileName = "No file chosen";

  String selectedAadhaarFileName = 'No file chosen';
  String selectedVoterIdFileName = 'No file chosen';
  String selectedPanFileName = 'No file chosen';
  String selectedNomineeAadharFileName = 'No file chosen';
  String selectNomineeVoterIdFileName = 'No file chosen';
  String selectedNomineePanFileName = 'No file chosen';
  String selectedRationCardFileName = 'No file chosen';
  String selectedpropertyTaxReceiptFileName = 'No file chosen';
  String selectedEBBillFileName = 'No file chosen';
  String selectedGasBillFileName = 'No file chosen';
  String selectedChequeLeafFileName = 'No file chosen';
  String selectedBondSheetFileName = 'No file chosen';
  String selectedImagesFileName = 'No file chosen';
  Uint8List? selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final Uint8List imageBytes = await pickedImage.readAsBytes();
        setState(() {
          selectedImage = imageBytes; // Update selectedImage with bytes
        });
      }
    } catch (e) {
      print("Image pick error: $e");
    }
  }

  void _pickFileForAadhaar() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedAadhaarFileName =
              result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectedAadhaarFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickFileForVoterId() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedVoterIdFileName =
              result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectedVoterIdFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickFileForPAN() async {
    // Simulate file picking for Voter ID
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedNomineePanFileName =
              result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectedNomineePanFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickFileForNomineeAdhaar() async {
    // Simulate file picking for Voter ID
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedNomineeAadharFileName =
              result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectedNomineeAadharFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickFileForNomineeVoterId() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectNomineeVoterIdFileName =
              result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectNomineeVoterIdFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickFileForNomineePan() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectNomineeVoterIdFileName =
              result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectNomineeVoterIdFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickFileForRationCard() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedRationCardFileName =
              result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectedRationCardFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickFileForPropertyTaxReceipt() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedpropertyTaxReceiptFileName =
              result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectedpropertyTaxReceiptFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickFileForEBBill() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedEBBillFileName = result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectedEBBillFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickFileForGasBill() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedGasBillFileName =
              result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectedGasBillFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickFileForChequeLeaf() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedChequeLeafFileName =
              result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectedChequeLeafFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickFileForBondSheet() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedBondSheetFileName =
              result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectedBondSheetFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  final List<String> branches = ['Branch 1', 'Branch 2', 'Branch 3'];
  final List<String> dayOrders = ['Morning', 'Afternoon', 'Evening'];
  final List<String> timings = ['9:00 AM', '10:00 AM', '11:00 AM'];
  final List<String> fieldOfficers = ['Officer A', 'Officer B', 'Officer C'];
  Widget buildUploadRow(
      String label, String selectedFileName, VoidCallback onPickFile) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: selectedFileName,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Positioned(
                left: 8,
                child: ElevatedButton(
                  onPressed: onPickFile,
                  child: const Text('Choose File'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
        title: const Text("Create Customer"),
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
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          // CircleAvatar with border
                          Container(
                            width: 140, // Adjust width according to your needs
                            height:
                                140, // Adjust height according to your needs
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey
                                    .withOpacity(0.5), // Mild grey border color
                                width: 2, // Border width
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: selectedImage != null
                                  ? MemoryImage(selectedImage!)
                                  : null,
                              child: selectedImage == null
                                  ? const Icon(Icons.person,
                                      size: 40, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.blue,
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    TextField(
                      controller: _branchNameController,
                      decoration: InputDecoration(
                        labelText: 'CustomerID',
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
                    TextField(
                      controller: _fullBranchNameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
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
                    TextField(
                      controller: _fullBranchNameController,
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
                    TextField(
                      controller: _fullBranchNameController,
                      decoration: InputDecoration(
                        labelText: 'Phone No',
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
                    TextField(
                      controller: _fullBranchNameController,
                      decoration: InputDecoration(
                        labelText: 'Mobile No',
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
                    TextField(
                      controller: _fullBranchNameController,
                      decoration: InputDecoration(
                        labelText: 'Aadhaar No',
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

                    // Branch Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedBranch,
                      decoration: InputDecoration(
                        labelText: 'Branch',
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

                    // Center Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedDayOrder,
                      decoration: InputDecoration(
                        labelText: 'Center',
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
                    // Upload Aadhaar Field
                    Row(
                      children: [
                        const Text(
                          'Upload Aadhaar',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // The disabled text field to hold the button and text
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left:
                                    120), // Adjust the padding to fit the button
                            hintText: selectedAadhaarFileName,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        // Positioned Choose File button inside the text field
                        Positioned(
                          left: 8,
                          child: ElevatedButton(
                            onPressed: _pickFileForAadhaar,
                            child: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Upload VoterId',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // The disabled text field to hold the button and text
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left:
                                    120), // Adjust the padding to fit the button
                            hintText: selectedVoterIdFileName,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        // Positioned Choose File button inside the text field
                        Positioned(
                          left: 8,
                          child: ElevatedButton(
                            onPressed: _pickFileForVoterId,
                            child: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Upload PAN',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // The disabled text field to hold the button and text
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left:
                                    120), // Adjust the padding to fit the button
                            hintText: selectedNomineePanFileName,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        // Positioned Choose File button inside the text field
                        Positioned(
                          left: 8,
                          child: ElevatedButton(
                            onPressed: _pickFileForPAN,
                            child: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Upload Nominee AadharCard',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // The disabled text field to hold the button and text
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left:
                                    120), // Adjust the padding to fit the button
                            hintText: selectedNomineeAadharFileName,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        // Positioned Choose File button inside the text field
                        Positioned(
                          left: 8,
                          child: ElevatedButton(
                            onPressed: _pickFileForNomineeAdhaar,
                            child: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Upload Nominee VoterID',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // The disabled text field to hold the button and text
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left:
                                    120), // Adjust the padding to fit the button
                            hintText: selectNomineeVoterIdFileName,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        // Positioned Choose File button inside the text field
                        Positioned(
                          left: 8,
                          child: ElevatedButton(
                            onPressed: _pickFileForNomineeVoterId,
                            child: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Upload NomineePAN',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // The disabled text field to hold the button and text
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left:
                                    120), // Adjust the padding to fit the button
                            hintText: selectedAadhaarFileName,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        // Positioned Choose File button inside the text field
                        Positioned(
                          left: 8,
                          child: ElevatedButton(
                            onPressed: _pickFileForNomineePan,
                            child: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Upload RationCard',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // The disabled text field to hold the button and text
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left:
                                    120), // Adjust the padding to fit the button
                            hintText: selectedRationCardFileName,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        // Positioned Choose File button inside the text field
                        Positioned(
                          left: 8,
                          child: ElevatedButton(
                            onPressed: _pickFileForRationCard,
                            child: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Upload PropertyTaxReceipt',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // The disabled text field to hold the button and text
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left:
                                    120), // Adjust the padding to fit the button
                            hintText: selectedpropertyTaxReceiptFileName,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        // Positioned Choose File button inside the text field
                        Positioned(
                          left: 8,
                          child: ElevatedButton(
                            onPressed: _pickFileForPropertyTaxReceipt,
                            child: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Upload EB Bill',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // The disabled text field to hold the button and text
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left:
                                    120), // Adjust the padding to fit the button
                            hintText: selectedEBBillFileName,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        // Positioned Choose File button inside the text field
                        Positioned(
                          left: 8,
                          child: ElevatedButton(
                            onPressed: _pickFileForEBBill,
                            child: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Upload Gas Bill',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // The disabled text field to hold the button and text
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left:
                                    120), // Adjust the padding to fit the button
                            hintText: selectedGasBillFileName,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        // Positioned Choose File button inside the text field
                        Positioned(
                          left: 8,
                          child: ElevatedButton(
                            onPressed: _pickFileForGasBill,
                            child: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Upload ChequeLeaf',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // The disabled text field to hold the button and text
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left:
                                    120), // Adjust the padding to fit the button
                            hintText: selectedChequeLeafFileName,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        // Positioned Choose File button inside the text field
                        Positioned(
                          left: 8,
                          child: ElevatedButton(
                            onPressed: _pickFileForChequeLeaf,
                            child: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Upload BondSheet',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // The disabled text field to hold the button and text
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left:
                                    120), // Adjust the padding to fit the button
                            hintText: selectedBondSheetFileName,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        // Positioned Choose File button inside the text field
                        Positioned(
                          left: 8,
                          child: ElevatedButton(
                            onPressed: _pickFileForBondSheet,
                            child: const Text('Choose File'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Document Upload Buttons

                    // Create Customer Button
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle create customer action here
                        },
                        child: const Text(
                          'Create Customer',
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
              height: 100,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadButton(String title) {
    return SizedBox(
      height: 20, // Adjust the height as needed
      child: ElevatedButton(
        onPressed: () {
          // Handle file upload action here
        },
        child: Text(title),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(10, 10), // Set the minimum size
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
        ),
      ),
    );
  }
}
