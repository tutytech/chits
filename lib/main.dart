import 'package:chitfunds/screens/LoginScreen.dart';
import 'package:chitfunds/screens/amountransfer.dart';
import 'package:chitfunds/screens/companycreation.dart';
import 'package:chitfunds/screens/createbranch.dart';
import 'package:chitfunds/screens/createcenter.dart';
import 'package:chitfunds/screens/createcustomer.dart';
import 'package:chitfunds/screens/createscheme.dart';
import 'package:chitfunds/screens/createstaff.dart';
import 'package:chitfunds/screens/customerreceipt.dart';
import 'package:chitfunds/screens/editcomapnydetails.dart';
import 'package:chitfunds/screens/registration.dart';
import 'package:chitfunds/screens/smssettings.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: CompanyCreationScreen(),
    );
  }
}
