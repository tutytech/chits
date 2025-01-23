import 'package:chitfunds/screens/Reports/collectionreport.dart';
import 'package:chitfunds/screens/amountransfer.dart';
import 'package:chitfunds/screens/branchlist.dart';
import 'package:chitfunds/screens/centerlist..dart';
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
import 'package:chitfunds/screens/receiptlist.dart';
import 'package:chitfunds/screens/schemelist.dart';
import 'package:chitfunds/screens/stafflist.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  final List<String>? branchNames;
  const CustomDrawer({this.branchNames});

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

  Future<void> _loadCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      companyId = prefs.getString('companyId');
      print('------------------------------$companyId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 130, // Keep the header height as 100
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Image.asset(
                  'nobglogo.png', // Path to your logo image
                  height:
                      120, // Keep the height of the image equal to the header height
                  width:
                      120, // Keep the width of the image equal to the header width
                  fit: BoxFit
                      .contain, // Ensures the logo scales to fit within the available space
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Customer'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomerList()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Branch'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BranchListPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Center'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CenterListPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('Scheme'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SchemeListPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Chits/Loan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Loan()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Receipt'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => receiptListPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.transfer_within_a_station),
            title: const Text('Voucher'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AmountTransfer()),
              );
            },
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.symmetric(
                horizontal: 16.0), // Match ListTile padding
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            childrenPadding:
                EdgeInsets.only(left: 32.0), // Indent child items slightly
            children: [
              ListTile(
                leading: const Icon(Icons.arrow_right),
                title: const Text('Collection Report'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CollectionReport(),
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
                MaterialPageRoute(builder: (context) => staffListPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_box),
            title: const Text('Closed Accounts'),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => ClosedAccountsPage()),
              // );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => SettingsPage()),
              // );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Edit Company Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCompany(id: companyId!),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('SMS Settings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditSmsSettings()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
