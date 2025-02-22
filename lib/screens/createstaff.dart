import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:chitfunds/screens/createcustomer.dart';
import 'package:chitfunds/screens/stafflist.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class CreateStaff extends StatefulWidget {
  final String? rights;
  const CreateStaff({Key? key, this.rights}) : super(key: key);

  @override
  _CreateStaffState createState() => _CreateStaffState();
}

class _CreateStaffState extends State<CreateStaff> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _staffNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _branchCodeController = TextEditingController();
  final TextEditingController _receiptNoController = TextEditingController();
  final TextEditingController _companyIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedBranch;
  String? selectedRights;
  List<Map<String, String>> branchData = [];
  String? selectedBranchName;
  String? selectedBranchId;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  String? _imageFileName;
  File? _image;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchBranches(); // Fetch branches when the widget dependencies change
  }

  final List<String> branches = [
    'Head Office',
    'Kalayarkovil',
    'Manalmelkudi',
    'Paramakudi',
    'Ramanathapuram'
  ];
  final List<String> rights = [
    'Admin',
    'HR',
    'MD',
    'Manager',
    'Auditor',
    'Accounts',
    'System Entry',
    'Field Officer'
  ];
  Future<void> _pickImage() async {
    print('pick1');
    try {
      print('pick2');
      // Pick the image from the gallery
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        print('pick3');
        final bytes = await pickedFile.readAsBytes(); // Convert image to bytes
        setState(() {
          print('pick4');
          _imageBytes = bytes; // Store the image bytes
          _imageFileName = pickedFile.name;
          _image = File(pickedFile.path);
          print('$_imageFileName');
          print('$_image');
        });
      } else {
        print('pick5');
        print("No image selected.");
      }
    } catch (e) {
      print('pick6');
      print("Error picking image: $e");
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
          'type': 'select',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<Map<String, String>> branches = [];
        for (var branch in responseData) {
          if (branch['id'] != null && branch['branchname'] != null) {
            branches.add({
              'id': branch['id'].toString(),
              'name': branch['branchname'],
            });
          }
        }

        setState(() {
          branchData = branches;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch branches.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _createStaff() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId = prefs.getString('staffId');
    final String? companyid = prefs.getString('companyId');

    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Exit if validation fails
    }

    final String staffApiUrl = 'https://chits.tutytech.in/staff.php';
    final String userApiUrl = 'https://chits.tutytech.in/user.php';

    try {
      // Create multipart request for staff
      var staffRequest = http.MultipartRequest('POST', Uri.parse(staffApiUrl));
      staffRequest.fields.addAll({
        'type': 'insert',
        'staffId': _staffIdController.text,
        'staffName': _staffNameController.text,
        'address': _addressController.text,
        'mobileNo': _mobileNoController.text,
        'userName': _userNameController.text,
        'password': _passwordController.text,
        'branch': selectedBranchName ?? '',
        'branchCode': _branchCodeController.text,
        'receiptNo': _receiptNoController.text,
        'rights': selectedRights ?? '',
        'companyid': companyid ?? '',
        'email': _emailController.text,
        'entryid': staffId ?? '',
      });

      if (_imageBytes != null && _imageFileName != null) {
        staffRequest.files.add(
          http.MultipartFile.fromBytes(
            'profile',
            _imageBytes!,
            filename: _imageFileName ?? 'profile_image.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // Send staff request
      final staffResponse = await staffRequest.send();
      final staffResponseBody = await staffResponse.stream.bytesToString();
      print('Staff response body: $staffResponseBody');

      if (staffResponse.statusCode == 200) {
        final Map<String, dynamic> staffData = json.decode(staffResponseBody);

        if (staffData['id'] != null) {
          // Call user.php to store usernames and passwords
          final userResponse = await http.post(
            Uri.parse(userApiUrl),
            body: {
              'type': 'insert',
              'username': _userNameController.text,
              'password': _passwordController.text,
              'rights': selectedRights ?? '',
            },
          );

          final userData = json.decode(userResponse.body);
          print('User response: $userData');

          if (userResponse.statusCode == 200 && userData['success'] == true) {
            _showSnackBar('Staff and users created successfully!');
          } else {
            _showSnackBar('Failed to create users: ${userData['errors']}');
          }
        } else {
          _showSnackBar('Error: ${staffData['message']}');
        }
      } else {
        _showSnackBar(
            'Failed to create staff. Status code: ${staffResponse.statusCode}');
      }

      // Navigate to staff list page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => staffListPage()),
      );
    } catch (e) {
      print('Error: $e');
      _showSnackBar('An error occurred: $e');
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
        title: 'Create Staff',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(rights: widget.rights),
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
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment
                              .center, // Center alignment for both children
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _imageBytes != null
                                    ? MemoryImage(_imageBytes!)
                                    : null,
                                child: _imageBytes == null
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
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _staffIdController,
                        decoration: InputDecoration(
                          labelText: 'Enter Staff ID',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your staff id';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _staffNameController,
                        decoration: InputDecoration(
                          labelText: 'Enter Staff Name',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your staff name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _companyIdController,
                        decoration: InputDecoration(
                          labelText: 'CompanyID',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your companyid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Enter Address',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _mobileNoController,
                        decoration: InputDecoration(
                          labelText: 'Enter Mobile No',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your mobileno';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _userNameController,
                        decoration: InputDecoration(
                          labelText: 'Enter User Name',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Enter Password',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      DropdownButtonFormField<String>(
                        value: selectedBranchId,
                        onChanged: (newValue) {
                          setState(() {
                            selectedBranchId = newValue;
                            selectedBranchName = branchData.firstWhere(
                                    (branch) => branch['id'] == newValue)[
                                'name']; // Fetch branch name
                          });
                        },
                        items: branchData
                            .map((branch) => DropdownMenuItem<String>(
                                  value: branch['id'], // Use branch ID as value
                                  child: Text(
                                      branch['name']!), // Display branch name
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a branch';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _branchCodeController,
                        decoration: InputDecoration(
                          labelText: 'Enter Branch Code',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your branch code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _receiptNoController,
                        decoration: InputDecoration(
                          labelText: 'Enter Receipt No',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your receiptno';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      DropdownButtonFormField<String>(
                        value: selectedRights,
                        decoration: InputDecoration(
                          labelText: 'Enter Rights',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your rights';
                          }
                          return null;
                        },
                        items: rights.map((rights) {
                          return DropdownMenuItem<String>(
                            value: rights,
                            child: Text(rights),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRights = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 150, // Adjust the width as needed
                              child: ElevatedButton(
                                onPressed: () {
                                  _createStaff();
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
                              width: 150, // Adjust the width as needed
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => LoanListPage(),
                                  //   ),
                                  // );
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
