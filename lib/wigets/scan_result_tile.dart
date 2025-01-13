import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ScanResultTile extends StatefulWidget {
  ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  @override
  State<ScanResultTile> createState() => _ScanResultTileState();
}

class _ScanResultTileState extends State<ScanResultTile> {
  List<dynamic> companyData = [];
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  BluetoothCharacteristic? _writeCharacteristic;

  @override
  void initState() {
    super.initState();
    fetchCompanyDetails();
    // Listen to the connection state of the device
    _connectionStateSubscription =
        widget.result.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchBranches() async {
    const String _baseUrl = 'https://chits.tutytech.in/receipt.php';

    try {
      // Debug: Print the request URL and parameters
      print('Request URL: $_baseUrl');
      print('Request Body: type=select');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'select'},
      );

      // Debug: Print the response
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as List<dynamic>;

        // Handle missing keys safely
        return responseData.map((branch) {
          return {
            'id': branch['id'] ?? '',
            'customername': branch['customername'] ?? 'Unknown Branch',
            'mobileno': branch['mobileno']?.toString() ?? '0',
            'loanamount': branch['loanamount'] ?? 'N/A',
            'receivedamount': branch['receivedamount'] ?? 'N/A',
            'depositamount': branch['depositamount'] ?? 'N/A',
            'paymenttype': branch['paymenttype'] ?? 'N/A',
            'chequeno': branch['chequeno'] ?? 'N/A',
            'chequedate': branch['chequedate'] ?? 'N/A',
            'bankname': branch['bankname'] ?? 'N/A',
            'remarks': branch['remarks'] ?? 'N/A',
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch branches');
      }
    } catch (e) {
      // Debug: Print the error
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> fetchCompanyDetails() async {
    final uri = Uri.parse('https://chits.tutytech.in/company.php');
    final requestBody = {'type': 'select'};

    try {
      // Print the request URL and body
      print('Request URL: $uri');
      print('Request Body: $requestBody');

      // Send POST request
      final response = await http.post(
        uri,
        body: requestBody,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      // Print the raw response
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the response
        final List<dynamic> responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty) {
          // Extract company details
          for (var company in responseData) {
            print('Company Name: ${company['companyname']}');
            print('Address: ${company['address']}');
            print('Phone No: ${company['phoneno']}');
            print('Mail ID: ${company['mailid']}');
            print('-----------------------');
          }

          setState(() {
            companyData = responseData;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No company data found.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to fetch data. Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> connectAndPrint() async {
    try {
      // Connect to the device
      await widget.result.device.connect();
      print("Connected to device: ${widget.result.device.remoteId.str}");

      // Discover services
      List<BluetoothService> services =
          await widget.result.device.discoverServices();

      // Find the write characteristic
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.write) {
            _writeCharacteristic = characteristic;
            break;
          }
        }
      }

      if (_writeCharacteristic != null) {
        // Prepare receipt data as a list of lines
        List<String> receiptLines = [
          "TutyTech.com", // Header
          "123 Market Street, Cityville, 12345",
          "Email: email@example.com",
          "Phone: (123) 456-7890",
          "------------------------------------",
          "Receipt No: 12345",
          "Receipt Date: 10-Jan-2025",
          "Customer ID: CUST001",
          "Customer Name: John Doe",
          "Mobile No : 1236547890",
          "Transaction Type: Purchase",
          "Amount: \$150.00",
          "Remarks: Success",
          "------------------------------------",
          "THANK YOU", // Footer
          "------------------------------------",
          "POWERED BY TUTYTECH",
          "------------------------------------",
        ];

        // Send each line separately to the printer
        for (String line in receiptLines) {
          String lineWithBreak = line + "\n"; // Add line break
          await _writeCharacteristic!.write(utf8.encode(lineWithBreak));
          await Future.delayed(
              Duration(milliseconds: 100)); // Small delay for processing
          print("Print data sent: $line");
        }
      } else {
        print("No write characteristic found!");
      }
    } catch (e) {
      print("Error while printing: $e");
    } finally {
      // Disconnect from the device
      await widget.result.device.disconnect();
      print("Disconnected from device: ${widget.result.device.remoteId.str}");
    }
  }

  Widget _buildTitle(BuildContext context) {
    if (widget.result.device.platformName.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.result.device.platformName,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            widget.result.device.remoteId.str,
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      );
    } else {
      return Text(widget.result.device.remoteId.str);
    }
  }

  Widget _buildConnectButton(BuildContext context) {
    return ElevatedButton(
      child: isConnected ? const Text('PRINT') : const Text('CONNECT'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        if (widget.result.advertisementData.connectable) {
          connectAndPrint();
        }
      },
    );
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  @override
  Widget build(BuildContext context) {
    var adv = widget.result.advertisementData;
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(widget.result.rssi.toString()),
      trailing: _buildConnectButton(context),
      children: <Widget>[
        if (adv.advName.isNotEmpty) Text("Name: ${adv.advName}"),
        if (adv.txPowerLevel != null)
          Text("Tx Power Level: ${adv.txPowerLevel}"),
        if ((adv.appearance ?? 0) > 0)
          Text('Appearance: 0x${adv.appearance!.toRadixString(16)}'),
        if (adv.serviceUuids.isNotEmpty)
          Text('Service UUIDs: ${adv.serviceUuids.join(', ')}'),
      ],
    );
  }
}
