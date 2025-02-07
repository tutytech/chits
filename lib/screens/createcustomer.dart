import 'dart:convert';
import 'dart:io';
import 'package:chitfunds/controlller/home_controller.dart';
import 'package:chitfunds/screens/branchlist.dart';
import 'package:chitfunds/screens/customerlist.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateCustomer extends StatefulWidget {
  final String? rights;
  const CreateCustomer({Key? key, this.rights}) : super(key: key);

  @override
  _CreateCustomerState createState() => _CreateCustomerState();
}

class _CreateCustomerState extends State<CreateCustomer> {
  final HomeController controller = Get.put(HomeController());
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _fullBranchNameController =
      TextEditingController();
  final TextEditingController _registerCompanyNameController =
      TextEditingController();
  final TextEditingController _openingBalanceController =
      TextEditingController();
  final TextEditingController _openingDateController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

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
  Uint8List? _imageBytes;
  String? selectedBranchName;
  String? selectedBranchId;
  String? selectedCenterId;
  String? selectedCenterName;
// Variables to hold file bytes for each selected document
  Uint8List? selectedAadhaarFileBytes;

  Uint8List? selectedVoterIdFileBytes;

  Uint8List? selectedPanFileBytes;

  Uint8List? selectedNomineeAadharFileBytes;

  Uint8List? selectNomineeVoterIdFileBytes;

  Uint8List? selectedNomineePanFileBytes;

  Uint8List? selectedRationCardFileBytes;

  Uint8List? selectedpropertyTaxReceiptFileBytes;

  Uint8List? selectedEBBillFileBytes;

  Uint8List? selectedGasBillFileBytes;

  Uint8List? selectedChequeLeafFileBytes;

  Uint8List? selectedBondSheetFileBytes;

  String? _imageFileName;
  Uint8List? selectedImage;
  List<String> branchNames = [];
  List<String> centerNames = [];
  List<Map<String, String>> centerData = [];
  bool _isLoading = false;

  List<Map<String, String>> branchData = [];
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
  File? _image;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // super.didChangeDependencies();
    _fetchBranches();
    _fetchCenters(); // Fetch branches when the widget dependencies change
  }

  // Function to pick an image or document for Aadhaar
  String selectedAadhaarFileName1 =
      'default_name.jpg'; // Default value for the name

  Future<void> _fetchAndSaveLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permissions are denied");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are permanently denied");
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
      });

      // Send location to the server
      // await _saveLocationToServer(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          'type': 'select', // Type for listing centers
        },
      );

      if (response.statusCode == 200) {
        // Log response for debugging
        print("Response Body: ${response.body}");

        final responseData = json.decode(response.body);

        // Parse centers from response
        List<Map<String, String>> centers = [];
        for (var center in responseData) {
          if (center['id'] != null && center['centername'] != null) {
            centers.add({
              'id': center['id'].toString(),
              'name': center['centername'],
            });
          }
        }

        if (centers.isEmpty) {
          _showSnackBar('No centers were found in the response data.');
        } else {
          setState(() {
            centerData = centers; // Update the state with center data
          });

          print('Center Data: $centers');
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
    print('hello1');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? staffId = await prefs.getString('staffId');
    print('-------------$staffId');

    final String apiUrl = 'https://chits.tutytech.in/customer.php';

    if (_image == null) {
      print('hello3');
      print("No image selected.");
      _showSnackBar('Please select an image.');
      return;
    }
    try {
      print('hello4');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(apiUrl),
      );

      request.fields['type'] = 'insert';
      request.fields['customerId'] = _customerIdController.text.trim();
      request.fields['name'] = _nameController.text.trim();
      request.fields['address'] = _addressController.text.trim();
      request.fields['phoneNo'] = _phoneNoController.text.trim();
      request.fields['aadharNo'] =
          _aadharNoController.text.trim(); // Ensure this is passed as a string
      request.fields['branch'] = selectedBranchName ?? '';
      request.fields['center'] = selectedCenterName ?? '';

      // Add file names for uploaded documents if available
      request.fields['uploadAadhar'] = selectedAadhaarFileName ?? '';
      request.fields['uploadVoterId'] = selectedVoterIdFileName ?? '';
      request.fields['uploadPan'] = selectedPanFileName ?? '';
      request.fields['uploadNomineeAadharCard'] =
          selectedNomineeAadharFileName ?? '';
      request.fields['uploadNomineeVoterId'] =
          selectNomineeVoterIdFileName ?? '';
      request.fields['uploadNomineePan'] = selectedNomineePanFileName ?? '';
      request.fields['uploadRationCard'] = selectedRationCardFileName ?? '';
      request.fields['uploadPropertyTaxReceipt'] =
          selectedpropertyTaxReceiptFileName ?? '';
      request.fields['uploadEbBill'] = selectedEBBillFileName ?? '';
      request.fields['uploadGasBill'] = selectedGasBillFileName ?? '';
      request.fields['uploadChequeLeaf'] = selectedChequeLeafFileName ?? '';
      request.fields['uploadBondSheet'] = selectedBondSheetFileName ?? '';
      request.fields['latitude'] = controller.latitude.value;
      request.fields['longitude'] = controller.longitude.value;
      request.fields['entryid'] = staffId.toString(); // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'customerPhoto',
          _imageBytes!,
          filename: _imageFileName ?? 'customer_photo.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      print('Aadhaar File Bytes: ${selectedAadhaarFileBytes}');
      print('Aadhaar File Name: $selectedAadhaarFileName');

      if (selectedAadhaarFileBytes != null &&
          selectedAadhaarFileBytes!.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'uploadAadhar',
            selectedAadhaarFileBytes!,
            filename: selectedAadhaarFileName,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else {
        print('No Aadhaar file bytes available.');
        _showSnackBar('Aadhaar file is missing or empty.');
      }

      // Add files for other documents
      if (selectedVoterIdFileName != null && selectedVoterIdFileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'uploadVoterId',
            selectedVoterIdFileBytes!,
            filename: selectedVoterIdFileName!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      if (selectedPanFileName != null && selectedPanFileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'uploadPan',
            selectedPanFileBytes!,
            filename: selectedPanFileName!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      if (selectedNomineeAadharFileName != null &&
          selectedNomineeAadharFileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'uploadNomineeAadharCard',
            selectedNomineeAadharFileBytes!,
            filename: selectedNomineeAadharFileName!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      if (selectNomineeVoterIdFileName != null &&
          selectNomineeVoterIdFileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'uploadNomineeVoterId',
            selectNomineeVoterIdFileBytes!,
            filename: selectNomineeVoterIdFileName!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      if (selectedNomineePanFileName != null &&
          selectedNomineePanFileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'uploadNomineePan',
            selectedNomineePanFileBytes!,
            filename: selectedNomineePanFileName!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      if (selectedRationCardFileName != null &&
          selectedRationCardFileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'uploadRationCard',
            selectedRationCardFileBytes!,
            filename: selectedRationCardFileName!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      if (selectedpropertyTaxReceiptFileName != null &&
          selectedpropertyTaxReceiptFileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'uploadPropertyTaxReceipt',
            selectedpropertyTaxReceiptFileBytes!,
            filename: selectedpropertyTaxReceiptFileName!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      if (selectedEBBillFileName != null && selectedEBBillFileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'uploadEbBill',
            selectedEBBillFileBytes!,
            filename: selectedEBBillFileName!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      if (selectedGasBillFileName != null && selectedGasBillFileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'uploadGasBill',
            selectedGasBillFileBytes!,
            filename: selectedGasBillFileName!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      if (selectedChequeLeafFileName != null &&
          selectedChequeLeafFileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'uploadChequeLeaf',
            selectedChequeLeafFileBytes!,
            filename: selectedChequeLeafFileName!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      if (selectedBondSheetFileName != null &&
          selectedBondSheetFileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'uploadBondSheet',
            selectedBondSheetFileBytes!,
            filename: selectedBondSheetFileName!,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      // Log request details for debugging
      print("Request URL: ${request.url}");
      print("Request Fields: ${request.fields}");
      print("Request Files: ${request.files}");

      // Send the request
      final response = await request.send();

      // Handle response
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print("Raw Response: $responseBody");

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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerList(),
        ),
      );
    } catch (e) {
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

  void _pickFileForAadhaar() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Get the file name
        setState(() {
          selectedAadhaarFileName = file.name;
        });

        // Fetch file bytes
        final fileBytes = file.bytes;
        if (fileBytes != null && fileBytes.isNotEmpty) {
          setState(() {
            selectedAadhaarFileBytes = fileBytes;
          });
          print('Aadhaar File Bytes: ${selectedAadhaarFileBytes?.length}');
        } else {
          print('Failed to fetch file bytes or file is empty');
          _showSnackBar('Failed to fetch Aadhaar file bytes');
        }
      } else {
        // No file selected
        setState(() {
          selectedAadhaarFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      _showSnackBar('Error picking file: $e');
    }
  }

  Future<void> _pickFileForVoterId() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Get the file name
        setState(() {
          selectedVoterIdFileName = file.name;
        });

        // Fetch file bytes
        final fileBytes = file.bytes;
        if (fileBytes != null && fileBytes.isNotEmpty) {
          setState(() {
            selectedVoterIdFileBytes = fileBytes;
          });
          print('Voter ID File Bytes: ${selectedVoterIdFileBytes?.length}');
        } else {
          print('Failed to fetch file bytes or file is empty');
          _showSnackBar('Failed to fetch Voter ID file bytes');
        }
      } else {
        // No file selected
        setState(() {
          selectedVoterIdFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      _showSnackBar('Error picking file: $e');
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

  Future<void> _pickFileForPAN() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Get the file name
        setState(() {
          selectedPanFileName = file.name;
        });

        // Fetch file bytes
        final fileBytes = file.bytes;
        if (fileBytes != null && fileBytes.isNotEmpty) {
          setState(() {
            selectedPanFileBytes = fileBytes;
          });
          print('Pan File Bytes: ${selectedPanFileBytes?.length}');
        } else {
          print('Failed to fetch file bytes or file is empty');
          _showSnackBar('Failed to fetch Pan file bytes');
        }
      } else {
        // No file selected
        setState(() {
          selectedPanFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      _showSnackBar('Error picking file: $e');
    }
  }

  Future<void> _pickFileForNomineeAdhaar() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Get the file name
        setState(() {
          selectedNomineeAadharFileName = file.name;
        });

        // Fetch file bytes
        final fileBytes = file.bytes;
        if (fileBytes != null && fileBytes.isNotEmpty) {
          setState(() {
            selectedNomineeAadharFileBytes = fileBytes;
          });
          print(
              'Nominee Aadhaar File Bytes: ${selectedNomineeAadharFileBytes?.length}');
        } else {
          print('Failed to fetch file bytes or file is empty');
          _showSnackBar('Failed to fetch Nominee Aadhaar file bytes');
        }
      } else {
        // No file selected
        setState(() {
          selectedNomineeAadharFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      _showSnackBar('Error picking file: $e');
    }
  }

  Future<void> _pickFileForNomineeVoterId() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Get the file name
        setState(() {
          selectNomineeVoterIdFileName = file.name;
        });

        // Fetch file bytes
        final fileBytes = file.bytes;
        if (fileBytes != null && fileBytes.isNotEmpty) {
          setState(() {
            selectNomineeVoterIdFileBytes = fileBytes;
          });
          print(
              'Nominee Voter Id File Bytes: ${selectNomineeVoterIdFileBytes?.length}');
        } else {
          print('Failed to fetch file bytes or file is empty');
          _showSnackBar('Failed to fetch Nominee Voter Id file bytes');
        }
      } else {
        // No file selected
        setState(() {
          selectNomineeVoterIdFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      _showSnackBar('Error picking file: $e');
    }
  }

  Future<void> _pickFileForNomineePan() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Get the file name
        setState(() {
          selectedNomineePanFileName = file.name;
        });

        // Fetch file bytes
        final fileBytes = file.bytes;
        if (fileBytes != null && fileBytes.isNotEmpty) {
          setState(() {
            selectedNomineePanFileBytes = fileBytes;
          });
          print(
              'Nominee Pan File Bytes: ${selectedNomineePanFileBytes?.length}');
        } else {
          print('Failed to fetch file bytes or file is empty');
          _showSnackBar('Failed to fetch Nominee Pan file bytes');
        }
      } else {
        // No file selected
        setState(() {
          selectedNomineePanFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      _showSnackBar('Error picking file: $e');
    }
  }

  Future<void> _pickFileForRationCard() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Get the file name
        setState(() {
          selectedRationCardFileName = file.name;
        });

        // Fetch file bytes
        final fileBytes = file.bytes;
        if (fileBytes != null && fileBytes.isNotEmpty) {
          setState(() {
            selectedRationCardFileBytes = fileBytes;
          });
          print(
              'Ration Card File Bytes: ${selectedRationCardFileBytes?.length}');
        } else {
          print('Failed to fetch file bytes or file is empty');
          _showSnackBar('Failed to fetch Ration Card file bytes');
        }
      } else {
        // No file selected
        setState(() {
          selectedRationCardFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      _showSnackBar('Error picking file: $e');
    }
  }

  Future<void> _pickFileForPropertyTaxReceipt() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Get the file name
        setState(() {
          selectedpropertyTaxReceiptFileName = file.name;
        });

        // Fetch file bytes
        final fileBytes = file.bytes;
        if (fileBytes != null && fileBytes.isNotEmpty) {
          setState(() {
            selectedpropertyTaxReceiptFileBytes = fileBytes;
          });
          print(
              'Property Tax Receipt File Bytes: ${selectedpropertyTaxReceiptFileBytes?.length}');
        } else {
          print('Failed to fetch file bytes or file is empty');
          _showSnackBar('Failed to fetch Property Tax Receipt file bytes');
        }
      } else {
        // No file selected
        setState(() {
          selectedpropertyTaxReceiptFileName = 'No file chosen';
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      _showSnackBar('Error picking file: $e');
    }
  }

  Future<void> _pickFileForEBBill() async {
    try {
      // Open file picker for selecting files
      final result = await FilePicker.platform.pickFiles();

      // Check if a file was selected
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Get the file name
        setState(() {
          selectedEBBillFileName = file.name;
        });

        // Fetch file bytes
        final fileBytes = file.bytes;
        if (fileBytes != null && fileBytes.isNotEmpty) {
          setState(() {
            selectedEBBillFileBytes = fileBytes;
          });
          print('EB Bill File Bytes: ${selectedEBBillFileBytes?.length}');
        } else {
          print('Failed to fetch file bytes or file is empty');
        }
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
        final file = result.files.first;

        // Get the file name
        setState(() {
          selectedGasBillFileName = file.name;
        });

        // Fetch file bytes
        final fileBytes = file.bytes;
        if (fileBytes != null && fileBytes.isNotEmpty) {
          setState(() {
            selectedGasBillFileBytes = fileBytes;
          });
          print('Gas Bill File Bytes: ${selectedGasBillFileBytes?.length}');
        } else {
          print('Failed to fetch file bytes or file is empty');
        }
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
        final file = result.files.first;

        // Get the file name
        setState(() {
          selectedChequeLeafFileName = file.name;
        });

        // Fetch file bytes
        final fileBytes = file.bytes;
        if (fileBytes != null && fileBytes.isNotEmpty) {
          setState(() {
            selectedChequeLeafFileBytes = fileBytes;
          });
          print(
              'Cheque Leaf File Bytes: ${selectedChequeLeafFileBytes?.length}');
        } else {
          print('Failed to fetch file bytes or file is empty');
        }
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
        final file = result.files.first;

        // Get the file name
        setState(() {
          selectedBondSheetFileName = file.name;
        });

        // Fetch file bytes
        final fileBytes = file.bytes;
        if (fileBytes != null && fileBytes.isNotEmpty) {
          setState(() {
            selectedBondSheetFileBytes = fileBytes;
          });
          print('Bond Sheet File Bytes: ${selectedBondSheetFileBytes?.length}');
        } else {
          print('Failed to fetch file bytes or file is empty');
        }
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
              TextFormField(
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
                  onPressed: _pickImage,
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
                          children: [
                            // CircleAvatar with border
                            Container(
                              width:
                                  140, // Adjust width according to your needs
                              height:
                                  140, // Adjust height according to your needs
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.withOpacity(
                                      0.5), // Mild grey border color
                                  width: 2, // Border width
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _imageBytes != null
                                    ? MemoryImage(
                                        _imageBytes!) // Use image bytes to show the picked image
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
                                onTap:
                                    _pickImage, // Call the method to pick an image
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
                      TextFormField(
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a Customer ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an Address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return 'Please enter a valid phone number (10 digits)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Latitude TextFormField
                          Obx(
                            () => Expanded(
                              child: TextFormField(
                                controller: TextEditingController(
                                  text: controller.latitude.value,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Latitude value',
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                readOnly:
                                    true, // Make it non-editable since it's a live value
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Latitude value is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),

                          const SizedBox(
                              width:
                                  10), // Space between latitude and longitude

                          // Longitude TextFormField
                          Obx(
                            () => Expanded(
                              child: TextFormField(
                                controller: TextEditingController(
                                  text: controller.longitude.value,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Longitude value',
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                readOnly:
                                    true, // Make it non-editable since it's a live value
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Longitude value is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              await controller.getLocation();
                            },
                            child: const Text(
                              'Get Location',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20), // Space below the row

                      // Address TextFormField (same as before)
                      // Space below the address field

                      // Location Button

                      // Aadhaar No validation
                      TextFormField(
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Aadhaar number';
                          } else if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                            return 'Please enter a valid Aadhaar number (12 digits)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Branch Dropdown validation
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

                      // Center Dropdown validation
                      DropdownButtonFormField<String>(
                        value: selectedCenterId,
                        onChanged: (newValue) {
                          setState(() {
                            selectedCenterId = newValue;
                            selectedCenterName = centerData.firstWhere(
                                (center) => center['id'] == newValue)['name'];
                          });
                        },
                        items: centerData
                            .map((center) => DropdownMenuItem<String>(
                                  value: center['id'],
                                  child: Text(center['name']!),
                                ))
                            .toList(),
                        decoration: InputDecoration(
                          labelText: 'Select Center',
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
                        children: const [
                          Text(
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
                          TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 120),
                              hintText:
                                  selectedAadhaarFileName ?? 'No file chosen',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (selectedAadhaarFileName!.isEmpty) {
                                return 'Please select an Aadhaar file';
                              }
                              return null;
                            },
                          ),
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // The disabled text field to hold the button and text
                          TextFormField(
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // The disabled text field to hold the button and text
                          TextFormField(
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // The disabled text field to hold the button and text
                          TextFormField(
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // The disabled text field to hold the button and text
                          TextFormField(
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // The disabled text field to hold the button and text
                          TextFormField(
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // The disabled text field to hold the button and text
                          TextFormField(
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // The disabled text field to hold the button and text
                          TextFormField(
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // The disabled text field to hold the button and text
                          TextFormField(
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // The disabled text field to hold the button and text
                          TextFormField(
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // The disabled text field to hold the button and text
                          TextFormField(
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // The disabled text field to hold the button and text
                          TextFormField(
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 150, // Adjust the width as needed
                              child: ElevatedButton(
                                onPressed: () {
                                  _createCustomer();
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CustomerList(),
                                    ),
                                  );
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
