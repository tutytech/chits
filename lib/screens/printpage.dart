import 'package:chitfunds/controlller/bluetooth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
// Import your BluetoothController

class BluetoothDeviceListScreen extends StatelessWidget {
  const BluetoothDeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Devices"),
      ),
      body: GetBuilder<BluetoothController>(
        init: BluetoothController(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: controller.scanDevices,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(350, 55),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                    child: const Text(
                      'Scan',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<ScanResult>>(
                  stream: controller?.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final device = snapshot.data![index].device;
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text(
                                  device.name.isNotEmpty
                                      ? device.name
                                      : 'Unknown Device',
                                ),
                                subtitle: Text(device.id.id),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    controller?.connectToDevice(device);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: device.isConnected
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                  child: Text(
                                    device.isConnected
                                        ? 'Connected'
                                        : 'Connect',
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text("No devices found"),
                        );
                      }
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return const Center(
                        child: Text("Press Scan to search for devices."),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
