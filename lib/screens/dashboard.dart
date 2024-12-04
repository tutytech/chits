import 'package:chitfunds/screens/createcenter.dart';
import 'package:chitfunds/wigets/customappbar.dart';
import 'package:chitfunds/wigets/customdrawer.dart';
import 'package:chitfunds/wigets/inputwidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> branchNames = [];
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _openingBalanceController =
      TextEditingController();
  final TextEditingController _openingDateController = TextEditingController();
  final entrydateController = TextEditingController();
  final dobController = TextEditingController();
  final dojController = TextEditingController();
  final domController = TextEditingController();
  Future<void> _selectMarriage(BuildContext context, String label) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: label == "DOB"
          ? dobController.text.isNotEmpty
              ? DateFormat('yyyy-MM-dd').parse(dobController.text)
              : DateTime.now()
          : label == "DOJ"
              ? dojController.text.isNotEmpty
                  ? DateFormat('yyyy-MM-dd').parse(dojController.text)
                  : DateTime.now()
              : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        String formattedDate = DateFormat('yyyy-MM-dd').format(picked);

        // Update the correct controller based on the label
        if (label == "DOB") {
          dobController.text = formattedDate;
        } else if (label == "DOJ") {
          dojController.text = formattedDate;
        } else if (label == "DOM") {
          domController.text = formattedDate;
        } else if (label == "EntryDate") {
          entrydateController.text = formattedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Dashboard',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(branchNames: branchNames),
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
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: const Color.fromARGB(218, 209, 209, 204),
              padding: const EdgeInsets.all(10.0),
              child: const Text(
                'POWERED BY TUTYTECH',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarriageDateField(BuildContext context, String label) {
    TextEditingController controller;

    // Select the correct controller based on the label
    if (label == "DOB") {
      controller = dobController;
    } else if (label == "DOJ") {
      controller = dojController;
    } else if (label == "DOM") {
      controller = domController;
    } else if (label == "EntryDate") {
      controller = entrydateController;
    } else {
      throw ArgumentError("Invalid label: $label");
    }

    return InputWidget(
      label: label,
      controller: controller,
      hintText: "Opening Date",
      readOnly: true, // Make the field read-only
      suffixWidget: IconButton(
        icon: Icon(Icons.calendar_today, color: Colors.grey),
        onPressed: () => _selectMarriage(
          context,
          label,
        ),
      ),
    );
  }
}
