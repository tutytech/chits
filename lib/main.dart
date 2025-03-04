import 'dart:async';

import 'package:chitfunds/screens/LoginScreen.dart';
import 'package:chitfunds/screens/Reports/branchwisereport.dart';
import 'package:chitfunds/screens/Reports/centerwisereport.dart';
import 'package:chitfunds/screens/Reports/collectionreport.dart';
import 'package:chitfunds/screens/Reports/outstandingreport.dart';
import 'package:chitfunds/screens/Reports/deletereport.dart';
import 'package:chitfunds/screens/amountransfer.dart';
import 'package:chitfunds/screens/bluetooth_off_screen.dart';
import 'package:chitfunds/screens/branchlist.dart';
import 'package:chitfunds/screens/centerlist..dart';
import 'package:chitfunds/screens/closeaccountlist.dart';
import 'package:chitfunds/screens/companycreation.dart';
import 'package:chitfunds/screens/createbranch.dart';
import 'package:chitfunds/screens/createcenter.dart';
import 'package:chitfunds/screens/createcustomer.dart';
import 'package:chitfunds/screens/createscheme.dart';
import 'package:chitfunds/screens/createstaff.dart';
import 'package:chitfunds/screens/customerlist.dart';
import 'package:chitfunds/screens/customerlogindashboard.dart';
import 'package:chitfunds/screens/customerreceipt.dart';
import 'package:chitfunds/screens/dashboard.dart';
import 'package:chitfunds/screens/editcenter.dart';
import 'package:chitfunds/screens/editcomapnydetails.dart';
import 'package:chitfunds/screens/editcompany.dart';
import 'package:chitfunds/screens/loan.dart';
import 'package:chitfunds/screens/loanlist.dart';
import 'package:chitfunds/screens/payment.dart';
import 'package:chitfunds/screens/receiptlist.dart';
import 'package:chitfunds/screens/registration.dart';
import 'package:chitfunds/screens/scan_screen.dart';
import 'package:chitfunds/screens/schemelist.dart';
import 'package:chitfunds/screens/smssettings.dart';
import 'package:chitfunds/screens/stafflist.dart';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  // For testing: force login screen on app start by setting isLoggedIn to false.

  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final lastScreen = prefs.getString('lastScreen') ?? 'LoginScreen';
  final rights = prefs.getString('rights');

  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  FlutterDownloader.initialize(debug: true);

  runApp(MyApp(isLoggedIn: isLoggedIn, lastScreen: lastScreen, rights: rights));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final String? lastScreen, rights;
  MyApp(
      {Key? key,
      required this.isLoggedIn,
      required this.lastScreen,
      this.rights})
      : super(key: key);

  @override
  State<MyApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<MyApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: const Color.from(alpha: 1, red: 0.012, green: 0.663, blue: 0.957),
      home: _getInitialScreen(),
      navigatorObservers: [BluetoothAdapterStateObserver()],
    );
  }

  Widget _getInitialScreen() {
    if (widget.isLoggedIn) {
      // Check the last visited screen and navigate accordingly
      switch (widget.lastScreen) {
        case 'Dashboard':
          return Dashboard(rights: widget.rights);

        default:
          return Dashboard(rights: widget.rights);
      }
    } else {
      return const LoginScreen();
    }
  }
}

class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Start listening to Bluetooth state changes when a new route is pushed
      _adapterStateSubscription ??=
          FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // Pop the current route if Bluetooth is off
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}
