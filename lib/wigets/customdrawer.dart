import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chitfunds/screens/LoginScreen.dart';
import 'package:chitfunds/screens/Reports/branchwisereport.dart';
import 'package:chitfunds/screens/Reports/centerwisereport.dart';
import 'package:chitfunds/screens/Reports/collectionreport.dart';
import 'package:chitfunds/screens/Reports/outstandingreport.dart';
import 'package:chitfunds/screens/Reports/deletereport.dart';
import 'package:chitfunds/screens/amountransfer.dart';
import 'package:chitfunds/screens/branchlist.dart';
import 'package:chitfunds/screens/centerlist..dart';
import 'package:chitfunds/screens/closeaccountlist.dart';
import 'package:chitfunds/screens/createbranch.dart';
import 'package:chitfunds/screens/createcenter.dart';
import 'package:chitfunds/screens/createcustomer.dart';
import 'package:chitfunds/screens/createscheme.dart';
import 'package:chitfunds/screens/createstaff.dart';
import 'package:chitfunds/screens/customerlist.dart';
import 'package:chitfunds/screens/customerreceipt.dart';
import 'package:chitfunds/screens/editcomapnydetails.dart';
import 'package:chitfunds/screens/editcompany.dart';
import 'package:chitfunds/screens/editsms.dart';
import 'package:chitfunds/screens/loan.dart';
import 'package:chitfunds/screens/loanlist.dart';
import 'package:chitfunds/screens/receiptlist.dart';
import 'package:chitfunds/screens/schemelist.dart';
import 'package:chitfunds/screens/stafflist.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  final String? rights, id;
  final List<String>? branchNames;
  final bool? isAdmin;
  final Function(bool)? onRightsChanged;
  const CustomDrawer(
      {this.branchNames,
      this.rights,
      this.isAdmin,
      this.onRightsChanged,
      this.id});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final List<Map<String, dynamic>> _branches = [];
  String? companyId;
  String? id;

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }

  Future<void> _logout(BuildContext context) async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('staffId');

      // Check if 'staffId' is removed
      bool isRemoved = !prefs.containsKey('staffId');
      if (isRemoved) {
        print('staffId successfully removed from SharedPreferences');
      } else {
        print('Failed to remove staffId from SharedPreferences');
      }

      // Navigate to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _loadCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      companyId = prefs.getString('companyId');
      print('------------------------------$companyId');
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = (widget.rights ?? '').trim().toLowerCase() == "admin";
    print('Navigated with rights: ${widget.rights}');

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 130,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Image.asset(
                  'nobglogo.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Show these items only if the user is admin
          if (isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Customer'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CustomerList(rights: widget.rights)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Branch'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BranchListPage(rights: widget.rights)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Center'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CenterListPage(rights: widget.rights)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Scheme'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SchemeListPage(rights: widget.rights)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Chits/Loan'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoanListPage(rights: widget.rights)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Receipt'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          receiptListPage(rights: widget.rights)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.transfer_within_a_station),
              title: const Text('Voucher'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AmountTransfer(rights: widget.rights)),
                );
              },
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16.0),
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              childrenPadding: EdgeInsets.only(left: 32.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.arrow_right),
                  title: const Text('Collection Report'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CollectionReport(rights: widget.rights),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_right),
                  title: const Text('Centerwise Report'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Centerwisereport(rights: widget.rights),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_right),
                  title: const Text('Branchwise Report'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Branchwisereport(rights: widget.rights),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_right),
                  title: const Text('Outstanding Report'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Outstandingreport(rights: widget.rights),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_right),
                  title: const Text('Delete Report'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DeleteReport(rights: widget.rights),
                      ),
                    );
                  },
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Staff Create'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          staffListPage(rights: widget.rights)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_box),
              title: const Text('Closed Accounts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          closeAccountList(rights: widget.rights)),
                );
              },
            ),
            const Divider(),
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16.0),
              leading: const Icon(
                Icons.settings,
              ),
              title: const Text(
                'Settings',
              ),
              childrenPadding: EdgeInsets.only(left: 32.0),
              collapsedShape: const RoundedRectangleBorder(
                side: BorderSide(
                    color:
                        Colors.transparent), // Remove the border when collapsed
              ),
              shape: const RoundedRectangleBorder(
                side: BorderSide(
                    color:
                        Colors.transparent), // Remove the border when expanded
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.business,
                        ),
                        title: const Text('Edit Company Profile'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCompany(
                                  id: companyId!, rights: widget.rights),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.sms,
                        ),
                        title: const Text('SMS Settings'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditSmsSettings(rights: widget.rights),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Log Out',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          _logout(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Show only for non-admin users
          if (!isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Receipt'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          receiptListPage(rights: widget.rights)),
                );
              },
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              childrenPadding: const EdgeInsets.only(left: 32.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.arrow_right),
                  title: const Text('Collection Report'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CollectionReport(rights: widget.rights)),
                    );
                  },
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor:
                      Colors.transparent, // Removes default background space
                  isScrollControlled: true,
                  builder: (context) => Align(
                    alignment:
                        Alignment.centerLeft, // Aligns closer to the side menu
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0), // Reduce left space
                      child: SizedBox(
                        width: 250, // Adjust width as needed
                        child: Material(
                          // Required to retain default styling
                          borderRadius: BorderRadius.circular(10),
                          child: SettingsPopup(rights: widget.rights),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          // Staff and other settings can be added here if needed
        ],
      ),
    );
  }
}

class SettingsPopup extends StatefulWidget {
  final String? rights, entryid, id;

  const SettingsPopup({Key? key, this.rights, this.entryid, this.id})
      : super(key: key);

  @override
  State<SettingsPopup> createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  String? staffName;
  String? password;
  String? profile;
  String profileUrl = '';
  File? _selectedImage;
  String? uploadedImageUrl;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStaffDetails();
  }

  Future<void> _loadStaffDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      staffName = prefs.getString('userName') ?? 'Unknown';
      password = prefs.getString('password') ?? 'Unknown';
      profile = prefs.getString('profileUrl') ?? '';
      _nameController.text = staffName!;
      _passwordController.text = password!;
    });

    print('Loaded Staff Name: $staffName');
    print('Loaded Password: $password');
    print('Loaded Profile URL: $profile');
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      await _uploadProfileImage(); // Upload after selecting
    }
  }

  void _editName() async {
    final newName = await _showEditDialog('Name', _nameController);
    if (newName != null && newName != staffName) {
      setState(() {
        staffName = newName;
        _nameController.text = newName;
      });

      final bool success = await _updateStaffDetails(
        updatedName: newName,
        updatedPassword: password,
      );

      if (success) {
        _updateStaff(); // Navigate or whatever logic you need
      } else {
        _showErrorSnackbar('Failed to update Name. Try again!');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _editPassword() async {
    final newPassword = await _showEditDialog('Password', _passwordController);
    if (newPassword != null && newPassword != password) {
      setState(() {
        password = newPassword;
        _passwordController.text = newPassword;
      });

      final bool success = await _updateStaffDetails(
        updatedName: staffName,
        updatedPassword: newPassword,
      );

      if (success) {
        _updateStaff(); // Navigate or whatever logic you need
      } else {
        _showErrorSnackbar('Failed to update Password. Try again!');
      }
    }
  }

  Future<bool> _updateStaffDetails({
    required String? updatedName,
    required String? updatedPassword,
  }) async {
    try {
      // Simulating API call (Replace with your API logic)
      await Future.delayed(const Duration(seconds: 1));

      // Simulate success (true) or failure (false)
      // Replace this with actual API response logic
      bool apiSuccess = true; // Example, change as per API response

      return apiSuccess;
    } catch (e) {
      print("Error updating staff details: $e");
      return false;
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_selectedImage == null)
      return profile; // Use existing profile URL if no new image

    final url = Uri.parse('https://chits.tutytech.in/upload_image.php');

    try {
      var request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _updateStaff();

        if (result['status'] == 'success') {
          return result['image_url']; // Uploaded image URL
        } else {
          _showError(result['message'] ?? 'Image upload failed.');
          return null;
        }
      } else {
        _showError('Failed to upload image: ${response.body}');
        return null;
      }
    } catch (error) {
      _showError('Image upload error: $error');
      return null;
    }
  }

  Future<void> _updateStaff() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? id = prefs.getInt('id');
    final String? finalProfileUrl =
        uploadedImageUrl ?? prefs.getString('profileUrl');

    print('staff1');
    print('---------------${widget.id}');
    try {
      final url = Uri.parse('https://chits.tutytech.in/staff.php');

      final requestBody = {
        'type':
            'updateprofile', // ✅ Try changing 'type' to 'action' if API expects this
        'id': id.toString(),

        'userName': _nameController.text.trim(),
        'password': _passwordController.text.trim(),
        'profile': finalProfileUrl,
      };

      print('staff3');
      debugPrint('Request URL: $url');
      debugPrint('Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      debugPrint('Response Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('staff4');
        final result =
            json.decode(response.body); // result is a Map, not a List

        if (result['status'] == 0) {
          print('staff5');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff updated successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          print('staff5');
          _showError(result['message'] ?? 'Failed to update staff.');
        }
      } else {
        print('staff6');
        _showError('Failed to update staff: ${response.body}');
      }
    } catch (error) {
      print('staff7');
      debugPrint('Error: $error');
      _showError('An error occurred: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<String?> _showEditDialog(
      String field, TextEditingController controller) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController localController =
            TextEditingController(text: controller.text);
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: localController,
            decoration: InputDecoration(labelText: field),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, localController.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('staffId');

      // Check if 'staffId' is removed
      bool isRemoved = !prefs.containsKey('staffId');
      if (isRemoved) {
        print('staffId successfully removed from SharedPreferences');
      } else {
        print('Failed to remove staffId from SharedPreferences');
      }

      // Navigate to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Aligns content centrally
            children: [
              Text("Edit Profile",
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
              SizedBox(height: 50),

              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      child: ClipOval(
                        child: profile != null && profile!.isNotEmpty
                            ? Image.network(
                                profile!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person,
                                      size: 60, color: Colors.grey);
                                },
                              )
                            : const Icon(Icons.person,
                                size: 60, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          _pickProfileImage();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ✅ Name Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      staffName ?? 'Unknown',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      _editName();
                    },
                  ),
                ],
              ),

              const Divider(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      password ?? 'Unknown',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      _editPassword();
                    },
                  ),
                ],
              ),

              const Divider(),
              SizedBox(height: 30),
              // ✅ Logout Button
              ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label:
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.red),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ]),
    );
  }
}
