import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  // Scan for devices
  Future<void> scanDevices() async {
    try {
      // Start scanning
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          print('${result.device.name} found! rssi: ${result.rssi}');
        }
      });

      // Stop scanning after the timeout
      await Future.delayed(const Duration(seconds: 5));
      // FlutterBluePlus.stopScan();
    } catch (e) {
      print('Error while scanning devices: $e');
    }
  }

  // Expose the scan results stream
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  // Connect to a Bluetooth device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      print('Connected to ${device.name}');
    } catch (e) {
      print('Error while connecting to device: $e');
    }
  }
}
