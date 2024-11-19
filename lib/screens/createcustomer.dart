import 'dart:convert';
import 'dart:io';

import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
  List<String> branchNames = [];
  List<String> centerNames = [];
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _aadharNoController = TextEditingController();
  final TextEditingController _uploadAadharPath = TextEditingController();
  final TextEditingController _uploadVoterIdPath = TextEditingController();
  final TextEditingController _uploadPanPath = TextEditingController();
  final TextEditingController _uploadNomineeAadharPath =
      TextEditingController();
  final TextEditingController _uploadNomineeVoterIdPath =
      TextEditingController();
  final TextEditingController _uploadNomineePanPath = TextEditingController();
  final TextEditingController _uploadRationCardPath = TextEditingController();
  final TextEditingController _uploadPropertyTaxReceiptPath =
      TextEditingController();
  final TextEditingController _uploadEbBillPath = TextEditingController();
  final TextEditingController _uploadGasBillPath = TextEditingController();
  final TextEditingController _uploadChequeLeafPath = TextEditingController();
  final TextEditingController _uploadBondSheetPath = TextEditingController();
  String? selectedCenter;
  final ImagePicker _picker = ImagePicker();
  List<String> centers = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // super.didChangeDependencies();
    _fetchBranches();
    _fetchCenters(); // Fetch branches when the widget dependencies change
  }

  Future<void> _fetchCenters() async {
    final String apiUrl = 'https://chits.tutytech.in/center.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'select', // Replace with the correct type for listing centers
        },
      );

      if (response.statusCode == 200) {
        // Log response for debugging
        print("Response Body: ${response.body}");

        final responseData = json.decode(response.body);

        // Log decoded response to check structure
        print("Decoded Response Data: $responseData");

        for (var center in responseData) {
          if (center['centername'] != null) {
            centers.add(center['centername']);
          }
        }

        if (centers.isEmpty) {
          _showSnackBar('Centers were not found in the response data.');
        } else {
          setState(() {
            centerNames = centers;
          });

          print('Center Names: $centers');
        }
      } else {
        _showSnackBar(
            'Failed to fetch centers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    }
  }

  Future<void> _createCustomer() async {
    final String apiUrl = 'https://chits.tutytech.in/customer.php';

    // Check if image is selected
    if (selectedImage == null) {
      print("No image selected.");
      return;
    }

    try {
      // Create the MultipartRequest
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(apiUrl),
      );

      // Dynamically add all fields from the controllers (use .text to get the values)
      request.fields['type'] = 'insert';
      request.fields['customerId'] = _customerIdController.text; // Corrected
      request.fields['name'] = _nameController.text;
      request.fields['address'] = _addressController.text;
      request.fields['phoneNo'] = _phoneNoController.text;
      request.fields['aadharNo'] = _aadharNoController.text;
      request.fields['branch'] = selectedBranch!;
      request.fields['center'] = selectedCenter!;
      request.fields['uploadAadhar'] = selectedAadhaarFileName; // Corrected
      request.fields['uploadVoterId'] = selectedVoterIdFileName; // Corrected
      request.fields['uploadPan'] = selectedPanFileName; // Corrected
      request.fields['uploadNomineeAadharCard'] =
          selectedNomineeAadharFileName; // Corrected
      request.fields['uploadnomineeVoterId'] =
          selectNomineeVoterIdFileName; // Corrected
      request.fields['uploadNomineePan'] =
          selectedNomineePanFileName; // Corrected
      request.fields['uploadRationCard'] =
          selectedRationCardFileName; // Corrected
      request.fields['uploadPropertyTaxReceipt'] =
          selectedpropertyTaxReceiptFileName; // Corrected
      request.fields['uploadEbBill'] = selectedEBBillFileName; // Corrected
      request.fields['uploadGasBill'] = selectedGasBillFileName; // Corrected
      request.fields['uploadChequeLeaf'] =
          selectedChequeLeafFileName; // Corrected
      request.fields['uploadBondSheet'] =
          selectedBondSheetFileName; // Corrected

      // Add image to the request (if picked)
      if (selectedImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'customerPhoto', // Field name for the image
            selectedImage!, // Image bytes
            filename: 'customer_image.jpg', // Image file name
            contentType:
                MediaType('image', 'jpeg'), // Set appropriate content type
          ),
        );
      }

      // Log request details for debugging
      print("Request URL: ${request.url}");
      print("Request Fields: ${request.fields}");
      print("Request Files: ${request.files}");

      // Send the request
      final response = await request.send();

      // Log the status code and response
      print("Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print("Raw Response: $responseBody");

        // Assuming the backend returns an ID or success message in the response
        if (responseBody.isNotEmpty) {
          print("Customer created successfully: $responseBody");
          _showSnackBar('Customer created successfully!');
        } else {
          print(
              "Customer created successfully, but no response body returned.");
          _showSnackBar('Failed to create customer.');
        }
      } else {
        print("Error creating customer: ${response.reasonPhrase}");
        _showSnackBar('Failed to create customer.');
      }
    } catch (e) {
      // Catch any exceptions during the request
      print("Exception: $e");
      _showSnackBar('An error occurred: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final Uint8List imageBytes = await pickedImage.readAsBytes();
        setState(() {
          selectedImage = imageBytes; // Update selectedImage with image bytes
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

  Future<void> _fetchBranches() async {
    final String apiUrl = 'https://chits.tutytech.in/branch.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'select', // Assuming 'list' type fetches all branches
        },
      );

      // Print the response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final responseData = json.decode(response.body);

          if (responseData is List) {
            // Check if the response is a list
            List<String> branches = [];

            for (var branch in responseData) {
              if (branch is Map && branch['branchname'] != null) {
                branches.add(branch['branchname']);
              }
            }

            setState(() {
              branchNames = branches;
            });

            // Print the branch names to the terminal
            print("Branch Names: $branches");
          } else {
            // Handle unexpected response structure
            print('Unexpected JSON structure: $responseData');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Unexpected JSON structure received.')),
            );
          }
        } catch (e) {
          // Handle JSON decoding errors
          print('JSON decode error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid JSON response: $e')),
          );
        }
      } else {
        // Handle cases where the response is not OK or empty
        print(
            'Failed to fetch branches or empty response. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Failed to fetch branches or received an empty response.')),
        );
      }
    } catch (e) {
      // Handle any other errors
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
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
          selectedPanFileName = result.files.first.name; // Get the file name
        });
      } else {
        // No file selected
        setState(() {
          selectedPanFileName = 'No file chosen';
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
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Create Customer',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer(); // Open drawer using the key
        },
      ),
      drawer: CustomDrawer(),
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
                      controller: _customerIdController,
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
                      controller: _nameController,
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
                      controller: _addressController,
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
                      controller: _phoneNoController,
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
                      controller: _aadharNoController,
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
                      value: branchNames.contains(selectedBranch)
                          ? selectedBranch
                          : null,
                      onChanged: (newValue) {
                        setState(() {
                          selectedBranch = newValue;
                        });
                      },
                      items: branchNames
                          .map((branchName) => DropdownMenuItem<String>(
                                value: branchName,
                                child: Text(branchName),
                              ))
                          .toList(),
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
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: centerNames.contains(selectedCenter)
                          ? selectedCenter
                          : null,
                      onChanged: (newValue) {
                        setState(() {
                          selectedCenter = newValue;
                        });
                      },
                      items: centerNames
                          .map((centerName) => DropdownMenuItem<String>(
                                value: centerName,
                                child: Text(centerName),
                              ))
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Select Center',
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
                            hintText: selectedPanFileName,
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
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _createCustomer,
                          child: const Text(
                            'Create Customer',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
