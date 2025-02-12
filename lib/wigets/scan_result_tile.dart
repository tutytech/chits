import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanResultTile extends StatefulWidget {
  ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  @override
  State<ScanResultTile> createState() => _ScanResultTileState();
}

class _ScanResultTileState extends State<ScanResultTile> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  BluetoothCharacteristic? _writeCharacteristic;

  @override
  void initState() {
    super.initState();

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
          "------------------------------------", // Footer
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
