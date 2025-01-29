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
import 'package:chitfunds/screens/receiptlist.dart';
import 'package:chitfunds/screens/schemelist.dart';
import 'package:chitfunds/screens/stafflist.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  final String? rights;
  final List<String>? branchNames;
  const CustomDrawer({this.branchNames, this.rights});

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
    bool isAdmin = widget.rights?.toLowerCase() == "admin";

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
                        builder: (context) => CollectionReport(),
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
                        builder: (context) => Centerwisereport(),
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
                        builder: (context) => Outstandingreport(),
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
                        builder: (context) => const DeleteReport(),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => closeAccountList()),
                );
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

          // Show only for non-admin users
          if (!isAdmin) ...[
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
                        builder: (context) => CollectionReport(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
          // Staff and other settings can be added here if needed
        ],
      ),
    );
  }
}
